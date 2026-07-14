# SPDX-License-Identifier: Apache-2.0

import math
import datetime
import json

from app import App
import slangpy as spy
import numpy as np
from pathlib import Path
from PIL import Image

from linear_layer import LinearLayer, USE_COOPVEC_LINEAR, preferred_device_type, validate_device
from materials.ceramic.mdl_ceramic_material import CeramicMaterial


NUM_LATENTS = 8


def cosine_falloff(iteration: int, max_iterations: int, start: float = 1.0, end: float = 0.0) -> float:
    """Smooth cosine annealing from `start` to `end` over `max_iterations`."""
    if iteration >= max_iterations:
        return end
    alpha = 0.5 * (1 + math.cos(iteration * math.pi / max_iterations))
    return end + alpha * (start - end)

# Create the app and load the slang module.
app = App(width=1024*2 + 1024, height=1024, title="MDL Material Example", device_type=preferred_device_type())
validate_device(app.device)
module = spy.Module.load_from_file(app.device, "step_02_latent_texture.slang")
mat = CeramicMaterial(app.device)

loader = spy.TextureLoader(app.device)
envmap = loader.load_texture( Path(__file__).parent.parent / "data/brown_photostudio_02_2k.hdr")
sampler = app.device.create_sampler()


class LatentTexture(spy.InstanceList):
    def __init__(self, width: int, height: int, num_latents: int):
        super().__init__(module[f"LatentTexture<{num_latents}>"])
        self.width = width
        self.height = height
        self.num_latents = num_latents
        
        # Initialize to random latent texture. Keep this float32 while we rely on
        # atomic gradient accumulation.
        initial_latents = np.random.uniform(0.0, 1.0, (height, width, num_latents)).astype("float32")
        self.texture = spy.Tensor.from_numpy(app.device, initial_latents)

        # Gradients for the latent texture
        self.texture_grads = spy.Tensor.zeros_like(self.texture)

        # Temp data for Adam optimizer (kept fp32 for numerical stability).
        self.m_texture = spy.Tensor.from_numpy(app.device, np.zeros((height, width, num_latents), dtype="float32"))
        self.v_texture = spy.Tensor.from_numpy(app.device, np.zeros((height, width, num_latents), dtype="float32"))

    # Calls the Slang 'optimize' function for biases and weights
    def optimize(self, learning_rate: float, optimize_counter: int):
        module.latent_optimizer_kernel.dispatch(
            thread_count=(self.num_latents, self.width, self.height),
            latent_texture=spy.slangpy.unpack_arg(self),
            means=self.m_texture.uniforms(),
            variances=self.v_texture.uniforms(),
            learning_rate=learning_rate,
            iteration=optimize_counter,
        )


class Network(spy.InstanceList):
    def __init__(self):
        super().__init__(module["Network"])
        self.latent_texture = LatentTexture(4096, 4096, NUM_LATENTS)
        # NA decoder config: hidden_layers=[32, 32], then a separate RGB output layer.
        self.layer0 = LinearLayer(app.device, module, self.latent_texture.num_latents+6, 32)
        self.layer1 = LinearLayer(app.device, module, 32, 32)
        self.layer2 = LinearLayer(app.device, module, 32, 3)

    # Calls the Slang 'optimize' function for the layer.
    def optimize(self, learning_rate: float, optimize_counter: int):
        self.latent_texture.optimize(learning_rate, optimize_counter)
        self.layer0.optimize(learning_rate, optimize_counter)
        self.layer1.optimize(learning_rate, optimize_counter)
        self.layer2.optimize(learning_rate, optimize_counter)

network = Network()

# ── Checkpoint helpers ────────────────────────────────────────────────────────
run_dir = Path(__file__).parent / "runs" / datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
run_dir.mkdir(parents=True, exist_ok=True)
checkpoint_interval = 16*1024
print(f"Run directory: {run_dir}")


def _float3_to_png(tensor: spy.Tensor, path: Path, tonemap: bool = True) -> None:
    """Convert a float3 tensor to a tonemapped (or raw-clamped) uint8 PNG."""
    data = tensor.to_numpy()  # shape (H, W, 3), float32
    if tonemap:
        data = np.clip(data ** (1.0 / 2.2), 0.0, 1.0)
    else:
        data = np.clip(data, 0.0, 1.0)
    Image.fromarray((data * 255).astype(np.uint8)).save(path)


def save_checkpoint(iter: int) -> None:
    """Save network weights and rendered images for iteration *iter*."""
    ckpt_dir = run_dir / f"{iter:07d}"
    ckpt_dir.mkdir(exist_ok=True)

    np.savez(
        ckpt_dir / "network.npz",
        latent_texture=network.latent_texture.texture.to_numpy(),
        **network.layer0.save("layer0"),
        **network.layer1.save("layer1"),
        **network.layer2.save("layer2"),
    )

    _save_train_config(ckpt_dir, iter)

    # ── Renders ──────────────────────────────────────────────────────────────
    _float3_to_png(output,        ckpt_dir / "render_reference.png", tonemap=True)
    _float3_to_png(output_neural, ckpt_dir / "render_neural.png",    tonemap=True)

    # ── Latent channels (raw float values, red=negative / green=positive) ───
    latents = network.latent_texture.texture.to_numpy()  # (H, W, NUM_LATENTS)
    for ch in range(latents.shape[2]):
        ch_data = latents[:, :, ch]
        rgb = np.zeros((*ch_data.shape, 3), dtype=np.float32)
        rgb[:, :, 0] = np.clip(-ch_data, 0.0, None)  # red   = negative part
        rgb[:, :, 1] = np.clip( ch_data, 0.0, None)  # green = positive part
        Image.fromarray((np.clip(rgb, 0.0, 1.0) * 255).astype(np.uint8)).save(
            ckpt_dir / f"latent_{ch}.png"
        )

    print(f"[iter {iter:7d}] checkpoint saved → {ckpt_dir}")


def _save_train_config(ckpt_dir: Path, iter: int) -> None:
    config = {
        "optimize_counter": iter,
        "lr_max": lr_max,
        "lr_min": lr_min,
        "lr_total_iters": lr_total_iters,
        "color_aug_enabled": color_aug_enabled,
        "color_aug_iters": color_aug_iters,
        "color_aug_start": color_aug_start,
        "color_aug_end": color_aug_end,
        "use_coopvec_linear": USE_COOPVEC_LINEAR,
        "num_latents": NUM_LATENTS,
        "metric_log_interval": metric_log_interval,
        "validation_seed": validation_seed,
        "validation_batch_size": validation_batch_size,
    }
    with open(ckpt_dir / "train_config.json", "w") as f:
        json.dump(config, f, indent=2)


def load_checkpoint(path: str | Path) -> None:
    """Restore network weights and training state from a checkpoint directory or .npz file.
    
    Pass either the directory written by save_checkpoint, or the network.npz inside it.
    The optimize_counter and LR schedule parameters are restored from train_config.json
    when it is present alongside the .npz.
    """
    global optimize_counter, lr_max, lr_min, lr_total_iters
    global color_aug_enabled, color_aug_iters, color_aug_start, color_aug_end
    path = Path(path)
    npz_path = path if path.suffix == ".npz" else path / "network.npz"
    ckpt_dir = npz_path.parent

    data = np.load(npz_path)
    network.latent_texture.texture = spy.Tensor.from_numpy(app.device, data["latent_texture"].astype("float32"))
    network.layer0.load(data, "layer0")
    network.layer1.load(data, "layer1")
    network.layer2.load(data, "layer2")

    # Re-zero all gradient / Adam state tensors after loading
    lt = network.latent_texture
    network.latent_texture.texture_grads = spy.Tensor.zeros_like(lt.texture)
    network.latent_texture.m_texture     = spy.Tensor.from_numpy(app.device, np.zeros((lt.height, lt.width, lt.num_latents), dtype="float32"))
    network.latent_texture.v_texture     = spy.Tensor.from_numpy(app.device, np.zeros((lt.height, lt.width, lt.num_latents), dtype="float32"))
    print(f"Loaded checkpoint: {path}")

    config_path = ckpt_dir / "train_config.json"
    if config_path.exists():
        with open(config_path) as f:
            config = json.load(f)
        optimize_counter  = config["optimize_counter"]
        lr_max            = config["lr_max"]
        lr_min            = config["lr_min"]
        lr_total_iters    = config["lr_total_iters"]
        color_aug_enabled = config.get("color_aug_enabled", color_aug_enabled)
        color_aug_iters   = config.get("color_aug_iters",   color_aug_iters)
        color_aug_start   = config.get("color_aug_start",   color_aug_start)
        color_aug_end     = config.get("color_aug_end",     color_aug_end)
        print(f"  Restored training state: iter={optimize_counter}, lr_max={lr_max}, "
              f"lr_min={lr_min}, lr_total_iters={lr_total_iters}, "
              f"color_aug={color_aug_enabled} ({color_aug_start:.1f}→{color_aug_end:.1f} over {color_aug_iters})")

    else:
        print(f"  No train_config.json found — optimize_counter and LR schedule unchanged.")

# ─────────────────────────────────────────────────────────────────────────────

optimize_counter = 0
metric_log_interval = 64
batch_size = (64, 64)
validation_seed = 0x5EED
validation_batch_size = (512, 512)

# Cosine annealing schedule: lr decays from lr_max -> lr_min over lr_total_iters
lr_max = 0.001
lr_min = 0.00001
lr_total_iters = 100_000

# Color channel augmentation with cosine annealing.
# Augmentation ratio anneals from start_ratio -> end_ratio over num_iterations,
# preventing the network from prioritising luminance over chrominance.
color_aug_enabled = True
color_aug_iters   = 10_000
color_aug_start   = 1.0
color_aug_end     = 0.0

metric_log_l1_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_rel_l1_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_mse_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_valid_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")

# Allocate a tensor for output
accumulator = spy.Tensor.empty(app.device, (1024,1024), "float4")
output = spy.Tensor.zeros(app.device, (1024,1024), "float3")
accumulator_neural = spy.Tensor.empty(app.device, (1024,1024), "float4")
output_neural = spy.Tensor.zeros(app.device, (1024,1024), "float3")
counter = 0

accumulate = False


def kb_event(e: spy.KeyboardEvent):
    global accumulate
    if e.is_key_press() and e.key == spy.KeyCode.space:
        accumulate = not accumulate
    if e.is_key_press() and e.key == spy.KeyCode.r:
        accumulator.clear()
        accumulator_neural.clear()

app.on_keyboard_event = kb_event

latent_output = spy.Tensor.empty(app.device, (512, 512), dtype=spy.float3)

load_checkpoint(r"C:\sw\neural-shading-s26\train\runs\20260506_122155\0065536")


def log_validation_metrics(globals: dict, learning_rate: float) -> None:
    module.compute_error_batch.set(globals)(
        seed=validation_seed,
        batch_index=spy.grid(validation_batch_size),
        batch_size=spy.int2(validation_batch_size),
        log_l1_out=metric_log_l1_buffer,
        rel_l1_out=metric_rel_l1_buffer,
        mse_out=metric_mse_buffer,
        valid_out=metric_valid_buffer,
    )

    valid = metric_valid_buffer.to_numpy()
    valid_count = max(float(valid.sum()), 1.0)
    log_l1 = float(metric_log_l1_buffer.to_numpy().sum() / valid_count)
    rel_l1 = float(metric_rel_l1_buffer.to_numpy().sum() / valid_count)
    rmse = math.sqrt(float(metric_mse_buffer.to_numpy().sum() / valid_count))

    print(
        f"[iter {optimize_counter:6d}] lr={learning_rate:.2e}  "
        f"metric  log_l1={log_l1:.5f}  rel_l1={rel_l1:.5f}  "
        f"rmse={rmse:.5f}  valid={int(valid_count)}"
    )

while app.process_events():

    # Set up global shader parameters.
    globals = {}
    globals["sampler"] = sampler
    globals["environment_map"] = envmap
    globals["network"] = spy.slangpy.unpack_arg(network)
    globals.update(mat.to_global_uniforms())

    # Full res rendered output BRDF from full res inputs.    
    module.render.set(globals)(
        pixel=spy.call_id(),
        accumulator=accumulator,
        counter=counter,
        _result=output,
    )
    module.render_neural.set(globals)(
        pixel=spy.call_id(),
        accumulator=accumulator_neural,
        counter=counter,
        _result=output_neural,
    )    

    counter += 1

    for i in range(0,16):
        t = min(optimize_counter, lr_total_iters)
        learning_rate = lr_min + 0.5 * (lr_max - lr_min) * (1.0 + math.cos(math.pi * t / lr_total_iters))
        color_aug_ratio = (
            cosine_falloff(optimize_counter, color_aug_iters, color_aug_start, color_aug_end)
            if color_aug_enabled else 0.0
        )
        module.calculate_grads.set(globals)(
            seed=optimize_counter,
            batch_index=spy.grid(batch_size),
            batch_size=spy.int2(batch_size),
            color_augmentation_ratio=color_aug_ratio,
        )
        optimize_counter += 1
        network.optimize(learning_rate, optimize_counter)
        module.device.wait_for_idle()

        if optimize_counter % metric_log_interval == 0:
            log_validation_metrics(globals, learning_rate)

        if optimize_counter % checkpoint_interval == 0:
            save_checkpoint(optimize_counter)

    # Blit tensor to screen.
    app.blit(output)
    app.blit(output_neural, offset=spy.int2(1024, 0))

    # Render latent texture channels as red/green squares
    latent_x = 1024 * 2
    latent_y = 0
    col = 0
    latent_res = spy.int2(512, 512)
    for ch in range(NUM_LATENTS):
        module.render_latent.set(globals)(
            pixel=spy.call_id(), resolution=latent_res, channel=ch, _result=latent_output
        )
        app.blit(latent_output, size=spy.int2(330, 330), offset=spy.int2(latent_x, latent_y), tonemap=False, bilinear=False)
        latent_x += 340
        col += 1
        if col >= 3:
            latent_x = 1024 * 2
            latent_y += 340
            col = 0

    # Present the window.
    app.present()
    module.device.wait_for_idle()

    if not accumulate:
        accumulator.clear()
        accumulator_neural.clear()
