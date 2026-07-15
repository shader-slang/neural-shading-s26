# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

from os import PathLike
from pathlib import Path
from typing import Mapping

import numpy as np
import slangpy as spy

from neural.common.linear_layer import LinearLayer


NUM_LATENTS = 8
DECODER_HIDDEN = 32


class NeuralDecoder(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["NeuralDecoder"])
        self.layer0 = LinearLayer(device, module, NUM_LATENTS + 6, DECODER_HIDDEN)
        self.layer1 = LinearLayer(device, module, DECODER_HIDDEN, DECODER_HIDDEN)
        self.layer2 = LinearLayer(device, module, DECODER_HIDDEN, 3)

    def load(self, data: Mapping[str, np.ndarray], prefixes: list[str]) -> None:
        self.layer0.load(data, prefixes[0])
        self.layer1.load(data, prefixes[1])
        self.layer2.load(data, prefixes[2])


class NeuralLatentTexture(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module, resolution: int = 1):
        super().__init__(module["NeuralLatentTexture"])
        self.device = device
        self.resolution = resolution
        self.texture = spy.Tensor.zeros(device, (resolution, resolution, NUM_LATENTS), dtype="float")

    def load(self, latents: np.ndarray) -> None:
        latents = np.asarray(latents, dtype=np.float32)
        if latents.ndim != 3 or latents.shape[2] != NUM_LATENTS:
            raise ValueError(f"Expected latent texture shape HxWx{NUM_LATENTS}, got {latents.shape}")
        self.resolution = int(latents.shape[0])
        self.texture = spy.Tensor.from_numpy(self.device, latents)


class BakedNeuralMaterial(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module, latent_resolution: int = 1):
        super().__init__(module["BakedNeuralMaterial"])
        self.latent_texture = NeuralLatentTexture(device, module, latent_resolution)
        self.decoder = NeuralDecoder(device, module)


def load_baked_neural_material(
    device: spy.Device,
    module: spy.Module,
    checkpoint: str | PathLike[str],
) -> BakedNeuralMaterial:
    """Load a checkpoint that already contains baked latents."""
    npz_path = _resolve_checkpoint_npz(checkpoint)
    data = _load_npz(npz_path)

    if "latent_texture" not in data:
        raise KeyError(
            "Checkpoint does not contain 'latent_texture'. "
            "Save a new training checkpoint so the encoder bake runs during checkpoint saving."
        )

    material = BakedNeuralMaterial(device, module, int(data["latent_texture"].shape[0]))
    material.decoder.load(data, _decoder_prefixes(data))
    material.latent_texture.load(data["latent_texture"])
    return material


def _resolve_checkpoint_npz(checkpoint: str | PathLike[str]) -> Path:
    path = Path(checkpoint)
    if path.is_dir():
        for filename in ("network.npz", "neural_shader.npz"):
            candidate = path / filename
            if candidate.is_file():
                return candidate
        raise FileNotFoundError(f"No network.npz or neural_shader.npz found in {path}")

    if path.is_file() and path.suffix == ".npz":
        return path

    raise FileNotFoundError(f"Neural checkpoint not found: {path}")


def _load_npz(path: Path) -> dict[str, np.ndarray]:
    with np.load(path) as npz:
        return {name: npz[name] for name in npz.files}


def _has_layer_set(data: Mapping[str, np.ndarray], prefixes: list[str]) -> bool:
    return all(f"{prefix}_biases" in data and f"{prefix}_weights" in data for prefix in prefixes)


def _decoder_prefixes(data: Mapping[str, np.ndarray]) -> list[str]:
    candidates = [
        ["decoder_layer0", "decoder_layer1", "decoder_layer2"],
        ["decoder_d0", "decoder_d1", "decoder_d2"],
        ["layer0", "layer1", "layer2"],
    ]
    for prefixes in candidates:
        if _has_layer_set(data, prefixes):
            return prefixes
    raise KeyError("Checkpoint does not contain a recognized decoder.")
