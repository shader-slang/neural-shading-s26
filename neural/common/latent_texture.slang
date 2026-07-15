// SPDX-License-Identifier: BSD-3-Clause

import slangpy;

#include "neural/common/adam.slang"

public static const int kLatentTextureNumLatents = 8;

public struct LatentTexture<int NumLatents>
{
    RWTensor<float, 3> values;
    AtomicTensor<float, 3> gradients;

    [BackwardDerivative(get_value_bwd)]
    float get_value(int x, int y, int channel)
    {
        return values[y, x, channel];
    }

    void get_value_bwd(int x, int y, int channel, float grad)
    {
        if (!isnan(grad))
            gradients.add(y, x, channel, grad);
    }

    [Differentiable]
    float[NumLatents] sample(no_diff float2 uv)
    {
        int2 size = int2(values.shape[1], values.shape[0]);
        float2 texel_uv = uv * float2(size - 1);

        int2 c0 = clamp(int2(texel_uv), int2(0), size - 1);
        int2 c1 = min(c0 + 1, size - 1);
        float2 f = saturate(texel_uv - float2(c0));

        float result[NumLatents];
        [ForceUnroll]
        for (int i = 0; i < NumLatents; ++i)
        {
            float v00 = get_value(c0.x, c0.y, i);
            float v10 = get_value(c1.x, c0.y, i);
            float v01 = get_value(c0.x, c1.y, i);
            float v11 = get_value(c1.x, c1.y, i);
            result[i] = lerp(lerp(v00, v10, f.x), lerp(v01, v11, f.x), f.y);
        }

        return result;
    }
};

[numthreads(1, 8, 8)]
public void latent_texture_optimizer_kernel(
    uint3 dispatch_thread_id: SV_DispatchThreadID,
    uniform LatentTexture<kLatentTextureNumLatents> latent_texture,
    uniform RWTensor<float, 3> means,
    uniform RWTensor<float, 3> variances,
    uniform float learning_rate,
    uniform int iteration)
{
    int channel = dispatch_thread_id.x;
    int x = dispatch_thread_id.y;
    int y = dispatch_thread_id.z;

    int2 resolution = int2(latent_texture.values.shape[1], latent_texture.values.shape[0]);
    if (x >= resolution.x || y >= resolution.y || channel >= kLatentTextureNumLatents)
        return;

    float primal = latent_texture.values[y, x, channel];
    float grad = latent_texture.gradients[y, x, channel];
    float mean = means[y, x, channel];
    float variance = variances[y, x, channel];

    optimizer_step_float(primal, grad, mean, variance, learning_rate, iteration);

    latent_texture.values[y, x, channel] = primal;
    latent_texture.gradients[y, x, channel] = 0.0f;
    means[y, x, channel] = mean;
    variances[y, x, channel] = variance;
}

