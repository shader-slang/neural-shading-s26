// SPDX-License-Identifier: Apache-2.0

import slangpy;
import materials.materials;
import materials.ceramic.mdl_ceramic_material;
import utracer.utracerutils;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 1
#endif
#include "linear_layer.slang"

public struct LatentTexture<int NumLatents> {
    RWTensor<float, 3> texture;

    AtomicTensor<float, 3> texture_grads;

    [BackwardDerivative(get_latent_bwd)]
    float get_latent(int x, int y, int latent_index)
    {
        return texture[y, x, latent_index];
    }

    void get_latent_bwd(int x, int y, int latent_index, float latent_grad)
    {
        if(!isnan(latent_grad))
            texture_grads.add( y, x, latent_index, latent_grad);
    }

    [Differentiable]
    float[NumLatents] sample(no_diff inout float2 uv)
    {
        int2 size = { texture.shape[1], texture.shape[0] };
        // Convert to (fractional) texel position
        uv *= float2(size - 1);
        // Get (clamped) integer positions of texel corners
        int2 c0 = clamp(int2(uv), int2(0), size - 1);
        int2 c1 = min(c0 + 1, size - 1);

        // Get fractional part of texel position for interpolation
        uv = saturate(uv - float2(c0));

        float result[NumLatents];
        [ForceUnroll]
        for (int i = 0; i < NumLatents; ++i) {
            // Simple linear interpolation of latent texture
            float latent00 = get_latent(c0.x, c0.y, i);
            float latent10 = get_latent(c1.x, c0.y, i);
            float latent01 = get_latent(c0.x, c1.y, i);
            float latent11 = get_latent(c1.x, c1.y, i);
            result[i] = lerp(lerp(latent00, latent10, uv.x), lerp(latent01, latent11, uv.x), uv.y);
        }

        return result;
    }
}

[Differentiable]
static void parameterize(float3 wi, float3 wo, out float3 wh, out float3 wd)
{
    // Compute half-vector.
    wh = normalize(wi + wo);

    // Compute the difference vector from wi by the smallest rotation that
    // brings wh to Z. Numerically stable version of rotating wi by
    // acos(wi.z) around cross(wh, Z).
    float3 v = float3(wh.y, -wh.x, 0.f);
    wd = wi * wh.z + cross(v, wi) + dot(v, wi) * v / (1.f + wh.z);
}

struct Network {
    static const int NumLatents = 8;

    LatentTexture<NumLatents> latent_texture;
    // NA decoder config: hidden_layers=[32, 32], then a separate RGB output layer.
    LinearLayer<NumLatents+6, 32> layer0;
    LinearLayer<32, 32> layer1;
    LinearLayer<32, 3> layer2;

    [Differentiable]
    float3 eval(no_diff float2 uv, no_diff float3 wi_ws, no_diff float3 wo_ws)
    {
        float3 wh, wd;
        parameterize(wi_ws, wo_ws, wh, wd);

        float encoded_latents[NumLatents] = latent_texture.sample(uv);
        float encoded_inputs[NumLatents + 6];
        [ForceUnroll]
        for (int i = 0; i < NumLatents; ++i)
            encoded_inputs[i] = encoded_latents[i];
        encoded_inputs[NumLatents + 0] = wh.x;
        encoded_inputs[NumLatents + 1] = wh.y;
        encoded_inputs[NumLatents + 2] = wh.z;
        encoded_inputs[NumLatents + 3] = wd.x;
        encoded_inputs[NumLatents + 4] = wd.y;
        encoded_inputs[NumLatents + 5] = wd.z;

        float output0[32] = layer0.forward(encoded_inputs);
        [ForceUnroll]
        for (int i = 0; i < 32; ++i)
            output0[i] = leakyReLU(output0[i]);
        float output1[32] = layer1.forward(output0);
        [ForceUnroll]
        for (int i = 0; i < 32; ++i)
            output1[i] = leakyReLU(output1[i]);
        float output2[3] = layer2.forward(output1);
        [ForceUnroll]
        for (int i = 0; i < 3; ++i)
            output2[i] = exp(output2[i]);
        return float3(output2[0], output2[1], output2[2]);
    }
}

[Differentiable]
float reLU(float x)
{
    return max(x, 0.0f);
}

[Differentiable]
float leakyReLU(float x, float negativeSlope = 0.01f)
{
    if (x > 0.0f)
        return x;
    else
        return x * negativeSlope;
}

// Approximates ln(x) for power -> inf.
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
        float diff = abs(r - p);
        loss += diff;
    }
    return loss/3.0f;
}

SamplerState sampler;
Texture2D<float4> environment_map;

float3 sample_env_map(float3 dir)
{
    // Note: the latlong map is stored with the "up" direction along -y, so we need to swap y and z here.
    float2 uv = world_to_latlong_map(float3(dir.x, dir.z, dir.y));
    uv += float2(0.7, 0.2); // Arbitrary offset to the sun in the right place for this demo
    return environment_map.SampleLevel(sampler, uv, 0).xyz;
}

static const float kMinCos = 1e-3f;

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

// Sample the reference BRDF with a given uv/pos/wi
// Outputs weights and wo
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

// Render full res BRDF from given inputs.
public float3 render(int2 pixel, inout float4 accumulator, int counter)
{
    if (any(isnan(accumulator)))
        accumulator = 0;

    float2 uv = (float2(pixel) + 0.5f) / float2(1024, 1024);
    float3 pos_ws = float3(uv, 0);
    float3 view_dir = normalize(float3(0.5, 0.5, 1) - pos_ws);
    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter*128);
    for(int i = 0; i < 16; ++i)
    {
        BSDFSample bsdf_sample = {};
        if(sample(uv, view_dir, sg, bsdf_sample))
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

[Differentiable]
float3 eval_neural(float2 uv, float3 wi_ws, float3 wo_ws)
{
    return network.eval(uv, wi_ws, wo_ws);
}

// Render full res BRDF from given inputs.
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
float3 gamma_correct(float3 color)
{
    return pow(color, 1.0f / 2.2f);
}

[Differentiable]
float3 loss(no_diff float2 uv, no_diff float3 wi_ws, no_diff float3 wo_ws, no_diff float3 reference)
{
    float3 color = eval_neural(uv, wi_ws, wo_ws);
    return l1PowerWithLog(color, reference);
}

// Render a single latent texture channel with red/green coloring
public float3 render_latent(int2 pixel, int2 resolution, int channel)
{
    float2 uv = (float2(pixel) + 0.5f) / float2(resolution);
    int2 size = {network.latent_texture.texture.shape[1], network.latent_texture.texture.shape[0]};

    // Bilinear interpolation
    uv *= float2(size - 1);
    int2 c0 = clamp(int2(uv), int2(0), size - 1);
    int2 c1 = min(c0 + 1, size - 1);
    float2 f = saturate(uv - float2(c0));

    float v00 = network.latent_texture.texture[c0.y, c0.x, channel];
    float v10 = network.latent_texture.texture[c0.y, c1.x, channel];
    float v01 = network.latent_texture.texture[c1.y, c0.x, channel];
    float v11 = network.latent_texture.texture[c1.y, c1.x, channel];
    float val = lerp(lerp(v00, v10, f.x), lerp(v01, v11, f.x), f.y);

    // Red for negative, green for positive
    if (val < 0)
        return float3(-val, 0, 0);
    else
        return float3(0, val, 0);
}

// Returns a channel remapping as 3 indices (each 0, 1, or 2).
// With probability `ratio`, draws a random mapping from 27 possibilities
// (all permutations and duplications of RGB channels).
// Otherwise returns the identity mapping (0, 1, 2).
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
    // Pick a random pixel for computing the loss
    // First, sample a random UV within our cell of the training batch grid
    UniformSampleGenerator sg = UniformSampleGenerator(batch_index, seed);
    float2 uv = (batch_index + next_float2(sg)) / float2(batch_size);

    // Generate a random world in dir
    float3 wi, wo;
    
    if(!sample_uniform_rusinkiewicz(next_float4(sg), wi, wo))
        return;

    //wi = next_dir_on_hemisphere(sg);
    //wo = next_dir_on_hemisphere(sg);
    //if(min(wi.z, wo.z) < 0.001f)
    //    return;

    // Sample the reference BRDF with the same random inputs to get the sampled
    // world out and corresponding weight
    float3 reference = eval(uv, wi, wo, sg);
    if(isnan(reference.x) || isnan(reference.y) || isnan(reference.z))
        return;

    // Apply color channel augmentation: randomly permute/duplicate RGB channels
    // to encourage the network to treat all channels with equal importance.
    uint3 idx = color_augmentation_indices(color_augmentation_ratio, next_float(sg));
    reference = float3(reference[idx.x], reference[idx.y], reference[idx.z]);

    // Backpropagate through the loss
    bwd_diff(loss)(uv, wi, wo, reference, 1.0f);
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
    // Default Adam values.
    const float ADAM_BETA_1 = 0.9;
    const float ADAM_BETA_2 = 0.999;
    const float ADAM_EPSILON = 1e-8;

    float p = primal;
    float g = grad;

    if(isnan(p))
        p = 0.f;
    if(isnan(g))
        g = 0.f;

    // Running average of gradient and square gradient (== variance)
    mean = lerp(g, mean, ADAM_BETA_1);
    variance = lerp(g * g, variance, ADAM_BETA_2);

    // The running average is initialized with zeros, and underestimates
    // the true values at the beginning. Adam divides by a compensation factor
    float mHat = mean / (1.0f - pow(ADAM_BETA_1, iteration));
    float vHat = variance / (1.0f - pow(ADAM_BETA_2, iteration));
    // Compute the adam step by scaling the mean gradient by the learning rate and the variance estimate
    float step = learning_rate * mHat / (sqrt(vHat) + ADAM_EPSILON);

    float new_p = p - step;
    return !isnan(new_p) ? new_p : primal;
}

public void optimizer_step(inout half primal, inout half grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    // Take an adam step and cast back to half
    half new_p = (half)adam_update(float(primal), float(grad), mean, variance, learning_rate, iteration);
    if(!isnan(new_p))
        primal = new_p;

    // Because we now accumulate gradients, we need to clear the gradient to zero before the next iteration
    grad = (half)0.0f;
}

public void optimizer_step_float(inout float primal, inout float grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    primal = adam_update(primal, grad, mean, variance, learning_rate, iteration);
    grad = 0.0f;
}

[numthreads(1, 8, 8)]
public void latent_optimizer_kernel(uint3 dispatch_thread_id: SV_DispatchThreadID,
    uniform LatentTexture<Network.NumLatents> latent_texture,
    uniform RWTensor<float,3> means,
    uniform RWTensor<float,3> variances,
    uniform float learning_rate,
    uniform int iteration)
{
    int channel = dispatch_thread_id.x;
    int x = dispatch_thread_id.y;
    int y = dispatch_thread_id.z;

    int2 resolution = int2(latent_texture.texture.shape[1], latent_texture.texture.shape[0]);
    if (x >= resolution.x || y >= resolution.y || channel >= Network.NumLatents)
        return;

    // Get the current value and gradient for this latent texel
    float primal = latent_texture.texture[y, x, channel];
    float grad = latent_texture.texture_grads[y, x, channel];
    float mean = means[y, x, channel];
    float variance = variances[y, x, channel];

    optimizer_step_float(primal, grad, mean, variance, learning_rate, iteration);

    // Write the updated value back to the latent texture
    latent_texture.texture[y, x, channel] = primal;
    latent_texture.texture_grads[y, x, channel] = 0.0f;
    means[y, x, channel] = mean;
    variances[y, x, channel] = variance;
}
