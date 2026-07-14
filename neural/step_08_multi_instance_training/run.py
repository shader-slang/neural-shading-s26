# SPDX-License-Identifier: Apache-2.0

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
from neural.common.checkpoint import create_run_dir, load_json, save_json
from neural.common.image_io import save_float3_png, save_latent_channel_png
from neural.common.linear_layer import LinearLayer, preferred_device_type, validate_device


TARGET_PREVIEW_SIZE = 256
NETWORK_PREVIEW_SIZE = 96
PANEL_GAP = 8
GRID_COLUMNS = 8

INSTANCE_SCHEDULE = [64, 16, 4, 1]
BATCH_SIZE_SCHEDULE = [(8, 8), (16, 16), (32, 32), (64, 64)]
TOTAL_TRAINING_ITERS = 100_000

GRID_ROWS = math.ceil(INSTANCE_SCHEDULE[0] / GRID_COLUMNS)
WINDOW_WIDTH = TARGET_PREVIEW_SIZE + PANEL_GAP + GRID_COLUMNS * NETWORK_PREVIEW_SIZE + (GRID_COLUMNS - 1) * PANEL_GAP
WINDOW_HEIGHT = max(TARGET_PREVIEW_SIZE, GRID_ROWS * NETWORK_PREVIEW_SIZE + (GRID_ROWS - 1) * PANEL_GAP)

CHECKPOINT_RESOLUTION = 1024
LATENT_PREVIEW_RESOLUTION = 512
NUM_LATENTS = 8
ENCODER_INPUTS = 29
ENCODER_HIDDEN_WIDTH = 64
HIDDEN_WIDTH = 32
NUM_ROTATION_FRAMES = 2
ROTATION_FRAME_ELEMENTS = 6
ROTATION_OUTPUTS = NUM_ROTATION_FRAMES * ROTATION_FRAME_ELEMENTS
DECODER_DIRECTION_INPUTS = NUM_ROTATION_FRAMES * 6

VALIDATION_BATCH_SIZE = (256, 256)
VALIDATION_SEED = 0x5EED

LEARNING_RATE_MAX = 1e-3
LEARNING_RATE_MIN = 1e-5
LEARNING_RATE_ITERS = TOTAL_TRAINING_ITERS
TRAIN_STEPS_PER_FRAME = 16
METRIC_INTERVAL = 64
CHECKPOINT_INTERVAL = 16 * 1024
PREVIEW_SAMPLES_PER_FRAME = 16
CHECKPOINT_SAMPLES_PER_FRAME = 16
CHECKPOINT_PREVIEW_FRAMES = 128
COLOR_AUGMENTATION_ITERS = 10_000
COLOR_AUGMENTATION_START = 1.0
COLOR_AUGMENTATION_END = 0.0
RANDOM_SEED = 1
CHECKPOINT_TO_LOAD = None
# CHECKPOINT_TO_LOAD = r"neural\step_08_multi_instance_training\runs\YYYYMMDD_HHMMSS\checkpoints\0000000"


class Encoder(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["Encoder"])
        self.layer0 = LinearLayer(device, module, ENCODER_INPUTS, ENCODER_HIDDEN_WIDTH)
        self.layer1 = LinearLayer(device, module, ENCODER_HIDDEN_WIDTH, ENCODER_HIDDEN_WIDTH)
        self.layer2 = LinearLayer(device, module, ENCODER_HIDDEN_WIDTH, ENCODER_HIDDEN_WIDTH)
        self.layer3 = LinearLayer(device, module, ENCODER_HIDDEN_WIDTH, NUM_LATENTS)

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.layer0.optimize(learning_rate, iteration)
        self.layer1.optimize(learning_rate, iteration)
        self.layer2.optimize(learning_rate, iteration)
        self.layer3.optimize(learning_rate, iteration)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.layer0.save("encoder_layer0"),
            **self.layer1.save("encoder_layer1"),
            **self.layer2.save("encoder_layer2"),
            **self.layer3.save("encoder_layer3"),
        }

    def load(self, data: dict[str, np.ndarray]) -> None:
        self.layer0.load(data, "encoder_layer0")
        self.layer1.load(data, "encoder_layer1")
        self.layer2.load(data, "encoder_layer2")
        self.layer3.load(data, "encoder_layer3")


class ShadingFrameRotation(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["ShadingFrameRotation"])
        self.frame_decoder = LinearLayer(device, module, NUM_LATENTS, ROTATION_OUTPUTS)

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.frame_decoder.optimize(learning_rate, iteration)

    def save(self) -> dict[str, np.ndarray]:
        return self.frame_decoder.save("rotation_frame_decoder")

    def load(self, data: dict[str, np.ndarray]) -> None:
        self.frame_decoder.load(data, "rotation_frame_decoder")


class Decoder(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module):
        super().__init__(module["Decoder"])
        self.layer0 = LinearLayer(device, module, NUM_LATENTS + DECODER_DIRECTION_INPUTS, HIDDEN_WIDTH)
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
        self.encoder = Encoder(device, module)
        self.rotation = ShadingFrameRotation(device, module)
        self.decoder = Decoder(device, module)

    def optimize(self, learning_rate: float, iteration: int) -> None:
        self.encoder.optimize(learning_rate, iteration)
        self.rotation.optimize(learning_rate, iteration)
        self.decoder.optimize(learning_rate, iteration)

    def save(self) -> dict[str, np.ndarray]:
        return {
            **self.encoder.save(),
            **self.rotation.save(),
            **self.decoder.save(),
        }

    def load(self, data: dict[str, np.ndarray]) -> None:
        self.encoder.load(data)
        self.rotation.load(data)
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


def training_stage(iteration: int) -> int:
    stage_iters = max(TOTAL_TRAINING_ITERS // len(INSTANCE_SCHEDULE), 1)
    return min(iteration // stage_iters, len(INSTANCE_SCHEDULE) - 1)


def create_network_preview_tensors(device: spy.Device, count: int) -> tuple[list[spy.Tensor], list[spy.Tensor]]:
    accumulators = [spy.Tensor.zeros(device, (NETWORK_PREVIEW_SIZE, NETWORK_PREVIEW_SIZE), "float4") for _ in range(count)]
    outputs = [spy.Tensor.zeros(device, (NETWORK_PREVIEW_SIZE, NETWORK_PREVIEW_SIZE), "float3") for _ in range(count)]
    return accumulators, outputs


def finite_error(error: float) -> float | None:
    return float(error) if math.isfinite(float(error)) else None


def best_network_index(network_errors: list[float]) -> int:
    errors = np.array(network_errors, dtype=np.float64)
    if not np.isfinite(errors).any():
        return 0
    return int(np.argmin(np.where(np.isfinite(errors), errors, np.inf)))


def measure_and_print_log_l1_errors(
    module: spy.Module,
    base_shader_globals: dict,
    networks: list[Network],
    network_ids: list[int],
    stage: int,
    batch_size: tuple[int, int],
    label: str,
) -> list[float]:
    log_l1_buffer = spy.Tensor.zeros(module.device, VALIDATION_BATCH_SIZE, dtype="float")
    valid_buffer = spy.Tensor.zeros(module.device, VALIDATION_BATCH_SIZE, dtype="float")
    errors: list[float] = []
    valid_counts: list[int] = []

    for network in networks:
        shader_globals = {**base_shader_globals, "network": spy.slangpy.unpack_arg(network)}
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
        errors.append(log_l1)
        valid_counts.append(int(valid_count))

    error_array = np.array(errors)
    finite = error_array[np.isfinite(error_array)]
    best_index = best_network_index(errors)
    worst = float(np.max(finite)) if len(finite) else math.inf
    median = float(np.median(finite)) if len(finite) else math.inf
    learning_rate = cosine_annealing_learning_rate(max(optimize_counter - 1, 0))
    color_augmentation_ratio = cosine_annealing_color_augmentation_ratio(max(optimize_counter - 1, 0))
    print(
        f"[iter {optimize_counter:6d}] {label}  stage={stage + 1}/{len(INSTANCE_SCHEDULE)}  "
        f"networks={len(networks):2d}  batch={batch_size[0]}x{batch_size[1]}  "
        f"lr={learning_rate:.2e}  color_aug={color_augmentation_ratio:.3f}  "
        f"log_l1 best=#{network_ids[best_index]} {errors[best_index]:.5f}  "
        f"median={median:.5f}  worst={worst:.5f}  valid={min(valid_counts)}"
    )
    if len(networks) <= 16:
        print("    " + "  ".join(f"#{network_ids[i]}={errors[i]:.5f}" for i in range(len(networks))))

    return errors


def prune_networks(
    networks: list[Network],
    network_ids: list[int],
    network_errors: list[float],
    keep_count: int,
) -> tuple[list[Network], list[int], list[float]]:
    sort_errors = np.array(network_errors, dtype=np.float64)
    order = np.argsort(np.where(np.isfinite(sort_errors), sort_errors, np.inf))[:keep_count]
    kept_networks = [networks[i] for i in order]
    kept_ids = [network_ids[i] for i in order]
    kept_errors = [network_errors[i] for i in order]
    kept_text = ", ".join(f"#{kept_ids[i]}({kept_errors[i]:.5f})" for i in range(len(kept_ids)))
    print(f"[iter {optimize_counter:6d}] keeping {keep_count} networks: {kept_text}")
    return kept_networks, kept_ids, kept_errors


def save_network_population(
    checkpoint_dir: Path,
    iteration: int,
    networks: list[Network],
    network_ids: list[int],
    network_errors: list[float],
    stage: int,
    batch_size: tuple[int, int],
    best_index: int,
) -> None:
    data: dict[str, np.ndarray] = {
        "network_ids": np.array(network_ids, dtype=np.int32),
        "network_errors": np.array(network_errors, dtype=np.float32),
    }

    for index, network in enumerate(networks):
        for name, value in network.save().items():
            data[f"network_{index:02d}_{name}"] = value

    np.savez(checkpoint_dir / "networks.npz", **data)
    save_json(
        checkpoint_dir / "config.json",
        {
            "iteration": iteration,
            "stage": stage,
            "batch_size": list(batch_size),
            "network_ids": network_ids,
            "network_errors": [finite_error(error) for error in network_errors],
            "best_network_id": network_ids[best_index],
        },
    )


def resolve_population_checkpoint(path: str | Path) -> Path:
    path = Path(path)
    if path.is_dir():
        candidate = path / "networks.npz"
        if candidate.is_file():
            return candidate
        raise FileNotFoundError(f"No networks.npz found in {path}")
    if path.is_file() and path.suffix == ".npz":
        return path
    raise FileNotFoundError(f"Checkpoint not found: {path}")


def load_network_population(
    device: spy.Device,
    module: spy.Module,
    path: str | Path,
) -> tuple[int, list[Network], list[int], list[float]]:
    npz_path = resolve_population_checkpoint(path)
    config_path = npz_path.parent / "config.json"
    iteration = int(load_json(config_path).get("iteration", 0)) if config_path.exists() else 0

    networks: list[Network] = []
    with np.load(npz_path) as npz:
        network_ids = npz["network_ids"].astype(np.int32).tolist()
        network_errors = npz["network_errors"].astype(np.float32).tolist()

        for index in range(len(network_ids)):
            prefix = f"network_{index:02d}_"
            network_data = {
                name[len(prefix) :]: npz[name]
                for name in npz.files
                if name.startswith(prefix)
            }
            network = Network(device, module)
            network.load(network_data)
            networks.append(network)

    print(f"Loaded checkpoint: {npz_path}")
    return iteration, networks, network_ids, network_errors


def render_and_save_checkpoint(
    module: spy.Module,
    base_shader_globals: dict,
    networks: list[Network],
    network_ids: list[int],
    network_errors: list[float],
    stage: int,
    batch_size: tuple[int, int],
) -> Path:
    best_index = best_network_index(network_errors)
    best_network = networks[best_index]
    shader_globals = {**base_shader_globals, "network": spy.slangpy.unpack_arg(best_network)}

    checkpoint_target_accumulator = spy.Tensor.zeros(module.device, (CHECKPOINT_RESOLUTION, CHECKPOINT_RESOLUTION), "float4")
    checkpoint_target_output = spy.Tensor.zeros(module.device, (CHECKPOINT_RESOLUTION, CHECKPOINT_RESOLUTION), "float3")
    checkpoint_neural_accumulator = spy.Tensor.zeros(module.device, (CHECKPOINT_RESOLUTION, CHECKPOINT_RESOLUTION), "float4")
    checkpoint_neural_output = spy.Tensor.zeros(module.device, (CHECKPOINT_RESOLUTION, CHECKPOINT_RESOLUTION), "float3")
    latent_preview = spy.Tensor.zeros(
        module.device,
        (LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION, NUM_LATENTS),
        "float",
    )
    checkpoint_resolution = spy.int2(CHECKPOINT_RESOLUTION, CHECKPOINT_RESOLUTION)

    for frame in range(CHECKPOINT_PREVIEW_FRAMES):
        module.render_target.set(shader_globals)(
            pixel=spy.call_id(),
            resolution=checkpoint_resolution,
            sample_count=CHECKPOINT_SAMPLES_PER_FRAME,
            accumulator=checkpoint_target_accumulator,
            counter=frame,
            _result=checkpoint_target_output,
        )
        module.render_neural.set(shader_globals)(
            pixel=spy.call_id(),
            resolution=checkpoint_resolution,
            sample_count=CHECKPOINT_SAMPLES_PER_FRAME,
            accumulator=checkpoint_neural_accumulator,
            counter=frame,
            _result=checkpoint_neural_output,
        )

    module.bake_latent_texture.set(shader_globals).dispatch(
        thread_count=(LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION, 1),
        latent_texture=latent_preview,
        resolution=spy.int2(LATENT_PREVIEW_RESOLUTION, LATENT_PREVIEW_RESOLUTION),
    )

    checkpoint_dir = run_dir / "checkpoints" / f"{optimize_counter:07d}"
    preview_dir = run_dir / "previews" / f"{optimize_counter:07d}"
    checkpoint_dir.mkdir(parents=True, exist_ok=True)
    preview_dir.mkdir(parents=True, exist_ok=True)

    save_network_population(
        checkpoint_dir,
        optimize_counter,
        networks,
        network_ids,
        network_errors,
        stage,
        batch_size,
        best_index,
    )
    save_float3_png(checkpoint_target_output, preview_dir / "target.png")
    save_float3_png(checkpoint_neural_output, preview_dir / "neural_best.png")

    latents = latent_preview.to_numpy()
    for channel in range(latents.shape[2]):
        save_latent_channel_png(
            latents,
            channel,
            preview_dir / f"latent_{channel:02d}.png",
            LATENT_PREVIEW_RESOLUTION,
        )

    return checkpoint_dir


np.random.seed(RANDOM_SEED)

app = App(
    width=WINDOW_WIDTH,
    height=WINDOW_HEIGHT,
    title="Neural Material: Multi-Instance Training",
    device_type=preferred_device_type(),
    shader_paths=[EXAMPLE_DIR],
)
validate_device(app.device)

module = spy.Module.load_from_file(app.device, str(EXAMPLE_DIR / "multi_instance_training.slang"))
material = CeramicMaterial(app.device)

loader = spy.TextureLoader(app.device)
envmap = loader.load_texture(WORKSPACE_ROOT / "data" / "brown_photostudio_02_2k.hdr")
sampler = app.device.create_sampler()

if CHECKPOINT_TO_LOAD is None:
    networks = [Network(app.device, module) for _ in range(INSTANCE_SCHEDULE[0])]
    network_ids = list(range(len(networks)))
    network_errors = [math.inf for _ in networks]
    optimize_counter = 0
else:
    optimize_counter, networks, network_ids, network_errors = load_network_population(app.device, module, CHECKPOINT_TO_LOAD)

current_stage = training_stage(optimize_counter)
batch_size = BATCH_SIZE_SCHEDULE[current_stage]

run_dir = create_run_dir(EXAMPLE_DIR)
print(f"Run directory: {run_dir}")
print(
    f"Multi-instance schedule: "
    f"{INSTANCE_SCHEDULE[0]}@{BATCH_SIZE_SCHEDULE[0][0]}x{BATCH_SIZE_SCHEDULE[0][1]} -> "
    f"{INSTANCE_SCHEDULE[1]}@{BATCH_SIZE_SCHEDULE[1][0]}x{BATCH_SIZE_SCHEDULE[1][1]} -> "
    f"{INSTANCE_SCHEDULE[2]}@{BATCH_SIZE_SCHEDULE[2][0]}x{BATCH_SIZE_SCHEDULE[2][1]} -> "
    f"{INSTANCE_SCHEDULE[3]}@{BATCH_SIZE_SCHEDULE[3][0]}x{BATCH_SIZE_SCHEDULE[3][1]}"
)

target_accumulator = spy.Tensor.zeros(app.device, (TARGET_PREVIEW_SIZE, TARGET_PREVIEW_SIZE), "float4")
target_output = spy.Tensor.zeros(app.device, (TARGET_PREVIEW_SIZE, TARGET_PREVIEW_SIZE), "float3")
network_accumulators, network_outputs = create_network_preview_tensors(app.device, len(networks))

target_preview_resolution = spy.int2(TARGET_PREVIEW_SIZE, TARGET_PREVIEW_SIZE)
network_preview_resolution = spy.int2(NETWORK_PREVIEW_SIZE, NETWORK_PREVIEW_SIZE)

frame_counter = 0
accumulate = False


def keyboard_event(event: spy.KeyboardEvent) -> None:
    global accumulate
    if event.is_key_press() and event.key == spy.KeyCode.space:
        accumulate = not accumulate
    if event.is_key_press() and event.key == spy.KeyCode.r:
        target_accumulator.clear()
        for accumulator in network_accumulators:
            accumulator.clear()


app.on_keyboard_event = keyboard_event

while app.process_events():
    base_shader_globals = {
        "sampler": sampler,
        "environment_map": envmap,
    }
    base_shader_globals.update(material.to_global_uniforms())

    target_shader_globals = {**base_shader_globals, "network": spy.slangpy.unpack_arg(networks[0])}
    module.render_target.set(target_shader_globals)(
        pixel=spy.call_id(),
        resolution=target_preview_resolution,
        sample_count=PREVIEW_SAMPLES_PER_FRAME,
        accumulator=target_accumulator,
        counter=frame_counter,
        _result=target_output,
    )

    for index, network in enumerate(networks):
        shader_globals = {**base_shader_globals, "network": spy.slangpy.unpack_arg(network)}
        module.render_neural.set(shader_globals)(
            pixel=spy.call_id(),
            resolution=network_preview_resolution,
            sample_count=PREVIEW_SAMPLES_PER_FRAME,
            accumulator=network_accumulators[index],
            counter=frame_counter,
            _result=network_outputs[index],
        )

    frame_counter += 1

    for _ in range(TRAIN_STEPS_PER_FRAME):
        if optimize_counter >= TOTAL_TRAINING_ITERS:
            break

        learning_rate = cosine_annealing_learning_rate(optimize_counter)
        color_augmentation_ratio = cosine_annealing_color_augmentation_ratio(optimize_counter)

        for network in networks:
            shader_globals = {**base_shader_globals, "network": spy.slangpy.unpack_arg(network)}
            module.calculate_grads.set(shader_globals)(
                seed=optimize_counter,
                batch_index=spy.grid(batch_size),
                batch_size=spy.int2(batch_size),
                color_augmentation_ratio=color_augmentation_ratio,
            )
            network.optimize(learning_rate, optimize_counter + 1)

        optimize_counter += 1
        pruned = False
        next_stage = training_stage(optimize_counter)

        if next_stage != current_stage:
            network_errors = measure_and_print_log_l1_errors(
                module,
                base_shader_globals,
                networks,
                network_ids,
                current_stage,
                batch_size,
                "before pruning",
            )
            networks, network_ids, network_errors = prune_networks(
                networks,
                network_ids,
                network_errors,
                INSTANCE_SCHEDULE[next_stage],
            )
            current_stage = next_stage
            batch_size = BATCH_SIZE_SCHEDULE[current_stage]
            network_accumulators, network_outputs = create_network_preview_tensors(app.device, len(networks))
            pruned = True
        elif optimize_counter % METRIC_INTERVAL == 0:
            network_errors = measure_and_print_log_l1_errors(
                module,
                base_shader_globals,
                networks,
                network_ids,
                current_stage,
                batch_size,
                "metric",
            )

        if optimize_counter % CHECKPOINT_INTERVAL == 0 or pruned or optimize_counter == TOTAL_TRAINING_ITERS:
            if not np.isfinite(np.array(network_errors, dtype=np.float64)).any():
                network_errors = measure_and_print_log_l1_errors(
                    module,
                    base_shader_globals,
                    networks,
                    network_ids,
                    current_stage,
                    batch_size,
                    "checkpoint metric",
                )
            checkpoint_dir = render_and_save_checkpoint(
                module,
                base_shader_globals,
                networks,
                network_ids,
                network_errors,
                current_stage,
                batch_size,
            )
            print(f"[iter {optimize_counter:7d}] checkpoint saved -> {checkpoint_dir}")

    app.clear()
    app.blit(target_output)

    grid_left = TARGET_PREVIEW_SIZE + PANEL_GAP
    for index, output in enumerate(network_outputs):
        col = index % GRID_COLUMNS
        row = index // GRID_COLUMNS
        app.blit(
            output,
            offset=spy.int2(
                grid_left + col * (NETWORK_PREVIEW_SIZE + PANEL_GAP),
                row * (NETWORK_PREVIEW_SIZE + PANEL_GAP),
            ),
        )

    app.present()

    if not accumulate:
        target_accumulator.clear()
        for accumulator in network_accumulators:
            accumulator.clear()
