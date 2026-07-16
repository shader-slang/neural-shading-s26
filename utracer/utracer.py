"""
utracer.py -- Micro Path Tracer (single self-contained Python file)

A minimal path tracer using slangpy, numpy and trimesh.
No dependency on falcor2.
"""

from __future__ import annotations

import math
from os import PathLike
from pathlib import Path
import sys
from typing import Optional, Union, cast

import numpy as np
import slangpy as spy
from slangpy import (
    AccelerationStructureBuildDesc,
    AccelerationStructureBuildFlags,
    AccelerationStructureBuildInputTriangles,
    AccelerationStructureBuildMode,
    AccelerationStructureGeometryFlags,
    Bitmap,
    Buffer,
    BufferOffsetPair,
    BufferUsage,
    Format,
    IndexFormat,
    Module,
    Tensor,
    TextureLoader,
    float3,
    int2,
    quatf,
    uint2,
    uint3,
)
from slangpy.math import (
    matrix_from_quat,
    normalize,
    quat_from_look_at,
    radians,
    tan,
)
import slangpy.bindings as spybind
import slangpy.reflection as spyref

#sys.path.append(str(Path(__file__).parent / "materials/ceramic"))
#sys.path.append(str(Path(__file__).parent / "materials/velvet"))

from materials.ceramic.mdl_ceramic_material import CeramicMaterial
from materials.velvet.mdl_velvet_material import VelvetMaterial
from neural.common.linear_layer import preferred_device_type, validate_device
from .neural_checkpoint import BakedNeuralMaterial, load_baked_neural_material

NON_NEURAL_MATERIAL = 0
NEURAL_BAKED_MATERIAL = 3


def create_device(device_type: Optional[spy.DeviceType] = None) -> spy.Device:
    """Create a SlangPy device configured for utracer."""
    if device_type is None:
        device_type = preferred_device_type()
    return spy.create_device(
        type=device_type,
        include_paths=[Path(__file__).parent, Path(__file__).parent.parent],
    )

class Camera:
    """Pinhole camera with orbital controls."""

    def __init__(self, device: spy.Device, width: int = 1024, height: int = 1024, fov_degrees: float = 45.0):
        self.device = device
        self.width = width
        self.height = height
        self.fov_degrees = fov_degrees
        self.pos = float3(1.8, 0.7, 0.4)
        self.rot = quat_from_look_at(-normalize(self.pos), float3(0, 1, 0))
        self.image_u = float3(1, 0, 0)
        self.image_v = float3(0, 1, 0)
        self.image_w = float3(0, 0, -1)
        self._output = self._create_texture()
        self._accumulator = self._create_texture()
        self.recompute()

    def recompute(self) -> None:
        aspect_ratio = float(self.width) / float(self.height)
        rot = matrix_from_quat(self.rot)
        fov = radians(self.fov_degrees)
        right = rot.get_col(0)
        up = rot.get_col(1)
        fwd = -rot.get_col(2)
        self.image_u = right * tan(fov * 0.5) * aspect_ratio
        self.image_v = up * tan(fov * 0.5)
        self.image_w = fwd

    def set_orbit(self, distance: float, elevation: float, azimuth: float) -> None:
        x = distance * math.cos(elevation) * math.sin(azimuth)
        y = distance * math.sin(elevation)
        z = distance * math.cos(elevation) * math.cos(azimuth)
        self.pos = float3(x, y, z)
        self.rot = quat_from_look_at(-normalize(self.pos), float3(0, 1, 0))
        self.recompute()

    def get_uniforms(self) -> dict[str, object]:
        self.recompute()
        return {
            "position": self.pos,
            "image_u": self.image_u,
            "image_v": self.image_v,
            "image_w": self.image_w,
            "dims": int2(self.width, self.height),
        }

    def _create_texture(self) -> spy.Texture:
        return self.device.create_texture(
            width=self.width,
            height=self.height,
            format=Format.rgba32_float,
            usage=spy.TextureUsage.shader_resource | spy.TextureUsage.unordered_access,
        )

    def reset_accumulator(self, module: "Module", cmd: Optional[spy.CommandEncoder] = None) -> None:
        if cmd is not None:
            module.accumulator_reset(self._accumulator, _append_to=cmd)
        else:
            module.accumulator_reset(self._accumulator)

    @property
    def output(self) -> spy.Texture:
        return self._output

    @property
    def accumulator(self) -> spy.Texture:
        return self._accumulator

class CameraMarshall(spybind.Marshall):
    def __init__(self, layout: spyref.SlangProgramLayout):
        super().__init__(layout)
        ct = layout.find_type_by_name("Camera")
        assert ct is not None
        self.slang_type = ct

    def get_shape(self, value: Camera):
        return spybind.Shape(value.height, value.width)

    def resolve_type(self, context: spybind.BindContext, bound_type: spyref.SlangType):
        return bound_type

    def resolve_dimensionality(
        self,
        context: spybind.BindContext,
        binding: spybind.BoundVariable,
        vector_target_type: spyref.SlangType,
    ):
        if vector_target_type.full_name == "RaySampler":
            return 2
        return 0

    def create_calldata(
        self, context: spybind.BindContext, binding: spybind.BoundVariable, data: "Camera"
    ):
        return data.get_uniforms()

    def gen_calldata(
        self,
        cgb: spybind.CodeGenBlock,
        context: spybind.BindContext,
        binding: spybind.BoundVariable,
    ):
        cgb.type_alias(f"_t_{binding.variable_name}", "Camera")

spybind.PYTHON_TYPES[Camera] = lambda layout, value: CameraMarshall(layout)

# =============================================================================
# MicroScene
# =============================================================================

class MicroScene:
    def __init__(self, device: spy.Device):
        validate_device(device)
        self.device = device
        self.module = Module(device.load_module("utracer"))
        self.sample = 0
        self._vertices_np: Optional[np.ndarray] = None
        self._indices_np: Optional[np.ndarray] = None
        self._vertex_tensor: Optional[Tensor] = None
        self._index_tensor: Optional[Tensor] = None
        self._blas: Optional[spy.AccelerationStructure] = None
        self._tlas: Optional[spy.AccelerationStructure] = None
        self._blas_scratch: Optional[Buffer] = None
        self._tlas_scratch: Optional[Buffer] = None
        self._sampler = self.device.create_sampler(
            min_filter=spy.TextureFilteringMode.linear,
            mag_filter=spy.TextureFilteringMode.linear,
            address_u=spy.TextureAddressingMode.wrap,
            address_v=spy.TextureAddressingMode.wrap,
        )
        self._white_texture = self._make_solid_texture(1.0, 1.0, 1.0, 1.0)
        self._black_texture = self._make_solid_texture(0.0, 0.0, 0.0, 1.0)
        self._default_normal_texture = self._make_solid_texture(0.5, 0.5, 1.0, 1.0)
        self._albedo_texture: spy.Texture = self._white_texture
        self._roughness_texture: spy.Texture = self._make_solid_texture(0.05, 0.05, 0.05, 1.0)
        self._metallic_texture: spy.Texture = self._black_texture
        self._specular_texture: spy.Texture = self._white_texture
        self._normal_texture: spy.Texture = self._default_normal_texture
        self._normal_map_strength: float = 1.0
        self._env_texture: Optional[spy.Texture] = None
        self._env_scaling: float3 = float3(1.0)
        self._material_mode: int = NON_NEURAL_MATERIAL
        self._dirty = True

        self.ceramic = CeramicMaterial(device)
        self.velvet = VelvetMaterial(device)
        self._neural_material = BakedNeuralMaterial(device, self.module, latent_resolution=1)

    def _create_texture_from_numpy(self, data: np.ndarray) -> spy.Texture:
        assert data.ndim == 3 and data.shape[2] == 4, f"Expected HxWx4 array, got {data.shape}"
        data = data.astype(np.float32)
        h, w = data.shape[:2]
        tex = self.device.create_texture(
            width=w,
            height=h,
            format=Format.rgba32_float,
            usage=spy.TextureUsage.shader_resource,
        )
        tex.copy_from_numpy(data)
        return tex

    def _make_solid_texture(self, r: float, g: float, b: float, a: float) -> spy.Texture:
        data = np.full((4, 4, 4), 0.0, dtype=np.float32)
        data[:, :, 0] = r
        data[:, :, 1] = g
        data[:, :, 2] = b
        data[:, :, 3] = a
        return self._create_texture_from_numpy(data)

    def load_mesh(self, path: Union[str, PathLike[str]], rescale_to: Optional[float] = None) -> None:
        """
        Load a mesh from a GLTF/OBJ file using trimesh.
        Extracts vertices, indices and first material textures.
        """
        import trimesh

        scene_or_mesh = trimesh.load(str(path), process=False)

        # Handle Scene vs Trimesh
        if isinstance(scene_or_mesh, trimesh.Scene):
            meshes = list(scene_or_mesh.geometry.values())
            if len(meshes) == 0:
                raise ValueError(f"No meshes found in {path}")
            # Combine all meshes into one
            mesh = cast(trimesh.Geometry, trimesh.util.concatenate (meshes))
        else:
            mesh = scene_or_mesh

        # Rotate 90 degrees about X axis (Y-up to Z-up or vice versa)
        #rot = trimesh.transformations.rotation_matrix(math.radians(90), [1, 0, 0])
        #mesh.apply_transform(rot)

        # Optionally rescale to fit in a bounding sphere
        if rescale_to is not None:
            extents = mesh.bounding_box.extents
            max_extent = max(extents)
            if max_extent > 0:
                scale = rescale_to / max_extent
                mesh.apply_scale(scale)
            # Center the mesh
            centroid = mesh.centroid
            mesh.apply_translation(-centroid)

        # Extract vertex data
        positions = np.asarray(mesh.vertices, dtype=np.float32)
        faces = np.asarray(mesh.faces, dtype=np.uint32)

        # Normals
        if mesh.vertex_normals is not None and len(mesh.vertex_normals) == len(positions):
            normals = np.asarray(mesh.vertex_normals, dtype=np.float32)
        else:
            normals = np.zeros_like(positions)

        # UVs
        if hasattr(mesh.visual, "uv") and mesh.visual.uv is not None:
            uvs = np.asarray(mesh.visual.uv, dtype=np.float32)
        else:
            uvs = np.zeros((len(positions), 2), dtype=np.float32)

        # Compute tangents (simple method)
        tangents = np.zeros_like(positions)
        bitangents = np.zeros_like(positions)
        _compute_tangents(positions, normals, uvs, faces, tangents, bitangents)

        # Vertex colors
        colors = np.ones((len(positions), 3), dtype=np.float32)
        if (
            hasattr(mesh.visual, "vertex_colors")
            and mesh.visual.vertex_colors is not None
            and len(mesh.visual.vertex_colors) == len(positions)
        ):
            vc = np.asarray(mesh.visual.vertex_colors, dtype=np.float32)
            if vc.shape[1] >= 3:
                colors = vc[:, :3] / 255.0 if vc.max() > 1.0 else vc[:, :3]

        # Pack into structured vertex array
        # Layout: position(3), normal(3), tangent(3), bitangent(3), color(3), uv(2) = 17 floats
        vertex_count = len(positions)
        vertex_data = np.zeros((vertex_count, 17), dtype=np.float32)
        vertex_data[:, 0:3] = positions
        vertex_data[:, 3:6] = normals
        vertex_data[:, 6:9] = tangents
        vertex_data[:, 9:12] = bitangents
        vertex_data[:, 12:15] = colors
        vertex_data[:, 15:17] = uvs[:, :2]

        self._vertices_np = vertex_data
        self._indices_np = faces.flatten().astype(np.uint32)

        # Try to extract material textures from trimesh
        self._extract_material_textures(mesh)

        self._dirty = True

    def _extract_material_textures(self, mesh: object) -> None:
        """Attempt to extract PBR textures from trimesh material."""
        try:
            import trimesh

            if not hasattr(mesh, "visual") or mesh.visual is None:
                return

            material = None
            if hasattr(mesh.visual, "material"):
                material = mesh.visual.material

            if material is None:
                return

            # Handle PBR material
            if isinstance(material, trimesh.visual.material.PBRMaterial):
                if material.baseColorTexture is not None:
                    img = np.asarray(material.baseColorTexture.convert("RGBA"), dtype=np.float32) / 255.0
                    self._albedo_texture = self._create_texture_from_numpy(img)

                if material.metallicRoughnessTexture is not None:
                    img = np.asarray(material.metallicRoughnessTexture.convert("RGBA"), dtype=np.float32) / 255.0
                    # Green channel = roughness, Blue channel = metallic  (glTF convention)
                    roughness_data = np.zeros_like(img)
                    roughness_data[:, :, 0] = img[:, :, 1]  # roughness in R
                    roughness_data[:, :, 1] = img[:, :, 1]
                    roughness_data[:, :, 2] = img[:, :, 1]
                    roughness_data[:, :, 3] = 1.0
                    self._roughness_texture = self._create_texture_from_numpy(roughness_data)

                    metallic_data = np.zeros_like(img)
                    metallic_data[:, :, 0] = img[:, :, 2]  # metallic in R
                    metallic_data[:, :, 1] = img[:, :, 2]
                    metallic_data[:, :, 2] = img[:, :, 2]
                    metallic_data[:, :, 3] = 1.0
                    self._metallic_texture = self._create_texture_from_numpy(metallic_data)

                if material.normalTexture is not None:
                    img = np.asarray(material.normalTexture.convert("RGBA"), dtype=np.float32) / 255.0
                    self._normal_texture = self._create_texture_from_numpy(img)

            elif isinstance(material, trimesh.visual.material.SimpleMaterial):
                # Simple material: use diffuse color as albedo
                if hasattr(material, "image") and material.image is not None:
                    img = np.asarray(material.image.convert("RGBA"), dtype=np.float32) / 255.0
                    self._albedo_texture = self._create_texture_from_numpy(img)

        except Exception:
            pass  # Silently fall back to defaults

    def set_env_map(self, path: Union[str, PathLike[str]], scaling: float = 1.0) -> None:
        bitmap = Bitmap.load_from_file(str(path))
        bitmap = bitmap.convert(
            pixel_format=Bitmap.PixelFormat.rgba,
            component_type=Bitmap.ComponentType.float32,
            srgb_gamma=False,
        )
        data = np.asarray(bitmap, copy=False)
        self._env_texture = self._create_texture_from_numpy(data)
        self._env_scaling = float3(scaling)
        self._dirty = True

    def set_neural_checkpoint(
        self,
        path: Union[str, PathLike[str]],
    ) -> None:
        """Load a neural checkpoint and render it through baked latents."""
        self._neural_material = load_baked_neural_material(
            self.device,
            self.module,
            path,
        )
        self._material_mode = NEURAL_BAKED_MATERIAL
        self.sample = 0

    def set_albedo_texture(self, path_or_data: Union[str, PathLike[str], np.ndarray]) -> None:
        self._albedo_texture = self._load_texture(path_or_data)
        self._dirty = True

    def set_roughness_texture(self, path_or_data: Union[str, PathLike[str], np.ndarray]) -> None:
        self._roughness_texture = self._load_texture(path_or_data)
        self._dirty = True

    def set_metallic_texture(self, path_or_data: Union[str, PathLike[str], np.ndarray]) -> None:
        self._metallic_texture = self._load_texture(path_or_data)
        self._dirty = True

    def set_normal_texture(self, path_or_data: Union[str, PathLike[str], np.ndarray]) -> None:
        self._normal_texture = self._load_texture(path_or_data)
        self._dirty = True

    def _load_texture(self, path_or_data: Union[str, PathLike[str], np.ndarray]) -> spy.Texture:
        if isinstance(path_or_data, np.ndarray):
            data = path_or_data.astype(np.float32)
            if data.ndim == 2:
                data = np.stack([data] * 4, axis=-1)
            elif data.ndim == 3 and data.shape[2] == 3:
                alpha = np.ones((*data.shape[:2], 1), dtype=np.float32)
                data = np.concatenate([data, alpha], axis=-1)
            return self._create_texture_from_numpy(data)
        else:
            loader = TextureLoader(self.device)
            return loader.load_texture(
                path=str(path_or_data),
                options={"load_as_normalized": True},
            )

    def build(self) -> None:
        if not self._dirty:
            return
        if self._vertices_np is None or self._indices_np is None:
            raise ValueError("No mesh loaded. Call load_mesh() first.")

        # Upload vertex data
        vertex_type = self.module.layout.require_type_by_name("Vertex")
        vertex_count = len(self._vertices_np)
        self._vertex_tensor = Tensor.empty(self.device, (vertex_count,), vertex_type)
        cursor = self._vertex_tensor.cursor()
        cursor.write_from_numpy(
            {
                "position": self._vertices_np[:, 0:3],
                "normal": self._vertices_np[:, 3:6],
                "tangent": self._vertices_np[:, 6:9],
                "bitangent": self._vertices_np[:, 9:12],
                "color": self._vertices_np[:, 12:15],
                "uv": self._vertices_np[:, 15:17],
            },
            unchecked_copy=True,
        )
        cursor.apply()

        # Upload index data
        index_count = len(self._indices_np)
        self._index_tensor = Tensor.empty(self.device, (index_count,), "uint")
        idx_cursor = self._index_tensor.cursor()
        idx_cursor.write_from_numpy(self._indices_np, unchecked_copy=True)
        idx_cursor.apply()

        # Build acceleration structures
        self._build_blas()
        self._build_tlas()
        self._dirty = False

    def _build_blas(self) -> None:
        """Build bottom-level acceleration structure from vertex/index data."""
        assert self._vertex_tensor is not None
        assert self._index_tensor is not None
        assert self._vertices_np is not None
        assert self._indices_np is not None

        blas_input = AccelerationStructureBuildDesc()
        blas_input.mode = AccelerationStructureBuildMode.build
        blas_input.flags = AccelerationStructureBuildFlags.none

        # Vertex stride: 17 floats * 4 bytes = 68 bytes per vertex
        # Layout: pos(3) + normal(3) + tangent(3) + bitangent(3) + color(3) + uv(2)
        vertex_stride = 17 * 4
        vertex_count = len(self._vertices_np)
        index_count = len(self._indices_np)

        triangles = AccelerationStructureBuildInputTriangles()
        triangles.vertex_buffers = [BufferOffsetPair(self._vertex_tensor.storage, 0)]
        triangles.vertex_count = vertex_count
        triangles.vertex_stride = vertex_stride
        triangles.vertex_format = Format.rgb32_float
        triangles.index_buffer = BufferOffsetPair(self._index_tensor.storage, 0)
        triangles.index_count = index_count
        triangles.index_format = IndexFormat.uint32
        triangles.flags = AccelerationStructureGeometryFlags.opaque
        blas_input.inputs = [triangles]

        prebuild = self.device.get_acceleration_structure_sizes(blas_input)
        if not self._blas_scratch or self._blas_scratch.size < prebuild.scratch_size:
            self._blas_scratch = self.device.create_buffer(
                prebuild.scratch_size,
                usage=BufferUsage.unordered_access,
                label="utracer_blas_scratch",
            )
        self._blas = self.device.create_acceleration_structure(
            size=prebuild.acceleration_structure_size,
            label="utracer_blas",
        )

        cmd = self.device.create_command_encoder()
        cmd.build_acceleration_structure(
            desc=blas_input,
            dst=self._blas,
            src=None,
            scratch_buffer=self._blas_scratch,
        )
        self.device.submit_command_buffer(cmd.finish())

    def _build_tlas(self) -> None:
        """Build top-level acceleration structure with a single instance."""
        assert self._blas is not None
        instance_list = self.device.create_acceleration_structure_instance_list(1)
        instance_list.write(
            0,
            {
                "transform": spy.float3x4.identity(),
                "instance_id": 0,
                "instance_mask": 0xFF,
                "instance_contribution_to_hit_group_index": 0,
                "flags": spy.AccelerationStructureInstanceFlags.none,
                "acceleration_structure": self._blas.handle,
            },
        )

        tlas_input = AccelerationStructureBuildDesc()
        tlas_input.mode = AccelerationStructureBuildMode.build
        tlas_input.flags = AccelerationStructureBuildFlags.none
        tlas_input.inputs = [instance_list.build_input_instances()]

        prebuild = self.device.get_acceleration_structure_sizes(tlas_input)
        if not self._tlas_scratch or self._tlas_scratch.size < prebuild.scratch_size:
            self._tlas_scratch = self.device.create_buffer(
                size=prebuild.scratch_size,
                usage=BufferUsage.unordered_access,
                label="utracer_tlas_scratch",
            )

        self._tlas = self.device.create_acceleration_structure(
            size=prebuild.acceleration_structure_size,
            label="utracer_tlas",
        )

        cmd = self.device.create_command_encoder()
        cmd.build_acceleration_structure(
            desc=tlas_input,
            dst=self._tlas,
            src=None,
            scratch_buffer=self._tlas_scratch,
        )
        self.device.submit_command_buffer(cmd.finish())

    def get_uniforms(self) -> dict[str, object]:
        """Return a dict matching the Slang Scene struct layout."""
        assert self._vertex_tensor is not None
        assert self._index_tensor is not None

        material_uniforms = {
            "albedo": self._albedo_texture,
            "roughness": self._roughness_texture,
            "metallic": self._metallic_texture,
            "specular": self._specular_texture,
            "normal": self._normal_texture,
            "normal_map_strength": self._normal_map_strength,
        }

        if self._env_texture is not None:
            env_uniforms = {
                "texture": self._env_texture,
                "scaling_factor": self._env_scaling,
                "valid": True,
            }
        else:
            env_uniforms = {
                "texture": self._black_texture,
                "scaling_factor": float3(0.0),
                "valid": False,
            }

        return {
            "_type": "Scene",
            "tlas": self._tlas,
            "vertices": self._vertex_tensor.storage,
            "indices": self._index_tensor.storage,
            "material": material_uniforms,
            "material_mode": self._material_mode,
            "neural_material": spy.slangpy.unpack_arg(self._neural_material),
            "sampler": self._sampler,
            "env_map": env_uniforms,
        }

    def render(
        self,
        camera: Camera,
        tone_map: bool = True,
        denoise: bool = False,
    ) -> spy.Texture:
        self.build()
        camera.recompute()

        cmd = self.device.create_command_encoder()

        uniforms = {}
        uniforms.update({
            "g_scene": self.get_uniforms(),
        })
        uniforms.update(self.ceramic.to_global_uniforms())

        self.module.render.set(uniforms).call(
            camera,
            camera.output,
            spp=128,
            iteration=self.sample,
            _append_to=cmd,
        )
        self.module.accumulator_update(camera.output, camera.accumulator, _append_to=cmd)
        self.module.accumulator_output(camera.accumulator, camera.output, _append_to=cmd)
        self.sample += 1
        self.device.submit_command_buffer(cmd.finish())

        # Optional AI denoising pass (Intel Open Image Denoise)
        if denoise:
            self._denoise_oidn(camera)

        if tone_map:
            tonemapped = camera._create_texture()
            self.module.apply_tonemap(camera.output, tonemapped)
            return tonemapped

        return camera.output

    def _denoise_oidn(self, camera: Camera) -> None:
        """Denoise camera.output in-place using Intel Open Image Denoise (OIDN).

        This is an AI-based denoiser specifically trained for path-traced images.
        It works well even at very low sample counts.
        """
        import pyoidn

        # Lazily create the OIDN device (reuse across frames)
        if not hasattr(self, "_oidn_device"):
            self._oidn_device = pyoidn.Device(pyoidn.OIDN_DEVICE_TYPE_CPU)
            self._oidn_device.commit()

        # Read HDR color from GPU texture → numpy (H, W, 4) float32
        rgba = camera.output.to_numpy()  # shape: (H, W, 4)
        h, w = rgba.shape[:2]

        # OIDN expects contiguous float3 (RGB)
        rgb = np.ascontiguousarray(rgba[:, :, :3])
        out = np.zeros_like(rgb)

        f = pyoidn.Filter(self._oidn_device, "RT")
        f.set_image("color", rgb, pyoidn.OIDN_FORMAT_FLOAT3, width=w, height=h)
        f.set_image("output", out, pyoidn.OIDN_FORMAT_FLOAT3, width=w, height=h)
        f.set_bool("hdr", True)
        f.commit()
        f.execute()
        self._oidn_device.wait()

        # Write denoised result back to the GPU texture
        denoised_rgba = np.ones((h, w, 4), dtype=np.float32)
        denoised_rgba[:, :, :3] = out
        camera._output.copy_from_numpy(denoised_rgba)


# =============================================================================
# Viewer
# =============================================================================


class Viewer:
    """Interactive viewer with orbital camera controls."""

    def __init__(
        self,
        scene: MicroScene,
        camera: Camera,
        title: str = "utracer",
    ):
        self.scene = scene
        self.camera = camera
        self.window = spy.Window(width=camera.width, height=camera.height, title=title, resizable=False)
        self.device = scene.device
        self.surface = self.device.create_surface(self.window)
        self.surface.configure(width=self.window.width, height=self.window.height)
        self.window.on_keyboard_event = self._on_keyboard_event
        self.window.on_mouse_event = self._on_mouse_event
        self.window.on_resize = self._on_resize
        self._blit_texture: Optional[spy.Texture] = None
        self._frame = 0
        self._last_mouse_pos = spy.float2(0, 0)
        self._is_dragging = False
        self._drag_start_pos = spy.float2(0, 0)
        self._camera_start_pos = float3(0, 0, 0)
        self.camera.reset_accumulator(self.scene.module)

    def run(self) -> None:
        while self.update():
            pass

    def update(self) -> bool:
        if self.window.should_close():
            return False
        self.window.process_events()
        output = self.scene.render(self.camera, tone_map=False, denoise=False)
        self._frame += 1
        self._render_to_screen(output)
        return True

    def _render_to_screen(self, output: spy.Texture) -> None:
        image = self.surface.acquire_next_image()
        if image is None:
            return

        if (
            self._blit_texture is None
            or self._blit_texture.width != image.width
            or self._blit_texture.height != image.height
        ):
            self._blit_texture = self.device.create_texture(
                format=spy.Format.rgba32_float,
                width=image.width,
                height=image.height,
                mip_count=1,
                usage=spy.TextureUsage.shader_resource | spy.TextureUsage.unordered_access,
                label="utracer_blit_texture",
            )

        self.scene.module.resample_rgb.dispatch(
            thread_count=uint3(image.width, image.height, 1),
            input=output,
            input_sampler=self.scene._sampler,
            output=self._blit_texture,
            output_pos=uint2(0),
            output_size=uint2(image.width, image.height),
            scale=1.0,
            set_abs=False,
            tone_map=True,
        )

        cmd = self.device.create_command_encoder()
        cmd.blit(image, self._blit_texture)
        cmd.set_texture_state(image, spy.ResourceState.present)
        self.device.submit_command_buffer(cmd.finish())
        del image
        self.surface.present()

    def _on_keyboard_event(self, event: spy.KeyboardEvent) -> None:
        if event.type == spy.KeyboardEventType.key_press:
            if event.key == spy.KeyCode.escape:
                self.window.close()

    def _on_mouse_event(self, event: spy.MouseEvent) -> None:
        if event.is_button_down() and event.button == spy.MouseButton.left:
            self._is_dragging = True
            self._drag_start_pos = self._last_mouse_pos
            self._camera_start_pos = self.camera.pos
            self.camera.reset_accumulator(self.scene.module)
        elif event.is_button_up() and event.button == spy.MouseButton.left and self._is_dragging:
            self._is_dragging = False
            self.camera.reset_accumulator(self.scene.module)
        elif event.is_move():
            self._last_mouse_pos = event.pos

        if self._is_dragging:
            self._update_camera_rotation(self._last_mouse_pos)

        if event.is_scroll():
            self._update_camera_zoom(event.scroll.y)

    def _update_camera_rotation(self, current_mouse_pos: spy.float2) -> None:
        mouse_delta = spy.float2(
            current_mouse_pos.x - self._drag_start_pos.x,
            current_mouse_pos.y - self._drag_start_pos.y,
        )
        sensitivity = 0.005
        yaw_delta = -mouse_delta.x * sensitivity
        pitch_delta = -mouse_delta.y * sensitivity
        orig_to_origin = -self._camera_start_pos
        orig_distance = spy.math.length(orig_to_origin)
        orig_forward = normalize(orig_to_origin)
        orig_yaw = spy.math.atan2(orig_forward.x, orig_forward.z)
        orig_pitch = spy.math.asin(orig_forward.y)
        new_yaw = orig_yaw + yaw_delta
        new_pitch = max(-1.5, min(1.5, orig_pitch + pitch_delta))
        new_forward = float3(
            spy.math.cos(new_pitch) * spy.math.sin(new_yaw),
            spy.math.sin(new_pitch),
            spy.math.cos(new_pitch) * spy.math.cos(new_yaw),
        )
        self.camera.pos = -orig_distance * new_forward
        self.camera.rot = quat_from_look_at(-normalize(self.camera.pos), float3(0, 1, 0))
        self.camera.recompute()
        self.camera.reset_accumulator(self.scene.module)

    def _update_camera_zoom(self, wheel_delta: float) -> None:
        zoom_sensitivity = 0.1
        zoom_factor = 1.0 + (wheel_delta * zoom_sensitivity)
        current_distance = spy.math.length(self.camera.pos)
        new_distance = max(0.1, min(100.0, current_distance / zoom_factor))
        direction = normalize(self.camera.pos)
        self.camera.pos = direction * new_distance
        self.camera.recompute()
        self.camera.reset_accumulator(self.scene.module)

    def _on_resize(self, width: int, height: int) -> None:
        self.device.wait()
        self.surface.configure(width=max(width, 1), height=max(height, 1))

def save_image(image: Union[Tensor, spy.Texture], path: Union[str, PathLike[str]]) -> None:
    """
    Save an image to a file. Supports PNG, JPEG, BMP, EXR, HDR.
    Accepts a Tensor (H,W float4 or H,W,C float) or a Texture.
    """
    path = Path(path)
    data = image.to_numpy()

    if len(data.shape) == 2:
        data = data[:, :, np.newaxis]
        pixel_format = Bitmap.PixelFormat.y

    if len(data.shape) == 3:
        channels = data.shape[2]
        if channels == 1:
            pixel_format = Bitmap.PixelFormat.y
        elif channels == 2:
            pixel_format = Bitmap.PixelFormat.ya
        elif channels == 3:
            pixel_format = Bitmap.PixelFormat.rgb
        elif channels == 4:
            pixel_format = Bitmap.PixelFormat.rgba
        else:
            raise ValueError(f"Unsupported channel count: {channels}")
    else:
        raise ValueError(f"Unsupported tensor shape: {data.shape}")

    data = data.astype(np.float32)

    # For non-HDR formats, convert to 8-bit
    if path.suffix not in (".exr", ".hdr"):
        data = np.clip(data * 255.0, 0, 255).astype(np.uint8)

    bitmap = Bitmap(data=data, pixel_format=pixel_format)
    bitmap.write(path)

def _compute_tangents(
    positions: np.ndarray,
    normals: np.ndarray,
    uvs: np.ndarray,
    faces: np.ndarray,
    tangents: np.ndarray,
    bitangents: np.ndarray,
) -> None:
    """Compute tangent and bitangent vectors using MikkTSpace-style approach."""
    tan1 = np.zeros_like(positions)
    tan2 = np.zeros_like(positions)

    for tri in faces:
        i0, i1, i2 = tri
        p0, p1, p2 = positions[i0], positions[i1], positions[i2]
        uv0, uv1, uv2 = uvs[i0], uvs[i1], uvs[i2]

        dp1 = p1 - p0
        dp2 = p2 - p0
        duv1 = uv1 - uv0
        duv2 = uv2 - uv0

        denom = duv1[0] * duv2[1] - duv2[0] * duv1[1]
        if abs(denom) < 1e-8:
            continue

        r = 1.0 / denom
        sdir = (duv2[1] * dp1 - duv1[1] * dp2) * r
        tdir = (duv1[0] * dp2 - duv2[0] * dp1) * r

        tan1[i0] += sdir
        tan1[i1] += sdir
        tan1[i2] += sdir
        tan2[i0] += tdir
        tan2[i1] += tdir
        tan2[i2] += tdir

    for i in range(len(positions)):
        n = normals[i]
        t = tan1[i]

        # Gram-Schmidt orthogonalize
        t_orth = t - n * np.dot(n, t)
        length = np.linalg.norm(t_orth)
        if length > 1e-8:
            tangents[i] = t_orth / length
        else:
            # Fallback: generate an arbitrary tangent
            if abs(n[0]) < 0.9:
                tangents[i] = np.cross(n, [1, 0, 0])
            else:
                tangents[i] = np.cross(n, [0, 1, 0])
            length = np.linalg.norm(tangents[i])
            if length > 1e-8:
                tangents[i] /= length

        bitangents[i] = np.cross(n, tangents[i])
        length = np.linalg.norm(bitangents[i])
        if length > 1e-8:
            bitangents[i] /= length
