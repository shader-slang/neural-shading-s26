# SPDX-License-Identifier: Apache-2.0

import datetime
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image
import slangpy as spy

from app import App
from linear_layer import LinearLayer, USE_COOPVEC_LINEAR, preferred_device_type, validate_device
from materials.ceramic.mdl_ceramic_material import CeramicMaterial


NUM_LATENTS = 8
ENCODER_INPUTS = 29
ENCODER_HIDDEN = 64
DECODER_HIDDEN = 32
LATENT_RESOLUTION = 4096
LATENT_PREVIEW_RESOLUTION = 512
ENCODER_HIDDEN_ACTIVATION = "LeakyReLU"
DECODER_HIDDEN_ACTIVATION = "SmeLU"
DECODER_OUTPUT_ACTIVATION = "ScaledSigmoid"
DECODER_OUTPUT_SCALE = 1e5


def cosine_falloff(iteration: int, max_iterations: int, start: float = 1.0, end: float = 0.0) -> float:
    """Smooth cosine annealing from `start` to `end` over `max_iterations`."""
    if iteration >= max_iterations:
        return end
    alpha = 0.5 * (1 + math.cos(iteration * math.pi / max_iterations))
    return end + alpha * (start - end)


def xavier_scale(inputs: int, outputs: int) -> float:
    return math.sqrt(6.0 / (inputs + outputs))


app = App(width=1024 * 2 + 1024, height=1024, title="Neural Activations Example", device_type=preferred_device_type())
validate_device(app.device)
module = spy.Module.load_from_file(app.device, "step_04_activations.slang")
mat = CeramicMaterial(app.device)

loader = spy.TextureLoader(app.device)
envmap = loader.load_texture(Path(__file__).parent.parent / "data/brown_photostudio_02_2k.hdr")
sampler = app.device.create_sampler()


class Encoder(spy.InstanceList):
    def __init__(self):
        super().__init__(module["Encoder"])
        # NA encoder config: hidden_layers=[64, 64, 64], then a latent output layer.
        self.layer0 = LinearLayer(
            app.device, module, ENCODER_INPUTS, ENCODER_HIDDEN, xavier_scale(ENCODER_INPUTS, ENCODER_HIDDEN)
        )
        self.layer1 = LinearLayer(
            app.device, module, ENCODER_HIDDEN, ENCODER_HIDDEN, xavier_scale(ENCODER_HIDDEN, ENCODER_HIDDEN)
        )
        self.layer2 = LinearLayer(
            app.device, module, ENCODER_HIDDEN, ENCODER_HIDDEN, xavier_scale(ENCODER_HIDDEN, ENCODER_HIDDEN)
        )
        self.layer3 = LinearLayer(
            app.device, module, ENCODER_HIDDEN, NUM_LATENTS, xavier_scale(ENCODER_HIDDEN, NUM_LATENTS)
        )

    def optimize(self, learning_rate: float, optimize_counter: int):
        self.layer0.optimize(learning_rate, optimize_counter)
        self.layer1.optimize(learning_rate, optimize_counter)
        self.layer2.optimize(learning_rate, optimize_counter)
        self.layer3.optimize(learning_rate, optimize_counter)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.layer0.save("encoder_layer0"),
            **self.layer1.save("encoder_layer1"),
            **self.layer2.save("encoder_layer2"),
            **self.layer3.save("encoder_layer3"),
        }

    def load(self, data):
        self.layer0.load(data, "encoder_layer0")
        self.layer1.load(data, "encoder_layer1")
        self.layer2.load(data, "encoder_layer2")
        self.layer3.load(data, "encoder_layer3")


class Decoder(spy.InstanceList):
    def __init__(self):
        super().__init__(module["Decoder"])
        # Keep the decoder comparable to step_02: two 32-wide hidden layers plus RGB output.
        self.layer0 = LinearLayer(app.device, module, NUM_LATENTS + 6, DECODER_HIDDEN)
        self.layer1 = LinearLayer(app.device, module, DECODER_HIDDEN, DECODER_HIDDEN)
        self.layer2 = LinearLayer(app.device, module, DECODER_HIDDEN, 3)

    def optimize(self, learning_rate: float, optimize_counter: int):
        self.layer0.optimize(learning_rate, optimize_counter)
        self.layer1.optimize(learning_rate, optimize_counter)
        self.layer2.optimize(learning_rate, optimize_counter)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.layer0.save("decoder_layer0"),
            **self.layer1.save("decoder_layer1"),
            **self.layer2.save("decoder_layer2"),
        }

    def load(self, data):
        self.layer0.load(data, "decoder_layer0")
        self.layer1.load(data, "decoder_layer1")
        self.layer2.load(data, "decoder_layer2")


class Network(spy.InstanceList):
    def __init__(self):
        super().__init__(module["Network"])
        self.encoder = Encoder()
        self.decoder = Decoder()

    def optimize(self, learning_rate: float, optimize_counter: int):
        self.encoder.optimize(learning_rate, optimize_counter)
        self.decoder.optimize(learning_rate, optimize_counter)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.encoder.save(),
            **self.decoder.save(),
        }

    def load(self, data):
        self.encoder.load(data)
        self.decoder.load(data)


network = Network()

run_dir = Path(__file__).parent / "runs" / datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
run_dir.mkdir(parents=True, exist_ok=True)
checkpoint_interval = 16 * 1024
print(f"Run directory: {run_dir}")


def _float3_to_png(tensor: spy.Tensor, path: Path, tonemap: bool = True) -> None:
    data = tensor.to_numpy()
    if tonemap:
        data = np.clip(data ** (1.0 / 2.2), 0.0, 1.0)
    else:
        data = np.clip(data, 0.0, 1.0)
    Image.fromarray((data * 255).astype(np.uint8)).save(path)


def _latent_channel_to_png(latents: np.ndarray, channel: int, path: Path) -> None:
    ch_data = latents[:, :, channel]
    if ch_data.shape[0] != LATENT_PREVIEW_RESOLUTION or ch_data.shape[1] != LATENT_PREVIEW_RESOLUTION:
        ys = np.linspace(0, ch_data.shape[0] - 1, LATENT_PREVIEW_RESOLUTION).astype(np.int32)
        xs = np.linspace(0, ch_data.shape[1] - 1, LATENT_PREVIEW_RESOLUTION).astype(np.int32)
        ch_data = ch_data[ys[:, None], xs[None, :]]

    rgb = np.zeros((*ch_data.shape, 3), dtype=np.float32)
    rgb[:, :, 0] = np.clip(-ch_data, 0.0, None)
    rgb[:, :, 1] = np.clip(ch_data, 0.0, None)
    Image.fromarray((np.clip(rgb, 0.0, 1.0) * 255).astype(np.uint8)).save(path)


def bake_latent_texture() -> np.ndarray:
    latent_texture = spy.Tensor.zeros(
        app.device,
        (LATENT_RESOLUTION, LATENT_RESOLUTION, NUM_LATENTS),
        dtype="float",
    )
    module.bake_latent_texture.set(make_globals()).dispatch(
        thread_count=(LATENT_RESOLUTION, LATENT_RESOLUTION, 1),
        latent_texture=latent_texture,
        resolution=spy.int2(LATENT_RESOLUTION, LATENT_RESOLUTION),
    )
    module.device.wait_for_idle()
    return latent_texture.to_numpy()


def save_checkpoint(iteration: int) -> None:
    ckpt_dir = run_dir / f"{iteration:07d}"
    ckpt_dir.mkdir(exist_ok=True)

    latent_texture = bake_latent_texture()
    np.savez(ckpt_dir / "network.npz", latent_texture=latent_texture, **network.save())
    _save_train_config(ckpt_dir, iteration)

    _float3_to_png(output, ckpt_dir / "render_reference.png", tonemap=True)
    _float3_to_png(output_neural, ckpt_dir / "render_neural.png", tonemap=True)

    for channel in range(NUM_LATENTS):
        _latent_channel_to_png(latent_texture, channel, ckpt_dir / f"latent_{channel}.png")

    print(f"[iter {iteration:7d}] checkpoint saved -> {ckpt_dir}")


def _save_train_config(ckpt_dir: Path, iteration: int) -> None:
    config = {
        "optimize_counter": iteration,
        "lr_max": lr_max,
        "lr_min": lr_min,
        "lr_total_iters": lr_total_iters,
        "color_aug_enabled": color_aug_enabled,
        "color_aug_iters": color_aug_iters,
        "color_aug_start": color_aug_start,
        "color_aug_end": color_aug_end,
        "use_coopvec_linear": USE_COOPVEC_LINEAR,
        "encoder_hidden_layers": [ENCODER_HIDDEN, ENCODER_HIDDEN, ENCODER_HIDDEN],
        "decoder_hidden_layers": [DECODER_HIDDEN, DECODER_HIDDEN],
        "encoder_hidden_activation": ENCODER_HIDDEN_ACTIVATION,
        "decoder_hidden_activation": DECODER_HIDDEN_ACTIVATION,
        "decoder_output_activation": DECODER_OUTPUT_ACTIVATION,
        "decoder_output_scale": DECODER_OUTPUT_SCALE,
        "latent_resolution": LATENT_RESOLUTION,
        "num_latents": NUM_LATENTS,
        "metric_log_interval": metric_log_interval,
        "validation_seed": validation_seed,
        "validation_batch_size": validation_batch_size,
    }
    with open(ckpt_dir / "train_config.json", "w") as f:
        json.dump(config, f, indent=2)


def load_checkpoint(path: str | Path) -> None:
    global optimize_counter, lr_max, lr_min, lr_total_iters
    global color_aug_enabled, color_aug_iters, color_aug_start, color_aug_end
    path = Path(path)
    npz_path = path if path.suffix == ".npz" else path / "network.npz"
    ckpt_dir = npz_path.parent

    network.load(np.load(npz_path))
    print(f"Loaded checkpoint: {path}")

    config_path = ckpt_dir / "train_config.json"
    if config_path.exists():
        with open(config_path) as f:
            config = json.load(f)
        optimize_counter = config["optimize_counter"]
        lr_max = config["lr_max"]
        lr_min = config["lr_min"]
        lr_total_iters = config["lr_total_iters"]
        color_aug_enabled = config.get("color_aug_enabled", color_aug_enabled)
        color_aug_iters = config.get("color_aug_iters", color_aug_iters)
        color_aug_start = config.get("color_aug_start", color_aug_start)
        color_aug_end = config.get("color_aug_end", color_aug_end)
        print(
            f"  Restored training state: iter={optimize_counter}, lr_max={lr_max}, "
            f"lr_min={lr_min}, lr_total_iters={lr_total_iters}, "
            f"color_aug={color_aug_enabled} ({color_aug_start:.1f}->{color_aug_end:.1f} over {color_aug_iters})"
        )
    else:
        print("  No train_config.json found; optimize_counter and LR schedule unchanged.")


def make_globals():
    globals = {
        "sampler": sampler,
        "environment_map": envmap,
        "network": spy.slangpy.unpack_arg(network),
    }
    globals.update(mat.to_global_uniforms())
    return globals


optimize_counter = 0
metric_log_interval = 64
batch_size = (64, 64)
validation_seed = 0x5EED
validation_batch_size = (512, 512)

lr_max = 0.001
lr_min = 0.00001
lr_total_iters = 100_000

color_aug_enabled = True
color_aug_iters = 10_000
color_aug_start = 1.0
color_aug_end = 0.0

metric_log_l1_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_rel_l1_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_mse_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")
metric_valid_buffer = spy.Tensor.zeros(app.device, validation_batch_size, dtype="float")

accumulator = spy.Tensor.empty(app.device, (1024, 1024), "float4")
output = spy.Tensor.zeros(app.device, (1024, 1024), "float3")
accumulator_neural = spy.Tensor.empty(app.device, (1024, 1024), "float4")
output_neural = spy.Tensor.zeros(app.device, (1024, 1024), "float3")
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

latent_output = spy.Tensor.empty(
    app.device,
    (LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION),
    dtype=spy.float3,
)

#load_checkpoint(r"C:\sw\neural-shading-s26\train\runs\20260506_100822\0065536")


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
    globals = make_globals()

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

    for _ in range(16):
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

    app.blit(output)
    app.blit(output_neural, offset=spy.int2(1024, 0))

    latent_x = 1024 * 2
    latent_y = 0
    col = 0
    latent_res = spy.int2(LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION)
    for channel in range(NUM_LATENTS):
        module.render_latent.set(globals)(
            pixel=spy.call_id(), resolution=latent_res, channel=channel, _result=latent_output
        )
        app.blit(latent_output, size=spy.int2(330, 330), offset=spy.int2(latent_x, latent_y), tonemap=False, bilinear=False)
        latent_x += 340
        col += 1
        if col >= 3:
            latent_x = 1024 * 2
            latent_y += 340
            col = 0

    app.present()
    module.device.wait_for_idle()

    if not accumulate:
        accumulator.clear()
        accumulator_neural.clear()
