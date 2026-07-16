// neural_baked_material.slang -- Baked neural material for UTracer.
//
// Training checkpoints contain a baked latent texture. UTracer only needs to
// sample that texture and run the decoder.

import slangpy;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 1
#endif
#include "neural/common/linear_layer.slang"

static const int kNeuralNumLatents = 8;
static const int kNeuralDecoderHidden = 32;

float leaky_relu(float x, float negative_slope = 0.01f)
{
    return x > 0.0f ? x : x * negative_slope;
}

static void parameterize_neural(float3 wi, float3 wo, out float3 wh, out float3 wd)
{
    wh = normalize(wi + wo);
    float3 v = float3(wh.y, -wh.x, 0.0f);
    wd = wi * wh.z + cross(v, wi) + dot(v, wi) * v / (1.0f + wh.z);
}

public struct NeuralDecoder
{
    LinearLayer<kNeuralNumLatents + 6, kNeuralDecoderHidden> layer0;
    LinearLayer<kNeuralDecoderHidden, kNeuralDecoderHidden> layer1;
    LinearLayer<kNeuralDecoderHidden, 3> layer2;

    float3 forward(float[kNeuralNumLatents] latents, float3 wi, float3 wo)
    {
        float3 wh, wd;
        parameterize_neural(wi, wo, wh, wd);

        float inputs[kNeuralNumLatents + 6] = {
            latents[0], latents[1], latents[2], latents[3],
            latents[4], latents[5], latents[6], latents[7],
            wh.x, wh.y, wh.z,
            wd.x, wd.y, wd.z
        };

        float[kNeuralDecoderHidden] h0 = layer0.forward(inputs);
        [ForceUnroll]
        for (int i = 0; i < kNeuralDecoderHidden; ++i)
            h0[i] = leaky_relu(h0[i]);

        float[kNeuralDecoderHidden] h1 = layer1.forward(h0);
        [ForceUnroll]
        for (int i = 0; i < kNeuralDecoderHidden; ++i)
            h1[i] = leaky_relu(h1[i]);

        float output[3] = layer2.forward(h1);
        [ForceUnroll]
        for (int i = 0; i < 3; ++i)
            output[i] = exp(output[i]);

        return float3(output[0], output[1], output[2]);
    }
};

public struct NeuralLatentTexture
{
    RWTensor<float, 3> texture;

    float[kNeuralNumLatents] sample(float2 uv)
    {
        int2 size = int2(texture.shape[1], texture.shape[0]);
        uv *= float2(size - 1);

        int2 c0 = clamp(int2(uv), int2(0), size - 1);
        int2 c1 = min(c0 + 1, size - 1);
        float2 f = saturate(uv - float2(c0));

        float[kNeuralNumLatents] result = {
            0.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 0.0f
        };
        [ForceUnroll]
        for (int i = 0; i < kNeuralNumLatents; ++i)
        {
            float v00 = texture[c0.y, c0.x, i];
            float v10 = texture[c0.y, c1.x, i];
            float v01 = texture[c1.y, c0.x, i];
            float v11 = texture[c1.y, c1.x, i];
            result[i] = lerp(lerp(v00, v10, f.x), lerp(v01, v11, f.x), f.y);
        }

        return result;
    }
};

public struct BakedNeuralMaterial
{
    NeuralLatentTexture latent_texture;
    NeuralDecoder decoder;

    public float3 eval(float2 uv, float3 wi, float3 wo)
    {
        if (min(wi.z, wo.z) <= 0.0f)
            return float3(0.0f);

        float[kNeuralNumLatents] latents = latent_texture.sample(uv);
        float3 weight = decoder.forward(latents, wi, wo);
        if (any(isnan(weight)) || any(isinf(weight)))
            return float3(0.0f);
        return max(weight, float3(0.0f));
    }
};
