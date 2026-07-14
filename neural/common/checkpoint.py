# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

import datetime
import json
from pathlib import Path
from typing import Any, Mapping

import numpy as np

from neural.common.image_io import save_float3_png, save_latent_channel_png


def create_run_dir(example_dir: Path) -> Path:
    run_dir = example_dir / "runs" / datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "checkpoints").mkdir(exist_ok=True)
    (run_dir / "previews").mkdir(exist_ok=True)
    return run_dir


def resolve_checkpoint(path: str | Path) -> Path:
    path = Path(path)
    if path.is_dir():
        candidate = path / "network.npz"
        if candidate.is_file():
            return candidate
        raise FileNotFoundError(f"No network.npz found in {path}")
    if path.is_file() and path.suffix == ".npz":
        return path
    raise FileNotFoundError(f"Checkpoint not found: {path}")


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)


def load_json(path: Path) -> dict[str, Any]:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_checkpoint(
    run_dir: Path,
    iteration: int,
    network,
    outputs: Mapping[str, Any],
    latent_preview: Any | None = None,
    latent_preview_size: int = 512,
) -> Path:
    checkpoint_dir = run_dir / "checkpoints" / f"{iteration:07d}"
    preview_dir = run_dir / "previews" / f"{iteration:07d}"
    checkpoint_dir.mkdir(parents=True, exist_ok=True)
    preview_dir.mkdir(parents=True, exist_ok=True)

    np.savez(checkpoint_dir / "network.npz", **network.save())
    save_json(checkpoint_dir / "config.json", {"iteration": iteration})

    for name, output in outputs.items():
        save_float3_png(output, preview_dir / f"{name}.png")

    latents = latent_preview
    if latents is None and hasattr(network, "latent_texture"):
        latents = network.latent_texture.values.to_numpy()
    if hasattr(latents, "to_numpy"):
        latents = latents.to_numpy()
    if latents is not None:
        for channel in range(latents.shape[2]):
            save_latent_channel_png(
                latents,
                channel,
                preview_dir / f"latent_{channel:02d}.png",
                latent_preview_size,
            )

    return checkpoint_dir


def load_checkpoint(network, path: str | Path) -> int:
    npz_path = resolve_checkpoint(path)
    with np.load(npz_path) as npz:
        network.load({name: npz[name] for name in npz.files})

    config_path = npz_path.parent / "config.json"
    iteration = 0
    if config_path.exists():
        iteration = int(load_json(config_path).get("iteration", 0))

    print(f"Loaded checkpoint: {npz_path}")
    return iteration
