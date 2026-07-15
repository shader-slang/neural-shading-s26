// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slangpy;
import materials.materials;
import materials.ceramic.mdl_ceramic_material;
import utracer.utracerutils;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 1
#endif

#include "neural/common/linear_layer.slang"
#include "neural/common/latent_texture.slang"

static const int kImageResolution = 1024;
static const int kNumLatents = kLatentTextureNumLatents;
static const int kHiddenWidth = 32;
static const float kMinCos = 1e-3f;

SamplerState sampler;
Texture2D<float4> environment_map;

[Differentiable]
float leaky_relu(float x, float negative_slope = 0.01f)
{
    return x > 0.0f ? x : x * negative_slope;
}

[Differentiable]
float output_activation(float x)
{
    return exp(x);
}

public struct Decoder
{
    LinearLayer<kNumLatents + 6, kHiddenWidth> layer0;
    LinearLayer<kHiddenWidth, kHiddenWidth> layer1;
    LinearLayer<kHiddenWidth, 3> layer2;

    [Differentiable]
    float3 forward(float[kNumLatents] latents, no_diff float3 wi, no_diff float3 wo)
    {
        float inputs[kNumLatents + 6];
        [ForceUnroll]
        for (int i = 0; i < kNumLatents; ++i)
            inputs[i] = latents[i];

        inputs[kNumLatents + 0] = wi.x;
        inputs[kNumLatents + 1] = wi.y;
        inputs[kNumLatents + 2] = wi.z;
        inputs[kNumLatents + 3] = wo.x;
        inputs[kNumLatents + 4] = wo.y;
        inputs[kNumLatents + 5] = wo.z;

        float[kHiddenWidth] h0 = layer0.forward(inputs);
        [ForceUnroll]
        for (int i = 0; i < kHiddenWidth; ++i)
            h0[i] = leaky_relu(h0[i]);

        float[kHiddenWidth] h1 = layer1.forward(h0);
        [ForceUnroll]
        for (int i = 0; i < kHiddenWidth; ++i)
            h1[i] = leaky_relu(h1[i]);

        float output[3] = layer2.forward(h1);
        [ForceUnroll]
        for (int i = 0; i < 3; ++i)
            output[i] = output_activation(output[i]);

        return float3(output[0], output[1], output[2]);
    }
};

public struct Network
{
    LatentTexture<kNumLatents> latent_texture;
    Decoder decoder;

    [Differentiable]
    float3 eval(no_diff float2 uv, no_diff float3 wi, no_diff float3 wo)
    {
        float[kNumLatents] latents = latent_texture.sample(uv);
        return decoder.forward(latents, wi, wo);
    }
};

Network network;

float3 sample_env_map(float3 dir)
{
    float2 uv = world_to_latlong_map(float3(dir.x, dir.z, dir.y));
    uv += float2(0.7f, 0.2f);
    return environment_map.SampleLevel(sampler, uv, 0).xyz;
}

ShadingData make_shading_data(float2 uv, float3 wi)
{
    ShadingData sd;
    sd.position = float3(uv, 0.0f);
    sd.view = wi;
    sd.uv = uv;
    sd.shading_frame = Frame(float3(0.0f, 0.0f, 1.0f), float3(1.0f, 0.0f, 0.0f));
    sd.geometric_normal = sd.shading_frame.normal;
    sd.geometric_tangent = float4(sd.shading_frame.tangent, 1.0f);
    sd.front_facing = true;
    return sd;
}

float3 target_eval(float2 uv, float3 wi, float3 wo, inout UniformSampleGenerator sg)
{
    ShadingData sd = make_shading_data(uv, wi);
    let material = MDLCeramicMaterialInstance(sd, true);
    return material.eval(sd, wo, sg);
}

float3 spherical_to_cartesian_rad(float2 theta_phi)
{
    float sin_theta;
    float cos_theta;
    float sin_phi;
    float cos_phi;
    sincos(theta_phi.x, sin_theta, cos_theta);
    sincos(theta_phi.y, sin_phi, cos_phi);
    return float3(sin_theta * cos_phi, sin_theta * sin_phi, cos_theta);
}

float3 rotate_y(float3 v, float angle)
{
    float s;
    float c;
    sincos(angle, s, c);
    return float3(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

float3 rotate_z(float3 v, float angle)
{
    float s;
    float c;
    sincos(angle, s, c);
    return float3(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}

void rusinkiewicz_to_cartesian(float2 h_sph, float2 d_sph, out float3 wi, out float3 wo)
{
    float3 d = spherical_to_cartesian_rad(d_sph);
    float3 half_vector = spherical_to_cartesian_rad(h_sph);
    wi = rotate_z(rotate_y(d, h_sph.x), h_sph.y);
    wo = normalize(2.0f * dot(wi, half_vector) * half_vector - wi);
}

bool sample_uniform_rusinkiewicz(inout UniformSampleGenerator sg, out float3 wi, out float3 wo)
{
    float4 u = next_float4(sg);
    float theta_h = u.x * M_PI * 0.5f;
    float theta_d = u.y * M_PI * 0.5f;
    float phi_h = u.z * M_PI * 2.0f;
    float phi_d = u.w * M_PI * 2.0f;

    rusinkiewicz_to_cartesian(float2(theta_h, phi_h), float2(theta_d, phi_d), wi, wo);
    return min(wi.z, wo.z) > kMinCos;
}

float3 render_sample(float3 wo, float3 material_value)
{
    float uniform_pdf = M_INV_TWO_PI;
    return sample_env_map(wo) * material_value / uniform_pdf;
}

public float3 render_target(int2 pixel, inout float4 accumulator, int counter)
{
    if (any(isnan(accumulator)) || any(isinf(accumulator)))
        accumulator = 0.0f;

    float2 uv = (float2(pixel) + 0.5f) / float2(kImageResolution, kImageResolution);
    float3 wi = normalize(float3(0.5f, 0.5f, 1.0f) - float3(uv, 0.0f));
    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter * 128);

    for (int i = 0; i < 16; ++i)
    {
        float3 wo = next_dir_on_hemisphere(sg);
        float3 value = target_eval(uv, wi, wo, sg);
        float3 radiance = render_sample(wo, value);
        if (all(!isnan(radiance)) && all(!isinf(radiance)))
        {
            accumulator.xyz += radiance;
            accumulator.w += 1.0f;
        }
    }

    return accumulator.w > 0.0f ? accumulator.xyz / accumulator.w : float3(0.0f);
}

public float3 render_neural(int2 pixel, inout float4 accumulator, int counter)
{
    if (any(isnan(accumulator)) || any(isinf(accumulator)))
        accumulator = 0.0f;

    float2 uv = (float2(pixel) + 0.5f) / float2(kImageResolution, kImageResolution);
    float3 wi = normalize(float3(0.5f, 0.5f, 1.0f) - float3(uv, 0.0f));
    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter * 128);

    for (int i = 0; i < 16; ++i)
    {
        float3 wo = next_dir_on_hemisphere(sg);
        float3 value = network.eval(uv, wi, wo);
        float3 radiance = render_sample(wo, value);
        if (all(!isnan(radiance)) && all(!isinf(radiance)))
        {
            accumulator.xyz += radiance;
            accumulator.w += 1.0f;
        }
    }

    return accumulator.w > 0.0f ? accumulator.xyz / accumulator.w : float3(0.0f);
}

public float3 render_latent(int2 pixel, int2 resolution, int channel)
{
    float2 uv = (float2(pixel) + 0.5f) / float2(resolution);
    int2 size = int2(network.latent_texture.values.shape[1], network.latent_texture.values.shape[0]);
    float2 texel_uv = uv * float2(size - 1);

    int2 c0 = clamp(int2(texel_uv), int2(0), size - 1);
    int2 c1 = min(c0 + 1, size - 1);
    float2 f = saturate(texel_uv - float2(c0));

    float v00 = network.latent_texture.values[c0.y, c0.x, channel];
    float v10 = network.latent_texture.values[c0.y, c1.x, channel];
    float v01 = network.latent_texture.values[c1.y, c0.x, channel];
    float v11 = network.latent_texture.values[c1.y, c1.x, channel];
    float value = lerp(lerp(v00, v10, f.x), lerp(v01, v11, f.x), f.y);

    return value < 0.0f ? float3(-value, 0.0f, 0.0f) : float3(0.0f, value, 0.0f);
}

[Differentiable]
float power_log(float x)
{
    float power = 3.0f;
    x = max(x, 0.0f);
    return power * (pow(x, 1.0f / power) - 1.0f);
}

[Differentiable]
float l1_power_log(float3 prediction, float3 reference)
{
    float loss = 0.0f;
    [ForceUnroll]
    for (int i = 0; i < 3; ++i)
        loss += abs(power_log(prediction[i]) - power_log(reference[i]));
    return loss / 3.0f;
}

[Differentiable]
float training_loss(no_diff float2 uv, no_diff float3 wi, no_diff float3 wo, no_diff float3 reference)
{
    float3 prediction = network.eval(uv, wi, wo);
    return l1_power_log(prediction, reference);
}

public void calculate_grads(uint seed, int2 batch_index, int2 batch_size)
{
    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (float2(batch_index) + next_float2(sg)) / float2(batch_size);

    float3 wi;
    float3 wo;
    if (!sample_uniform_rusinkiewicz(sg, wi, wo))
        return;

    float3 reference = target_eval(uv, wi, wo, sg);
    if (any(isnan(reference)) || any(isinf(reference)))
        return;

    bwd_diff(training_loss)(uv, wi, wo, reference, 1.0f);
}

public void compute_error_batch(
    uint seed,
    int2 batch_index,
    int2 batch_size,
    WTensor<float, 2> log_l1_out,
    WTensor<float, 2> valid_out)
{
    log_l1_out[batch_index.y, batch_index.x] = 0.0f;
    valid_out[batch_index.y, batch_index.x] = 0.0f;

    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (float2(batch_index) + next_float2(sg)) / float2(batch_size);

    float3 wi;
    float3 wo;
    if (!sample_uniform_rusinkiewicz(sg, wi, wo))
        return;

    float3 reference = target_eval(uv, wi, wo, sg);
    float3 prediction = network.eval(uv, wi, wo);
    if (any(isnan(reference)) || any(isnan(prediction)) || any(isinf(reference)) || any(isinf(prediction)))
        return;

    float3 log_error = abs(log(1.0f + max(prediction, float3(0.0f))) - log(1.0f + max(reference, float3(0.0f))));

    log_l1_out[batch_index.y, batch_index.x] = (log_error.x + log_error.y + log_error.z) / 3.0f;
    valid_out[batch_index.y, batch_index.x] = 1.0f;
}
