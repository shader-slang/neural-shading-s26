
from __future__ import annotations

from pathlib import Path

import numpy as np
import slangpy as spy
from PIL import Image


def _tonemap_aces_film(data: np.ndarray) -> np.ndarray:
    x = np.clip(data, 0.0, None)
    a = 2.51
    b = 0.03
    c = 2.43
    d = 0.59
    e = 0.14
    return np.clip((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0)


def _linear_to_srgb(data: np.ndarray) -> np.ndarray:
    data = np.clip(data, 0.0, 1.0)
    return np.where(data <= 0.0031308, data * 12.92, 1.055 * np.power(data, 1.0 / 2.4) - 0.055)


def _save_png(path: Path, linear_rgb: np.ndarray) -> None:
    srgb = _linear_to_srgb(linear_rgb)
    Image.fromarray((srgb * 255.0 + 0.5).astype(np.uint8)).save(path)


def save_float3_png(tensor: spy.Tensor, path: Path, tonemap: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = tensor.to_numpy()
    if tonemap:
        data = _tonemap_aces_film(data)
    else:
        data = np.clip(data, 0.0, 1.0)
    _save_png(path, data)


def save_latent_channel_png(latents: np.ndarray, channel: int, path: Path, preview_size: int = 512) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    channel_data = latents[:, :, channel]
    if channel_data.shape[0] != preview_size or channel_data.shape[1] != preview_size:
        ys = np.linspace(0, channel_data.shape[0] - 1, preview_size).astype(np.int32)
        xs = np.linspace(0, channel_data.shape[1] - 1, preview_size).astype(np.int32)
        channel_data = channel_data[ys[:, None], xs[None, :]]

    rgb = np.zeros((*channel_data.shape, 3), dtype=np.float32)
    rgb[:, :, 0] = np.clip(-channel_data, 0.0, None)
    rgb[:, :, 1] = np.clip(channel_data, 0.0, None)
    _save_png(path, np.clip(rgb, 0.0, 1.0))
