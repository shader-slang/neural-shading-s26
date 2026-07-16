// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slangpy;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 0
#endif

#if USE_COOPVEC_LINEAR

// CoopVec participates natively in autodiff, but lane reads and writes still need focused
// conversion derivatives at the array boundary.
CoopVec<half, N> coop_vec_from_float_array<let N : int>(float[N] values)
{
    CoopVec<half, N> result;
    [ForceUnroll]
    for (int i = 0; i < N; ++i)
        result[i] = half(values[i]);
    return result;
}

[BackwardDerivativeOf(coop_vec_from_float_array)]
void coop_vec_from_float_array_bwd<let N : int>(
    inout DifferentialPair<float[N]> values,
    CoopVec<half, N> grad)
{
    float[N] values_grad;
    [ForceUnroll]
    for (int i = 0; i < N; ++i)
        values_grad[i] = float(grad[i]);
    values = diffPair(values.p, values_grad);
}

float[N] coop_vec_to_float_array<let N : int>(CoopVec<half, N> value)
{
    float[N] result;
    [ForceUnroll]
    for (int i = 0; i < N; ++i)
        result[i] = float(value[i]);
    return result;
}

[BackwardDerivativeOf(coop_vec_to_float_array)]
void coop_vec_to_float_array_bwd<let N : int>(
    inout DifferentialPair<CoopVec<half, N>> value,
    float[N] grad)
{
    value = diffPair(value.p, coop_vec_from_float_array(grad));
}

public struct LinearLayer<int Inputs, int Outputs>
{
    ByteAddressBuffer.Handle weights;
    ByteAddressBuffer.Handle biases;
    RWByteAddressBuffer.Handle weights_grad;
    RWByteAddressBuffer.Handle biases_grad;
    uint weight_offset;
    uint bias_offset;
    uint weight_grad_offset;
    uint bias_grad_offset;

    // Matrix operations depend on external layout metadata, so keep the custom reverse rule.
    CoopVec<half, Outputs> forward_vec(CoopVec<half, Inputs> x)
    {
        return coopVecMatMulAdd<half, Outputs>(
            x,
            CoopVecComponentType.Float16,
            *weights,
            weight_offset * sizeof(half),
            CoopVecComponentType.Float16,
            *biases,
            bias_offset * sizeof(half),
            CoopVecComponentType.Float16,
            CoopVecMatrixLayout.TrainingOptimal,
            false,
            0
        );
    }

    [BackwardDerivativeOf(forward_vec)]
    void forward_vec_bwd(
        inout DifferentialPair<CoopVec<half, Inputs>> x,
        CoopVec<half, Outputs> grad)
    {
        coopVecOuterProductAccumulate(
            grad,
            x.p,
            *weights_grad,
            weight_grad_offset * sizeof(half),
            0,
            CoopVecMatrixLayout.TrainingOptimal,
            CoopVecComponentType.Float16
        );

        coopVecReduceSumAccumulate(grad, *biases_grad, bias_grad_offset * sizeof(half));

        CoopVec<half, Inputs> dx = coopVecMatMul<half, Inputs>(
            grad,
            CoopVecComponentType.Float16,
            *weights,
            weight_offset * sizeof(half),
            CoopVecComponentType.Float16,
            CoopVecMatrixLayout.TrainingOptimal,
            true,
            0
        );
        x = diffPair(x.p, dx);
    }

    [Differentiable]
    float[Outputs] forward(float[Inputs] x)
    {
        return coop_vec_to_float_array(forward_vec(coop_vec_from_float_array(x)));
    }
};

#else

public struct LinearLayer<int Inputs, int Outputs>
{
    Tensor<half, 1> biases;
    Tensor<half, 2> weights;

    AtomicTensor<float, 1> biases_grad;
    AtomicTensor<float, 2> weights_grad;

    float get_bias(no_diff int neuron)
    {
        return biases.load(neuron);
    }

    float get_weight(no_diff int neuron, no_diff int input_index)
    {
        return weights.load(neuron, input_index);
    }

    [Differentiable]
    float[Outputs] forward(float[Inputs] x)
    {
        float[Outputs] y;

        [MaxIters(Outputs)]
        for (int row = 0; row < Outputs; ++row)
        {
            float sum = get_bias(row);
            [ForceUnroll]
            for (int col = 0; col < Inputs; ++col)
                sum += get_weight(row, col) * x[col];
            y[row] = sum;
        }

        return y;
    }

    [BackwardDerivativeOf(forward)]
    void forward_bwd(
        inout DifferentialPair<float[Inputs]> x,
        float[Outputs] output_grad)
    {
        float input_grad[Inputs];
        [ForceUnroll]
        for (int col = 0; col < Inputs; ++col)
            input_grad[col] = 0.0f;

        [MaxIters(Outputs)]
        for (int row = 0; row < Outputs; ++row)
        {
            float grad = output_grad[row];
            if (isnan(grad))
                continue;

            biases_grad.add(row, grad);
            [ForceUnroll]
            for (int col = 0; col < Inputs; ++col)
            {
                weights_grad.add(row, col, grad * x.p[col]);
                input_grad[col] += grad * get_weight(row, col);
            }
        }

        x = diffPair(x.p, input_grad);
    }
};

#endif
