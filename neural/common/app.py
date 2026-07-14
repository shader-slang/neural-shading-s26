# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

import sys
from pathlib import Path
from typing import Callable, Optional

import slangpy as spy


WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
if str(WORKSPACE_ROOT) not in sys.path:
    sys.path.insert(0, str(WORKSPACE_ROOT))


def _unique_paths(paths: list[Path]) -> list[Path]:
    result: list[Path] = []
    seen: set[Path] = set()
    for path in paths:
        resolved = path.resolve()
        if resolved not in seen:
            result.append(resolved)
            seen.add(resolved)
    return result


class App:
    def __init__(
        self,
        title: str,
        width: int,
        height: int,
        device_type: spy.DeviceType = spy.DeviceType.automatic,
        shader_paths: Optional[list[Path]] = None,
    ):
        self._window = spy.Window(width=width, height=height, title=title, resizable=False)

        bindless_options = spy.BindlessDesc(
            buffer_count=16*1024,
            texture_count=16*1024,
            sampler_count=128,
        )

        include_paths = _unique_paths(
            [
                *(shader_paths or []),
                Path(__file__).parent,
                WORKSPACE_ROOT,
            ]
        )

        self._device = spy.create_device(
            device_type,
            enable_debug_layers=True,
            include_paths=include_paths,
            bindless_options=bindless_options,
        )
        self._module = spy.Module.load_from_file(self._device, str(Path(__file__).parent / "app.slang"))

        self.surface = self._device.create_surface(self._window)
        self.surface.configure(width=self._window.width, height=self._window.height)

        self._output_texture: spy.Texture = self._create_output_texture(width, height)
        self._mouse_pos = spy.float2()

        self._window.on_keyboard_event = self._on_window_keyboard_event
        self._window.on_mouse_event = self._on_window_mouse_event
        self._window.on_resize = self._on_window_resize

        self.on_keyboard_event: Optional[Callable[[spy.KeyboardEvent], None]] = None
        self.on_mouse_event: Optional[Callable[[spy.MouseEvent], None]] = None

    @property
    def device(self) -> spy.Device:
        return self._device

    @property
    def window(self) -> spy.Window:
        return self._window

    @property
    def mouse_pos(self) -> spy.float2:
        return self._mouse_pos

    @property
    def output(self) -> spy.Texture:
        return self._output_texture

    def process_events(self) -> bool:
        if self._window.should_close():
            return False
        self._window.process_events()
        return True

    def present(self) -> None:
        if not self.surface.config:
            return

        image = self.surface.acquire_next_image()
        if not image:
            return

        if self._output_texture is None or self._output_texture.width != image.width or self._output_texture.height != image.height:
            self._output_texture = self._create_output_texture(image.width, image.height)

        command_encoder = self._device.create_command_encoder()
        command_encoder.blit(image, self._output_texture)
        command_encoder.set_texture_state(image, spy.ResourceState.present)
        self._device.submit_command_buffer(command_encoder.finish())

        del image
        self.surface.present()

    def blit(
        self,
        source: spy.Tensor,
        size: Optional[spy.int2] = None,
        offset: Optional[spy.int2] = None,
        tonemap: bool = False,
        bilinear: bool = False,
    ) -> None:
        if len(source.shape) != 2:
            raise ValueError("Source tensor must be 2D (height, width).")
        if size is None:
            size = spy.int2(source.shape[1], source.shape[0])
        if offset is None:
            offset = spy.int2(0, 0)

        self._module.blit(
            spy.grid((size.y, size.x)),
            size,
            offset,
            tonemap,
            bilinear,
            source,
            self.output,
        )

    def clear(self, color: spy.float4 = spy.float4(0.0, 0.0, 0.0, 1.0)) -> None:
        self._module.clear(
            spy.grid((self.output.height, self.output.width)),
            color,
            self.output,
        )

    def _create_output_texture(self, width: int, height: int) -> spy.Texture:
        return self.device.create_texture(
            format=spy.Format.rgba16_float,
            width=width,
            height=height,
            mip_count=1,
            usage=spy.TextureUsage.shader_resource | spy.TextureUsage.unordered_access,
            label="output_texture",
        )

    def _on_window_keyboard_event(self, event: spy.KeyboardEvent) -> None:
        if event.type == spy.KeyboardEventType.key_press:
            if event.key == spy.KeyCode.escape:
                self._window.close()
                return
            if event.key == spy.KeyCode.f1:
                spy.tev.show_async(self._output_texture)
                return
            if event.key == spy.KeyCode.f2:
                bitmap = self._output_texture.to_bitmap()
                bitmap.convert(
                    spy.Bitmap.PixelFormat.rgb,
                    spy.Bitmap.ComponentType.uint8,
                    srgb_gamma=True,
                ).write_async("screenshot.png")
                return

        if self.on_keyboard_event:
            self.on_keyboard_event(event)

    def _on_window_mouse_event(self, event: spy.MouseEvent) -> None:
        if event.type == spy.MouseEventType.move:
            self._mouse_pos = event.pos
        if self.on_mouse_event:
            self.on_mouse_event(event)

    def _on_window_resize(self, width: int, height: int) -> None:
        self._device.wait()
        if width > 0 and height > 0:
            self.surface.configure(width=width, height=height)
        else:
            self.surface.unconfigure()
