# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

from collections.abc import Mapping

import numpy as np
import slangpy as spy


LATENT_TEXTURE_NUM_LATENTS = 8


class LatentTexture(spy.InstanceList):
    def __init__(
        self,
        device: spy.Device,
        module: spy.Module,
        width: int,
        height: int,
        num_latents: int = LATENT_TEXTURE_NUM_LATENTS,
        random_seed: int = 1,
        initial_scale: float = 0.01,
    ):
        if num_latents != LATENT_TEXTURE_NUM_LATENTS:
            raise ValueError(f"LatentTexture uses {LATENT_TEXTURE_NUM_LATENTS} channels, got {num_latents}.")

        super().__init__(module[f"LatentTexture<{num_latents}>"])
        self.device = device
        self.module = module
        self.width = width
        self.height = height
        self.num_latents = num_latents

        rng = np.random.default_rng(random_seed)
        values = rng.uniform(-initial_scale, initial_scale, (height, width, num_latents)).astype(np.float32)
        self.values = spy.Tensor.from_numpy(device, values)
        self.reset_optimizer_state()

    def reset_optimizer_state(self) -> None:
        self.gradients = spy.Tensor.zeros_like(self.values)
        self.means = spy.Tensor.zeros(self.device, (self.height, self.width, self.num_latents), dtype="float")
        self.variances = spy.Tensor.zeros(self.device, (self.height, self.width, self.num_latents), dtype="float")

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.module.latent_texture_optimizer_kernel.dispatch(
            thread_count=(self.num_latents, self.width, self.height),
            latent_texture=spy.slangpy.unpack_arg(self),
            means=self.means.uniforms(),
            variances=self.variances.uniforms(),
            learning_rate=learning_rate,
            iteration=iteration,
        )

    def save(self) -> dict[str, np.ndarray]:
        return {"latent_texture": self.values.to_numpy()}

    def load(self, data: Mapping[str, np.ndarray]) -> None:
        values = data["latent_texture"].astype(np.float32)
        if values.ndim != 3 or values.shape[2] != self.num_latents:
            raise ValueError(f"Expected latent texture shape HxWx{self.num_latents}, got {values.shape}")
        self.height, self.width, _ = values.shape
        self.values = spy.Tensor.from_numpy(self.device, values)
        self.reset_optimizer_state()
