
import slangpy;
import materials.materials;
import materials.ceramic.mdl_ceramic_material;
import utracer.utracerutils;

#ifndef USE_COOPVEC_LINEAR
#define USE_COOPVEC_LINEAR 1
#endif

#include "neural/common/adam.slang"
#include "neural/common/linear_layer.slang"

static const int kImageResolution = 1024;
static const int kNumLatents = 8;
static const int kNumBsdfLayers = 2;
static const int kBsdfLayerInputs = 14; // normal3, tangent3, albedo3, roughness2, weight3.
static const int kEncoderInputs = kNumBsdfLayers * kBsdfLayerInputs + 1; // + mip level.
static const int kEncoderHiddenWidth = 64;
static const int kHiddenWidth = 32;
static const int kNumRotationFrames = 2;
static const int kRotationFrameElements = 6;
static const int kDecoderDirectionInputs = kNumRotationFrames * 6;
static const float kMinCos = 1e-3f;
static const float kDecoderOutputScale = 1e5f;

SamplerState sampler;
Texture2D<float4> environment_map;

[Differentiable]
float leaky_relu(float x, float negative_slope = 0.01f)
{
    return x > 0.0f ? x : x * negative_slope;
}

[Differentiable]
float scaled_sigmoid(float x)
{
    float neg_exp = exp(-abs(x));
    float positive = kDecoderOutputScale / (kDecoderOutputScale * neg_exp + 1.0f);
    float negative = kDecoderOutputScale * neg_exp / (neg_exp + kDecoderOutputScale);
    return x > 0.0f ? positive : negative;
}

public struct Encoder
{
    LinearLayer<kEncoderInputs, kEncoderHiddenWidth> layer0;
    LinearLayer<kEncoderHiddenWidth, kEncoderHiddenWidth> layer1;
    LinearLayer<kEncoderHiddenWidth, kEncoderHiddenWidth> layer2;
    LinearLayer<kEncoderHiddenWidth, kNumLatents> layer3;

    [Differentiable]
    float[kNumLatents] forward(no_diff float[kEncoderInputs] inputs)
    {
        float[kEncoderHiddenWidth] h0 = layer0.forward(inputs);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHiddenWidth; ++i)
            h0[i] = leaky_relu(h0[i]);

        float[kEncoderHiddenWidth] h1 = layer1.forward(h0);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHiddenWidth; ++i)
            h1[i] = leaky_relu(h1[i]);

        float[kEncoderHiddenWidth] h2 = layer2.forward(h1);
        [ForceUnroll]
        for (int i = 0; i < kEncoderHiddenWidth; ++i)
            h2[i] = leaky_relu(h2[i]);

        return layer3.forward(h2);
    }
};

struct LearnedShadingFrame : IDifferentiable
{
    float3 tangent;
    float3 bitangent;
    float3 normal;

    [Differentiable]
    float3 to_local(float3 w)
    {
        return float3(dot(w, tangent), dot(w, bitangent), dot(w, normal));
    }
};

public struct ShadingFrameRotation
{
    LinearLayer<kNumLatents, kNumRotationFrames * kRotationFrameElements> frame_decoder;

    [Differentiable]
    void decode(float[kNumLatents] latents, out LearnedShadingFrame frames[kNumRotationFrames])
    {
        float[kNumRotationFrames * kRotationFrameElements] values = frame_decoder.forward(latents);

        [ForceUnroll]
        for (int frame = 0; frame < kNumRotationFrames; ++frame)
        {
            int normal_index = 3 * frame;
            int tangent_index = 3 * (frame + kNumRotationFrames);

            float3 n = float3(values[normal_index + 0], values[normal_index + 1], values[normal_index + 2]);
            float3 t = float3(values[tangent_index + 0], values[tangent_index + 1], values[tangent_index + 2]);

            n = normalize(n + float3(0.0f, 0.0f, 1.0f));
            t = normalize(t + float3(1.0f, 0.0f, 0.0f));

            frames[frame].normal = n;
            frames[frame].tangent = t;
            frames[frame].bitangent = cross(n, t);
        }
    }
};

public struct Decoder
{
    LinearLayer<kNumLatents + kDecoderDirectionInputs, kHiddenWidth> layer0;
    LinearLayer<kHiddenWidth, kHiddenWidth> layer1;
    LinearLayer<kHiddenWidth, 3> layer2;

    [Differentiable]
    float3 forward(float[kNumLatents] latents, float3 wh[kNumRotationFrames], float3 wd[kNumRotationFrames])
    {
        float inputs[kNumLatents + kDecoderDirectionInputs];
        [ForceUnroll]
        for (int i = 0; i < kNumLatents; ++i)
            inputs[i] = latents[i];

        int input_index = kNumLatents;
        [ForceUnroll]
        for (int frame = 0; frame < kNumRotationFrames; ++frame)
        {
            inputs[input_index++] = wh[frame].x;
            inputs[input_index++] = wh[frame].y;
            inputs[input_index++] = wh[frame].z;
        }

        [ForceUnroll]
        for (int frame = 0; frame < kNumRotationFrames; ++frame)
        {
            inputs[input_index++] = wd[frame].x;
            inputs[input_index++] = wd[frame].y;
            inputs[input_index++] = wd[frame].z;
        }

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
            output[i] = scaled_sigmoid(output[i]);

        return float3(output[0], output[1], output[2]);
    }
};

[Differentiable]
void rusinkiewicz_parameterize(float3 wi, float3 wo, out float3 wh, out float3 wd)
{
    wh = normalize(wi + wo);
    float3 v = float3(wh.y, -wh.x, 0.0f);
    wd = wi * wh.z + cross(v, wi) + dot(v, wi) * v / (1.0f + wh.z);
}

public struct Network
{
    Encoder encoder;
    ShadingFrameRotation rotation;
    Decoder decoder;

    [Differentiable]
    float3 eval(no_diff float[kEncoderInputs] encoder_inputs, no_diff float3 wi, no_diff float3 wo)
    {
        float[kNumLatents] latents = encoder.forward(encoder_inputs);

        float3 wh;
        float3 wd;
        rusinkiewicz_parameterize(wi, wo, wh, wd);

        LearnedShadingFrame frames[kNumRotationFrames];
        rotation.decode(latents, frames);

        float3 rotated_wh[kNumRotationFrames];
        float3 rotated_wd[kNumRotationFrames];
        [ForceUnroll]
        for (int frame = 0; frame < kNumRotationFrames; ++frame)
        {
            rotated_wh[frame] = frames[frame].to_local(wh);
            rotated_wd[frame] = frames[frame].to_local(wd);
        }

        return decoder.forward(latents, rotated_wh, rotated_wd);
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

void pack_encoder_layer(
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

    ShadingData sd = make_shading_data(uv, float3(0.0f, 0.0f, 1.0f));
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
                pack_encoder_layer(
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
                pack_encoder_layer(inputs, index, float3(0.0f), float3(0.0f), float3(0.0f), float2(0.0f), float3(0.0f));
            }
        }
    }
    else
    {
        MaterialProperties props = material.collect_properties(sd);
        pack_encoder_layer(
            inputs,
            index,
            props.guide_normal,
            sd.shading_frame.tangent,
            props.diffuse_reflection_albedo + props.specular_reflection_albedo,
            float2(props.roughness),
            float3(1.0f));
        pack_encoder_layer(inputs, index, float3(0.0f), float3(0.0f), float3(0.0f), float2(0.0f), float3(0.0f));
    }

    inputs[index++] = 1.0f; // Single-mip sample: original pipeline stores 1 + mip_level.
    return inputs;
}

float[kNumLatents] eval_latents(float2 uv)
{
    return network.encoder.forward(collect_encoder_inputs(uv));
}

float3 eval_neural(float2 uv, float3 wi, float3 wo)
{
    return network.eval(collect_encoder_inputs(uv), wi, wo);
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
        float3 value = eval_neural(uv, wi, wo);
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
    float[kNumLatents] latents = eval_latents(uv);
    float value = latents[channel];

    return value < 0.0f ? float3(-value, 0.0f, 0.0f) : float3(0.0f, value, 0.0f);
}

[numthreads(8, 8, 1)]
public void bake_latent_texture(
    uint3 dispatch_thread_id: SV_DispatchThreadID,
    uniform RWTensor<float, 3> latent_texture,
    uniform int2 resolution)
{
    int x = int(dispatch_thread_id.x);
    int y = int(dispatch_thread_id.y);
    if (x >= resolution.x || y >= resolution.y)
        return;

    float2 uv = (float2(x, y) + 0.5f) / float2(resolution);
    float[kNumLatents] latents = eval_latents(uv);

    [ForceUnroll]
    for (int i = 0; i < kNumLatents; ++i)
        latent_texture[y, x, i] = latents[i];
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
float training_loss(
    no_diff float[kEncoderInputs] encoder_inputs,
    no_diff float3 wi,
    no_diff float3 wo,
    no_diff float3 reference)
{
    float3 prediction = network.eval(encoder_inputs, wi, wo);
    return l1_power_log(prediction, reference);
}

uint3 color_augmentation_indices(float ratio, float sample)
{
    if (sample < ratio)
    {
        sample /= ratio;
        float r = 27.0f * sample;
        return uint3(uint(r / 9.0f), uint(r / 3.0f), uint(r)) % 3;
    }
    return uint3(0, 1, 2);
}

public void calculate_grads(uint seed, int2 batch_index, int2 batch_size, no_diff float color_augmentation_ratio)
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

    uint3 channel_indices = color_augmentation_indices(color_augmentation_ratio, next_float(sg));
    reference = float3(reference[channel_indices.x], reference[channel_indices.y], reference[channel_indices.z]);

    float[kEncoderInputs] encoder_inputs = collect_encoder_inputs(uv);
    bwd_diff(training_loss)(encoder_inputs, wi, wo, reference, 1.0f);
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
    float3 prediction = eval_neural(uv, wi, wo);
    if (any(isnan(reference)) || any(isnan(prediction)) || any(isinf(reference)) || any(isinf(prediction)))
        return;

    float3 log_error = abs(log(1.0f + max(prediction, float3(0.0f))) - log(1.0f + max(reference, float3(0.0f))));

    log_l1_out[batch_index.y, batch_index.x] = (log_error.x + log_error.y + log_error.z) / 3.0f;
    valid_out[batch_index.y, batch_index.x] = 1.0f;
}
