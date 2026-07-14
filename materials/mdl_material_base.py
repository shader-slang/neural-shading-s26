import slangpy as spy
import numpy as np
from pathlib import Path


class MDLMaterialBase:
    def __init__(self, device: spy.Device):
        self.device = device
        self.texture_paths = []
        self.buffer_path = ""
        self.arg_block_offset = 0
        self.surface_scatter_bsdf_count = 0
        self.material_data_name = ""
        self.loaded = False

    def load_data(self):
        if self.loaded:
            return
        self.loaded = True
        buffer_data = np.fromfile(self.buffer_path, dtype=np.float32)
        self.buffer = self.device.create_buffer(
            size=buffer_data.nbytes,
            usage=spy.BufferUsage.shader_resource | spy.BufferUsage.unordered_access,
            data=buffer_data,
        )

        texture_loader = spy.TextureLoader(self.device)
        self.textures: list[spy.Texture] = []
        for texture_info in self.texture_paths:
            texture = texture_loader.load_texture(
                path=texture_info["name"],
                options = {
                    'load_as_srgb': texture_info["srgb"],
                }
            )
            self.textures.append(texture)

        # Resize to 32 textures, as that's the maximum number of textures we can bind to the shader.
        self.textures.extend([self.textures[-1]] * (32 - len(self.textures)))

        self.sampler = self.device.create_sampler()

    def to_global_uniforms(self):
        self.load_data()
        return {
            self.material_data_name: {
                "data": self.buffer,
                "textures_2d": self.textures,
                "sampler_state": self.sampler,
                "arg_block_offset": self.arg_block_offset,
                "surface_scatter_bsdf_count": self.surface_scatter_bsdf_count,
            }
        }