# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np
import slangpy as spy


EXAMPLE_DIR = Path(__file__).resolve().parent
WORKSPACE_ROOT = EXAMPLE_DIR.parents[1]
if str(WORKSPACE_ROOT) not in sys.path:
    sys.path.insert(0, str(WORKSPACE_ROOT))

from materials.ceramic.mdl_ceramic_material import CeramicMaterial
from neural.common.app import App
from neural.common.checkpoint import create_run_dir, load_checkpoint, save_checkpoint
from neural.common.latent_texture import LATENT_TEXTURE_NUM_LATENTS, LatentTexture
from neural.common.linear_layer import LinearLayer, preferred_device_type, validate_device


IMAGE_RESOLUTION = 1024
PANEL_GAP = 8
PANEL_STRIDE = IMAGE_RESOLUTION + PANEL_GAP
LATENT_RESOLUTION = 4096
LATENT_PREVIEW_RESOLUTION = 512
NUM_LATENTS = LATENT_TEXTURE_NUM_LATENTS
HIDDEN_WIDTH = 32

BATCH_SIZE = (64, 64)
VALIDATION_BATCH_SIZE = (512, 512)
VALIDATION_SEED = 0x5EED

LEARNING_RATE_MAX = 1e-3
LEARNING_RATE_MIN = 1e-5
LEARNING_RATE_ITERS = 100_000
TRAIN_STEPS_PER_FRAME = 16
METRIC_INTERVAL = 64
CHECKPOINT_INTERVAL = 16 * 1024
CHECKPOINT_PREVIEW_FRAMES = 128
COLOR_AUGMENTATION_ITERS = 10_000
COLOR_AUGMENTATION_START = 1.0
COLOR_AUGMENTATION_END = 0.0
RANDOM_SEED = 1
CHECKPOINT_TO_LOAD = None
# CHECKPOINT_TO_LOAD = r"neural\step_05_color_augmentation\runs\YYYYMMDD_HHMMSS\checkpoints\0000000"


class Decoder(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["Decoder"])
        self.layer0 = LinearLayer(device, module, NUM_LATENTS + 6, HIDDEN_WIDTH)
        self.layer1 = LinearLayer(device, module, HIDDEN_WIDTH, HIDDEN_WIDTH)
        self.layer2 = LinearLayer(device, module, HIDDEN_WIDTH, 3)

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.layer0.optimize(learning_rate, iteration)
        self.layer1.optimize(learning_rate, iteration)
        self.layer2.optimize(learning_rate, iteration)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.layer0.save("decoder_layer0"),
            **self.layer1.save("decoder_layer1"),
            **self.layer2.save("decoder_layer2"),
        }

    def load(self, data: dict[str, np.ndarray]) -> None:
        self.layer0.load(data, "decoder_layer0")
        self.layer1.load(data, "decoder_layer1")
        self.layer2.load(data, "decoder_layer2")


class Network(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["Network"])
        self.latent_texture = LatentTexture(
            device,
            module,
            width=LATENT_RESOLUTION,
            height=LATENT_RESOLUTION,
            num_latents=NUM_LATENTS,
            random_seed=RANDOM_SEED,
        )
        self.decoder = Decoder(device, module)

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.latent_texture.optimize(learning_rate, iteration)
        self.decoder.optimize(learning_rate, iteration)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.latent_texture.save(),
            **self.decoder.save(),
        }

    def load(self, data: dict[str, np.ndarray]) -> None:
        self.latent_texture.load(data)
        self.decoder.load(data)


def cosine_annealing_learning_rate(iteration: int) -> float:
    t = min(iteration, LEARNING_RATE_ITERS)
    return LEARNING_RATE_MIN + 0.5 * (LEARNING_RATE_MAX - LEARNING_RATE_MIN) * (
        1.0 + math.cos(math.pi * t / LEARNING_RATE_ITERS)
    )


def cosine_annealing_color_augmentation_ratio(iteration: int) -> float:
    t = min(iteration, COLOR_AUGMENTATION_ITERS)
    return COLOR_AUGMENTATION_END + 0.5 * (COLOR_AUGMENTATION_START - COLOR_AUGMENTATION_END) * (
        1.0 + math.cos(math.pi * t / COLOR_AUGMENTATION_ITERS)
    )


def print_log_l1_error(module: spy.Module, shader_globals: dict) -> None:
    log_l1_buffer = spy.Tensor.zeros(module.device, VALIDATION_BATCH_SIZE, dtype="float")
    valid_buffer = spy.Tensor.zeros(module.device, VALIDATION_BATCH_SIZE, dtype="float")

    module.compute_error_batch.set(shader_globals)(
        seed=VALIDATION_SEED,
        batch_index=spy.grid(VALIDATION_BATCH_SIZE),
        batch_size=spy.int2(VALIDATION_BATCH_SIZE),
        log_l1_out=log_l1_buffer,
        valid_out=valid_buffer,
    )

    valid = valid_buffer.to_numpy()
    valid_count = max(float(valid.sum()), 1.0)
    log_l1 = float(log_l1_buffer.to_numpy().sum() / valid_count)

    learning_rate = cosine_annealing_learning_rate(max(optimize_counter - 1, 0))
    color_augmentation_ratio = cosine_annealing_color_augmentation_ratio(max(optimize_counter - 1, 0))
    print(
        f"[iter {optimize_counter:6d}] lr={learning_rate:.2e}  "
        f"color_aug={color_augmentation_ratio:.3f}  "
        f"log_l1={log_l1:.5f}  valid={int(valid_count)}"
    )


def render_and_save_checkpoint(module: spy.Module, shader_globals: dict) -> Path:
    checkpoint_target_accumulator = spy.Tensor.zeros(module.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float4")
    checkpoint_target_output = spy.Tensor.zeros(module.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float3")
    checkpoint_neural_accumulator = spy.Tensor.zeros(module.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float4")
    checkpoint_neural_output = spy.Tensor.zeros(module.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float3")

    for frame in range(CHECKPOINT_PREVIEW_FRAMES):
        module.render_target.set(shader_globals)(
            pixel=spy.call_id(),
            accumulator=checkpoint_target_accumulator,
            counter=frame,
            _result=checkpoint_target_output,
        )
        module.render_neural.set(shader_globals)(
            pixel=spy.call_id(),
            accumulator=checkpoint_neural_accumulator,
            counter=frame,
            _result=checkpoint_neural_output,
        )

    return save_checkpoint(
        run_dir,
        optimize_counter,
        network,
        outputs={"target": checkpoint_target_output, "neural": checkpoint_neural_output},
        latent_preview_size=LATENT_PREVIEW_RESOLUTION,
    )


np.random.seed(RANDOM_SEED)

app = App(
    width=IMAGE_RESOLUTION * 3 + PANEL_GAP * 2,
    height=IMAGE_RESOLUTION,
    title="Neural Material: Color Augmentation",
    device_type=preferred_device_type(),
    shader_paths=[EXAMPLE_DIR],
)
validate_device(app.device)

module = spy.Module.load_from_file(app.device, str(EXAMPLE_DIR / "color_augmentation.slang"))
material = CeramicMaterial(app.device)

loader = spy.TextureLoader(app.device)
envmap = loader.load_texture(WORKSPACE_ROOT / "data" / "brown_photostudio_02_2k.hdr")
sampler = app.device.create_sampler()
network = Network(app.device, module)

run_dir = create_run_dir(EXAMPLE_DIR)
print(f"Run directory: {run_dir}")

target_accumulator = spy.Tensor.zeros(app.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float4")
target_output = spy.Tensor.zeros(app.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float3")
neural_accumulator = spy.Tensor.zeros(app.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float4")
neural_output = spy.Tensor.zeros(app.device, (IMAGE_RESOLUTION, IMAGE_RESOLUTION), "float3")
latent_output = spy.Tensor.empty(app.device, (LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION), dtype=spy.float3)

frame_counter = 0
optimize_counter = 0
accumulate = False

if CHECKPOINT_TO_LOAD is not None:
    optimize_counter = load_checkpoint(network, CHECKPOINT_TO_LOAD)


def keyboard_event(event: spy.KeyboardEvent) -> None:
    global accumulate
    if event.is_key_press() and event.key == spy.KeyCode.space:
        accumulate = not accumulate
    if event.is_key_press() and event.key == spy.KeyCode.r:
        target_accumulator.clear()
        neural_accumulator.clear()


app.on_keyboard_event = keyboard_event

while app.process_events():
    shader_globals = {
        "sampler": sampler,
        "environment_map": envmap,
        "network": spy.slangpy.unpack_arg(network),
    }
    shader_globals.update(material.to_global_uniforms())

    module.render_target.set(shader_globals)(
        pixel=spy.call_id(),
        accumulator=target_accumulator,
        counter=frame_counter,
        _result=target_output,
    )
    module.render_neural.set(shader_globals)(
        pixel=spy.call_id(),
        accumulator=neural_accumulator,
        counter=frame_counter,
        _result=neural_output,
    )
    frame_counter += 1

    for _ in range(TRAIN_STEPS_PER_FRAME):
        learning_rate = cosine_annealing_learning_rate(optimize_counter)
        color_augmentation_ratio = cosine_annealing_color_augmentation_ratio(optimize_counter)

        module.calculate_grads.set(shader_globals)(
            seed=optimize_counter,
            batch_index=spy.grid(BATCH_SIZE),
            batch_size=spy.int2(BATCH_SIZE),
            color_augmentation_ratio=color_augmentation_ratio,
        )
        optimize_counter += 1
        network.optimize(learning_rate, optimize_counter)

        if optimize_counter % METRIC_INTERVAL == 0:
            print_log_l1_error(module, shader_globals)

        if optimize_counter % CHECKPOINT_INTERVAL == 0:
            checkpoint_dir = render_and_save_checkpoint(module, shader_globals)
            print(f"[iter {optimize_counter:7d}] checkpoint saved -> {checkpoint_dir}")

    app.clear()
    app.blit(target_output)
    app.blit(neural_output, offset=spy.int2(PANEL_STRIDE, 0))

    latent_tile = 330
    latent_step = 340
    latent_res = spy.int2(LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION)
    for channel in range(NUM_LATENTS):
        col = channel % 3
        row = channel // 3
        module.render_latent.set(shader_globals)(
            pixel=spy.call_id(),
            resolution=latent_res,
            channel=channel,
            _result=latent_output,
        )
        app.blit(
            latent_output,
            size=spy.int2(latent_tile, latent_tile),
            offset=spy.int2(PANEL_STRIDE * 2 + col * latent_step, row * latent_step),
            tonemap=False,
            bilinear=False,
        )

    app.present()

    if not accumulate:
        target_accumulator.clear()
        neural_accumulator.clear()
