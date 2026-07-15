// SPDX-License-Identifier: BSD-3-Clause

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

    AtomicTensor<half, 1> biases_grad;
    AtomicTensor<half, 2> weights_grad;

    [Differentiable]
    float get_bias(int neuron)
    {
        return biases.load(neuron);
    }

    [Differentiable]
    float get_weight(int neuron, int input)
    {
        return weights.load(neuron, input);
    }

    [BackwardDerivativeOf(get_bias)]
    void get_bias_bwd(int neuron, float grad)
    {
        if (!isnan(grad))
            biases_grad.add(neuron, grad);
    }

    [BackwardDerivativeOf(get_weight)]
    void get_weight_bwd(int neuron, int input, float grad)
    {
        if (!isnan(grad))
            weights_grad.add(neuron, input, grad);
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
};

#endif
