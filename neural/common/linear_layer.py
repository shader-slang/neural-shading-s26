
from __future__ import annotations

import math
from collections.abc import Mapping

import numpy as np
import slangpy as spy


# Keep this in sync with USE_COOPVEC_LINEAR in the Slang example.
USE_COOPVEC_LINEAR = True


def preferred_device_type() -> spy.DeviceType:
    return spy.DeviceType.vulkan if USE_COOPVEC_LINEAR else spy.DeviceType.d3d12


def validate_device(device: spy.Device) -> None:
    if USE_COOPVEC_LINEAR and spy.Feature.cooperative_vector not in device.features:
        raise RuntimeError("USE_COOPVEC_LINEAR requires cooperative vector support.")


def xavier_scale(inputs: int, outputs: int) -> float:
    return math.sqrt(6.0 / (inputs + outputs))


class LinearLayer(spy.InstanceList):
    def __init__(self, device: spy.Device, module: spy.Module, inputs: int, outputs: int, weight_scale: float | None = None):
        super().__init__(module[f"LinearLayer<{inputs},{outputs}>"])
        self.device = device
        self.module = module
        self.inputs = inputs
        self.outputs = outputs

        if weight_scale is None:
            weight_scale = xavier_scale(inputs, outputs)
        weights = np.random.uniform(-weight_scale, weight_scale, (outputs, inputs)).astype(np.float16)
        biases = np.zeros(outputs, dtype=np.float16)

        if USE_COOPVEC_LINEAR:
            self._init_coopvec(weights, biases)
        else:
            self._init_tensors(weights, biases)

    @staticmethod
    def _align_half_count(count: int, byte_alignment: int) -> int:
        byte_count = count * np.dtype(np.float16).itemsize
        aligned = math.ceil(byte_count / byte_alignment) * byte_alignment
        return aligned // np.dtype(np.float16).itemsize

    def _init_tensors(self, weights: np.ndarray, biases: np.ndarray) -> None:
        self.biases = spy.Tensor.from_numpy(self.device, biases.astype(np.float16))
        self.weights = spy.Tensor.from_numpy(self.device, weights.astype(np.float16))
        self.reset_optimizer_state()

    def _init_coopvec(self, weights: np.ndarray, biases: np.ndarray) -> None:
        self.usage = (
            spy.BufferUsage.shader_resource
            | spy.BufferUsage.unordered_access
            | spy.BufferUsage.shared
        )
        self.weight_desc = self.device.create_coop_vec_matrix_desc(
            self.outputs,
            self.inputs,
            spy.CoopVecMatrixLayout.training_optimal,
            spy.DataType.float16,
        )
        self.weight_count = self.weight_desc.size // np.dtype(np.float16).itemsize
        self.bias_count = self._align_half_count(self.outputs, 16)

        self._set_weights_from_row_major(weights)
        self._set_biases(biases)
        self.reset_optimizer_state()

    def _new_half_tensor(self, values: np.ndarray) -> spy.Tensor:
        tensor = spy.Tensor.empty(self.device, values.shape, "half", usage=self.usage)
        tensor.storage.copy_from_numpy(values.astype(np.float16))
        return tensor

    def _bind_coopvec_buffers(self) -> None:
        self.weights = self.weight_values.storage.descriptor_handle_ro
        self.biases = self.bias_values.storage.descriptor_handle_ro
        self.weights_grad = self.weight_grad_values.storage.descriptor_handle_rw
        self.biases_grad = self.bias_grad_values.storage.descriptor_handle_rw
        self.weight_offset = self.weight_values.offset
        self.bias_offset = self.bias_values.offset
        self.weight_grad_offset = self.weight_grad_values.offset
        self.bias_grad_offset = self.bias_grad_values.offset

    def _set_weights_from_row_major(self, weights: np.ndarray) -> None:
        values = np.zeros((self.weight_count,), dtype=np.float16)
        self.device.convert_coop_vec_matrix(
            dst=values,
            src=weights.astype(np.float16),
            dst_layout=spy.CoopVecMatrixLayout.training_optimal,
        )
        self.weight_values = self._new_half_tensor(values)

    def _set_biases(self, biases: np.ndarray) -> None:
        values = np.zeros((self.bias_count,), dtype=np.float16)
        values[: self.outputs] = biases.astype(np.float16)
        self.bias_values = self._new_half_tensor(values)

    def _weights_to_row_major(self) -> np.ndarray:
        row_major_desc = self.device.create_coop_vec_matrix_desc(
            self.outputs,
            self.inputs,
            spy.CoopVecMatrixLayout.row_major,
            spy.DataType.float16,
        )
        row_major = spy.Tensor.empty(
            self.device,
            (row_major_desc.size // np.dtype(np.float16).itemsize,),
            "half",
            usage=self.usage,
        )
        cmd = self.device.create_command_encoder()
        cmd.convert_coop_vec_matrix(
            row_major.storage,
            row_major_desc,
            self.weight_values.storage,
            self.weight_desc,
        )
        self.device.wait_for_submit(self.device.submit_command_buffer(cmd.finish()))
        values = row_major.to_numpy()[: self.inputs * self.outputs]
        return values.reshape((self.outputs, self.inputs))

    def optimize(self, learning_rate: float, iteration: int) -> None:
        if USE_COOPVEC_LINEAR:
            self.module.optimizer_step(
                self.bias_values,
                self.bias_grad_values,
                self.m_biases,
                self.v_biases,
                learning_rate,
                iteration,
            )
            self.module.optimizer_step(
                self.weight_values,
                self.weight_grad_values,
                self.m_weights,
                self.v_weights,
                learning_rate,
                iteration,
            )
        else:
            self.module.optimizer_step(
                self.biases,
                self.biases_grad,
                self.m_biases,
                self.v_biases,
                learning_rate,
                iteration,
            )
            self.module.optimizer_step(
                self.weights,
                self.weights_grad,
                self.m_weights,
                self.v_weights,
                learning_rate,
                iteration,
            )

    def reset_optimizer_state(self) -> None:
        if USE_COOPVEC_LINEAR:
            self.bias_grad_values = spy.Tensor.zeros(
                self.device, (self.bias_count,), "half", usage=self.usage
            )
            self.weight_grad_values = spy.Tensor.zeros(
                self.device, (self.weight_count,), "half", usage=self.usage
            )
            self.m_biases = spy.Tensor.from_numpy(self.device, np.zeros(self.bias_count, dtype=np.float32))
            self.m_weights = spy.Tensor.from_numpy(self.device, np.zeros(self.weight_count, dtype=np.float32))
            self.v_biases = spy.Tensor.from_numpy(self.device, np.zeros(self.bias_count, dtype=np.float32))
            self.v_weights = spy.Tensor.from_numpy(self.device, np.zeros(self.weight_count, dtype=np.float32))
            self._bind_coopvec_buffers()
        else:
            self.biases_grad = spy.Tensor.zeros_like(self.biases)
            self.weights_grad = spy.Tensor.zeros_like(self.weights)
            self.m_biases = spy.Tensor.from_numpy(self.device, np.zeros(self.outputs, dtype=np.float32))
            self.m_weights = spy.Tensor.from_numpy(
                self.device, np.zeros((self.outputs, self.inputs), dtype=np.float32)
            )
            self.v_biases = spy.Tensor.from_numpy(self.device, np.zeros(self.outputs, dtype=np.float32))
            self.v_weights = spy.Tensor.from_numpy(
                self.device, np.zeros((self.outputs, self.inputs), dtype=np.float32)
            )

    def save(self, prefix: str) -> dict[str, np.ndarray]:
        if USE_COOPVEC_LINEAR:
            biases = self.bias_values.to_numpy()[: self.outputs]
            weights = self._weights_to_row_major()
        else:
            biases = self.biases.to_numpy()
            weights = self.weights.to_numpy()
        return {
            f"{prefix}_biases": biases,
            f"{prefix}_weights": weights,
        }

    def load(self, data: Mapping[str, np.ndarray], prefix: str) -> None:
        biases = data[f"{prefix}_biases"].astype(np.float16)
        weights = data[f"{prefix}_weights"].astype(np.float16)
        if USE_COOPVEC_LINEAR:
            self._set_biases(biases)
            self._set_weights_from_row_major(weights)
            self.reset_optimizer_state()
        else:
            self.biases = spy.Tensor.from_numpy(self.device, biases)
            self.weights = spy.Tensor.from_numpy(self.device, weights)
            self.reset_optimizer_state()
