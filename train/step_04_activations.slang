// SPDX-License-Identifier: Apache-2.0

import slangpy;
import materials.materials;
import materials.ceramic.mdl_ceramic_material;
import utracer.utracerutils;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 1
#endif
#include "linear_layer.slang"

static const int kNumLatents = 8;
static const int kNumBsdfLayers = 2;
static const int kBsdfLayerInputs = 14; // normal3, tangent3, albedo3, roughness2, weight3.
static const int kEncoderInputs = kNumBsdfLayers * kBsdfLayerInputs + 1; // + mip level.
static const int kEncoderHidden = 64;
static const int kDecoderHidden = 32;
static const float kMinCos = 1e-3f;
static const float kSmeLUAlpha = 0.5f;
static const float kSmeLUBeta = 0.01f;
static const float kSmeLUA = (1.0f - kSmeLUBeta) / (4.0f * kSmeLUAlpha);
static const float kSmeLUB = (1.0f + kSmeLUBeta) / 2.0f;
static const float kSmeLUC = kSmeLUAlpha * (1.0f - kSmeLUBeta) / 4.0f;
static const float kDecoderOutputScale = 1e5f;

[Differentiable]
float leakyReLU(float x, float negativeSlope = 0.01f)
{
    return x > 0.0f ? x : x * negativeSlope;
}

[Differentiable]
float smeLU(float x)
{
    float left = max(kSmeLUBeta * x, x + kSmeLUAlpha * (1.0f - kSmeLUBeta));
    float middle = kSmeLUA * x * x + kSmeLUB * x + kSmeLUC;
    float right = max(x, kSmeLUAlpha);
    return min(left, min(middle, right));
}

[Differentiable]
float scaledSigmoid(float x)
{
    float negE = exp(-abs(x));
    float pos = kDecoderOutputScale / (kDecoderOutputScale * negE + 1.0f);
    float neg = kDecoderOutputScale * negE / (negE + kDecoderOutputScale);
    return x > 0.0f ? pos : neg;
}

struct Encoder
{
    // NA encoder config: hidden_layers=[64, 64, 64], then a latent output layer.
    LinearLayer<kEncoderInputs, kEncoderHidden> layer0;
    LinearLayer<kEncoderHidden, kEncoderHidden> layer1;
    LinearLayer<kEncoderHidden, kEncoderHidden> layer2;
    LinearLayer<kEncoderHidden, kNumLatents> layer3;

    [Differentiable]
    float[kNumLatents] forward(float[kEncoderInputs] inputs)
    {
        float[kEncoderHidden] output0 = layer0.forward(inputs);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHidden; ++i)
            output0[i] = leakyReLU(output0[i]);

        float[kEncoderHidden] output1 = layer1.forward(output0);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHidden; ++i)
            output1[i] = leakyReLU(output1[i]);

        float[kEncoderHidden] output2 = layer2.forward(output1);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHidden; ++i)
            output2[i] = leakyReLU(output2[i]);

        return layer3.forward(output2);
    }
}

[Differentiable]
static void parameterize(float3 wi, float3 wo, out float3 wh, out float3 wd)
{
    wh = normalize(wi + wo);
    float3 v = float3(wh.y, -wh.x, 0.0f);
    wd = wi * wh.z + cross(v, wi) + dot(v, wi) * v / (1.0f + wh.z);
}

struct Decoder
{
    // Step 03 layout with NA default hidden/output activations.
    LinearLayer<kNumLatents + 6, kDecoderHidden> layer0;
    LinearLayer<kDecoderHidden, kDecoderHidden> layer1;
    LinearLayer<kDecoderHidden, 3> layer2;

    [Differentiable]
    float3 forward(float[kNumLatents] latents, no_diff float3 wi_ws, no_diff float3 wo_ws)
    {
        float3 wh, wd;
        parameterize(wi_ws, wo_ws, wh, wd);

        float encoded_inputs[kNumLatents + 6];
        [ForceUnroll]
        for (int i = 0; i < kNumLatents; ++i)
            encoded_inputs[i] = latents[i];
        encoded_inputs[kNumLatents + 0] = wh.x;
        encoded_inputs[kNumLatents + 1] = wh.y;
        encoded_inputs[kNumLatents + 2] = wh.z;
        encoded_inputs[kNumLatents + 3] = wd.x;
        encoded_inputs[kNumLatents + 4] = wd.y;
        encoded_inputs[kNumLatents + 5] = wd.z;

        float[kDecoderHidden] output0 = layer0.forward(encoded_inputs);
        [ForceUnroll]
        for (int i = 0; i < kDecoderHidden; ++i)
            output0[i] = smeLU(output0[i]);

        float[kDecoderHidden] output1 = layer1.forward(output0);
        [ForceUnroll]
        for (int i = 0; i < kDecoderHidden; ++i)
            output1[i] = smeLU(output1[i]);

        float output2[3] = layer2.forward(output1);
        [ForceUnroll]
        for (int i = 0; i < 3; ++i)
            output2[i] = scaledSigmoid(output2[i]);

        return float3(output2[0], output2[1], output2[2]);
    }
}

struct Network
{
    Encoder encoder;
    Decoder decoder;

    [Differentiable]
    float3 eval(no_diff float[kEncoderInputs] encoder_inputs, no_diff float3 wi_ws, no_diff float3 wo_ws)
    {
        float[kNumLatents] latents = encoder.forward(encoder_inputs);
        return decoder.forward(latents, wi_ws, wo_ws);
    }
}

void pack_layer(
    inout float[kEncoderInputs] inputs,
    inout int index,
    float3 normal,
    float3 tangent,
    float3 albedo,
    float2 roughness,
    float3 weight)
{
    inputs[index++] = normal.x;
    inputs[index++] = normal.y;
    inputs[index++] = normal.z;
    inputs[index++] = tangent.x;
    inputs[index++] = tangent.y;
    inputs[index++] = tangent.z;
    inputs[index++] = albedo.x;
    inputs[index++] = albedo.y;
    inputs[index++] = albedo.z;
    inputs[index++] = roughness.x;
    inputs[index++] = roughness.y;
    inputs[index++] = weight.x;
    inputs[index++] = weight.y;
    inputs[index++] = weight.z;
}

float[kEncoderInputs] collect_encoder_inputs(float2 uv)
{
    float[kEncoderInputs] inputs = {};
    int index = 0;

    ShadingData sd;
    sd.position = float3(uv, 0);
    sd.view = float3(0, 0, 1);
    sd.uv = uv;
    sd.shading_frame = Frame(float3(0, 0, 1), float3(1, 0, 0));
    sd.geometric_normal = sd.shading_frame.normal;
    sd.geometric_tangent = float4(sd.shading_frame.tangent, 1);
    sd.front_facing = true;

    let material = MDLCeramicMaterialInstance(sd, true);
    Optional<ExtraBsdfProperties> extra = material.collect_extra_bsdf_properties(sd, sd.view);

    if (extra.hasValue && extra.value.bsdf_count > 0)
    {
        ExtraBsdfProperties props = extra.value;
        [ForceUnroll]
        for (int layer = 0; layer < kNumBsdfLayers; ++layer)
        {
            if (layer < int(props.bsdf_count))
            {
                pack_layer(
                    inputs,
                    index,
                    props.bsdf_N[layer],
                    props.bsdf_T[layer],
                    props.bsdf_albedo[layer],
                    props.bsdf_roughness[layer],
                    props.bsdf_weight[layer]);
            }
            else
            {
                pack_layer(inputs, index, float3(0), float3(0), float3(0), float2(0), float3(0));
            }
        }
    }
    else
    {
        MaterialProperties props = material.collect_properties(sd);
        pack_layer(
            inputs,
            index,
            props.guide_normal,
            sd.shading_frame.tangent,
            props.diffuse_reflection_albedo + props.specular_reflection_albedo,
            float2(props.roughness),
            float3(1.0f));
        pack_layer(inputs, index, float3(0), float3(0), float3(0), float2(0), float3(0));
    }

    inputs[index++] = 1.0f; // Single-mip sample: original pipeline stores 1 + mip_level.
    return inputs;
}

[Differentiable]
float power_log(float x)
{
    float power = 3.0f;
    return power * (pow(x, 1.f / power) - 1.f);
}

[Differentiable]
float l1PowerWithLog(float3 pred, float3 ref)
{
    float loss = 0.f;
    [ForceUnroll]
    for (int i = 0; i < 3; ++i)
    {
        float r = power_log(ref[i]);
        float p = power_log(pred[i]);
        loss += abs(r - p);
    }
    return loss / 3.0f;
}

SamplerState sampler;
Texture2D<float4> environment_map;

float3 sample_env_map(float3 dir)
{
    // Note: the latlong map is stored with the "up" direction along -y, so we need to swap y and z here.
    float2 uv = world_to_latlong_map(float3(dir.x, dir.z, dir.y));
    uv += float2(0.7, 0.2);
    return environment_map.SampleLevel(sampler, uv, 0).xyz;
}

[Differentiable]
float3 spherical_to_cartesian_rad(float2 sph)
{
    float3 p;
    p.x = -cos(sph.y - M_PI) * sin(sph.x);
    p.y = -sin(sph.y - M_PI) * sin(sph.x);
    p.z = cos(sph.x);
    return p;
}

[Differentiable]
float3 rotate_y(const float3 v, const float angle)
{
    float c, s;
    sincos(angle, s, c);
    return float3(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

[Differentiable]
float3 rotate_z(const float3 v, const float angle)
{
    float c, s;
    sincos(angle, s, c);
    return float3(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}

[Differentiable]
void rusinkiewicz_to_cartesian(const float2 h_sph, const float2 d_sph, out float3 wi, out float3 wo)
{
    float3 d = spherical_to_cartesian_rad(d_sph);
    float3 temp = rotate_y(d, h_sph.x);
    wi = rotate_z(temp, h_sph.y);
    float3 half = spherical_to_cartesian_rad(h_sph);
    wo = normalize(2 * dot(wi, half) * half - wi);
}

bool sample_uniform_rusinkiewicz(float4 u, out float3 wi, out float3 wo)
{
    float theta_h_warp_power = 1.f;
    float theta_h = pow(u.x, theta_h_warp_power) * M_PI * 0.5f;
    float theta_d = u.y * M_PI * 0.5f;
    float phi_h = u.z * M_PI * 2.f;
    float phi_d = u.w * M_PI * 2.f;
    rusinkiewicz_to_cartesian(float2(theta_h, phi_h), float2(theta_d, phi_d), wi, wo);
    return wi.z >= kMinCos && wo.z >= 0.f;
}

bool sample(float2 uv, float3 wi_ws, UniformSampleGenerator sg, out BSDFSample bsdf_sample)
{
    ShadingData sd;
    sd.position = float3(uv, 0);
    sd.view = wi_ws;
    sd.uv = uv;
    sd.shading_frame = Frame(float3(0, 0, 1), float3(1, 0, 0));
    sd.geometric_normal = sd.shading_frame.normal;
    sd.geometric_tangent = float4(sd.shading_frame.tangent, 1);
    sd.front_facing = true;
    let material = MDLCeramicMaterialInstance(sd, true);
    return material.sample(sd, sg, bsdf_sample);
}

float3 eval(float2 uv, float3 wi_ws, float3 wo_ws, UniformSampleGenerator sg)
{
    ShadingData sd;
    sd.position = float3(uv, 0);
    sd.view = wi_ws;
    sd.uv = uv;
    sd.shading_frame = Frame(float3(0, 0, 1), float3(1, 0, 0));
    sd.geometric_normal = sd.shading_frame.normal;
    sd.geometric_tangent = float4(sd.shading_frame.tangent, 1);
    sd.front_facing = true;
    let material = MDLCeramicMaterialInstance(sd, true);
    return material.eval(sd, wo_ws, sg);
}

public float3 render(int2 pixel, inout float4 accumulator, int counter)
{
    if (any(isnan(accumulator)))
        accumulator = 0;

    float2 uv = (float2(pixel) + 0.5f) / float2(1024, 1024);
    float3 pos_ws = float3(uv, 0);
    float3 view_dir = normalize(float3(0.5, 0.5, 1) - pos_ws);
    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter * 128);

    for (int i = 0; i < 16; ++i)
    {
        BSDFSample bsdf_sample = {};
        if (sample(uv, view_dir, sg, bsdf_sample))
        {
            float3 lighting = sample_env_map(bsdf_sample.wo_ws);
            float3 radiance = lighting * bsdf_sample.weight;
            if (all(!isnan(radiance)))
            {
                accumulator.xyz += radiance;
                accumulator.w += 1;
            }
        }
    }
    return accumulator.xyz / accumulator.w;
}

Network network;

float[kNumLatents] eval_latents(float2 uv)
{
    return network.encoder.forward(collect_encoder_inputs(uv));
}

float3 eval_neural(float2 uv, float3 wi_ws, float3 wo_ws)
{
    return network.eval(collect_encoder_inputs(uv), wi_ws, wo_ws);
}

public float3 render_neural(int2 pixel, inout float4 accumulator, int counter)
{
    float2 uv = (float2(pixel) + 0.5f) / float2(1024, 1024);
    float3 pos_ws = float3(uv, 0);
    float3 wi = normalize(float3(0.5, 0.5, 1) - pos_ws);
    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter * 128);

    for (int i = 0; i < 16; ++i)
    {
        float3 wo = square_to_cosine_hemisphere_concentric(next_float2(sg));
        float pdf = square_to_cosine_hemisphere_concentric_pdf(wo);
        float3 weight = eval_neural(uv, wi, wo);
        if (min(wi.z, wo.z) > 0.001f && pdf > 0.001f)
        {
            weight /= pdf;
            float3 lighting = sample_env_map(wo);
            accumulator.xyz += lighting * weight;
            accumulator.w += 1;
        }
    }
    return accumulator.xyz / accumulator.w;
}

[Differentiable]
float3 loss(
    no_diff float[kEncoderInputs] encoder_inputs,
    no_diff float3 wi_ws,
    no_diff float3 wo_ws,
    no_diff float3 reference)
{
    float3 color = network.eval(encoder_inputs, wi_ws, wo_ws);
    return l1PowerWithLog(color, reference);
}

public float3 render_latent(int2 pixel, int2 resolution, int channel)
{
    float2 uv = (float2(pixel) + 0.5f) / float2(resolution);
    float[kNumLatents] latents = eval_latents(uv);
    float val = latents[channel];
    return val < 0 ? float3(-val, 0, 0) : float3(0, val, 0);
}

[numthreads(8, 8, 1)]
public void bake_latent_texture(
    uint3 dispatchThreadID: SV_DispatchThreadID,
    uniform RWTensor<float, 3> latent_texture,
    uniform int2 resolution)
{
    int x = int(dispatchThreadID.x);
    int y = int(dispatchThreadID.y);
    if (x >= resolution.x || y >= resolution.y)
        return;

    float2 uv = (float2(x, y) + 0.5f) / float2(resolution);
    float[kNumLatents] latents = eval_latents(uv);

    [ForceUnroll]
    for (int i = 0; i < kNumLatents; ++i)
        latent_texture[y, x, i] = latents[i];
}

uint3 color_augmentation_indices(float ratio, float sample)
{
    if (sample < ratio)
    {
        sample /= ratio;
        float r = 27.0f * sample;
        return uint3(uint(r / 9), uint(r / 3), uint(r)) % 3;
    }
    return uint3(0, 1, 2);
}

public void calculate_grads(uint seed, int2 batch_index, int2 batch_size, no_diff float color_augmentation_ratio)
{
    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (batch_index + next_float2(sg)) / float2(batch_size);

    float3 wi, wo;
    if (!sample_uniform_rusinkiewicz(next_float4(sg), wi, wo))
        return;

    float3 reference = eval(uv, wi, wo, sg);
    if (isnan(reference.x) || isnan(reference.y) || isnan(reference.z))
        return;

    uint3 idx = color_augmentation_indices(color_augmentation_ratio, next_float(sg));
    reference = float3(reference[idx.x], reference[idx.y], reference[idx.z]);

    float[kEncoderInputs] encoder_inputs = collect_encoder_inputs(uv);
    bwd_diff(loss)(encoder_inputs, wi, wo, reference, 1.0f);
}

public void compute_loss_batch(uint seed, int2 batch_index, int2 batch_size, WTensor<float, 2> loss_out)
{
    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (batch_index + next_float2(sg)) / float2(batch_size);

    float3 wi, wo;
    if (!sample_uniform_rusinkiewicz(next_float4(sg), wi, wo))
        { loss_out[batch_index.y, batch_index.x] = 0.f; return; }

    float3 reference = eval(uv, wi, wo, sg);
    if (isnan(reference.x) || isnan(reference.y) || isnan(reference.z))
        { loss_out[batch_index.y, batch_index.x] = 0.f; return; }

    float3 color = eval_neural(uv, wi, wo);
    loss_out[batch_index.y, batch_index.x] = l1PowerWithLog(color, reference);
}

public void compute_error_batch(
    uint seed,
    int2 batch_index,
    int2 batch_size,
    WTensor<float, 2> log_l1_out,
    WTensor<float, 2> rel_l1_out,
    WTensor<float, 2> mse_out,
    WTensor<float, 2> valid_out)
{
    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (batch_index + next_float2(sg)) / float2(batch_size);

    log_l1_out[batch_index.y, batch_index.x] = 0.0f;
    rel_l1_out[batch_index.y, batch_index.x] = 0.0f;
    mse_out[batch_index.y, batch_index.x] = 0.0f;
    valid_out[batch_index.y, batch_index.x] = 0.0f;

    float3 wi, wo;
    if (!sample_uniform_rusinkiewicz(next_float4(sg), wi, wo))
        return;

    float3 reference = eval(uv, wi, wo, sg);
    float3 prediction = eval_neural(uv, wi, wo);
    if (any(isnan(reference)) || any(isnan(prediction)) || any(isinf(reference)) || any(isinf(prediction)))
        return;

    float3 diff = prediction - reference;
    float3 log_error = abs(log(1.0f + max(prediction, float3(0.0f))) - log(1.0f + max(reference, float3(0.0f))));
    float3 rel_error = abs(diff) / max(abs(reference), float3(1e-3f));
    float3 sq_error = diff * diff;

    log_l1_out[batch_index.y, batch_index.x] = (log_error.x + log_error.y + log_error.z) / 3.0f;
    rel_l1_out[batch_index.y, batch_index.x] = (rel_error.x + rel_error.y + rel_error.z) / 3.0f;
    mse_out[batch_index.y, batch_index.x] = (sq_error.x + sq_error.y + sq_error.z) / 3.0f;
    valid_out[batch_index.y, batch_index.x] = 1.0f;
}

public float adam_update(float primal, float grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    const float ADAM_BETA_1 = 0.9;
    const float ADAM_BETA_2 = 0.999;
    const float ADAM_EPSILON = 1e-8;

    float p = primal;
    float g = grad;

    if (isnan(p))
        p = 0.f;
    if (isnan(g))
        g = 0.f;

    mean = lerp(g, mean, ADAM_BETA_1);
    variance = lerp(g * g, variance, ADAM_BETA_2);

    float mHat = mean / (1.0f - pow(ADAM_BETA_1, iteration));
    float vHat = variance / (1.0f - pow(ADAM_BETA_2, iteration));
    float step = learning_rate * mHat / (sqrt(vHat) + ADAM_EPSILON);

    float new_p = p - step;
    return !isnan(new_p) ? new_p : primal;
}

public void optimizer_step(inout half primal, inout half grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    half new_p = (half)adam_update(float(primal), float(grad), mean, variance, learning_rate, iteration);
    if (!isnan(new_p))
        primal = new_p;
    grad = (half)0.0f;
}
