// utracer.slang -- Micro Path Tracer
//
// Scene, intersection, path tracing, rendering, accumulator + tonemap.
// No dependency on falcor2.

import slangpy;
import utracerutils;
import utracermaterial;
__exported import neural_baked_material;

#define DEFAULT_MATERIAL 0
#define MDL_VELVET_MATERIAL 1
#define MDL_CERAMIC_MATERIAL 2
#define NEURAL_BAKED_MATERIAL 3

#define USED_MATERIAL DEFAULT_MATERIAL

#if USED_MATERIAL != DEFAULT_MATERIAL
import materials.materials;
#if USED_MATERIAL == MDL_VELVET_MATERIAL
import materials.velvet.mdl_velvet_material;
#elif USED_MATERIAL == MDL_CERAMIC_MATERIAL
import materials.ceramic.mdl_ceramic_material;
#else
#error "Invalid material selection"
#endif
#endif

// ============================================================================
// Scene types
// ============================================================================

/// Vertex data stored in structured buffer.
public struct Vertex
{
    public float3 position;
    public float3 normal;
    public float3 tangent;
    public float3 bitangent;
    public float3 color;
    public float2 uv;
}

/// Interpolated vertex data in world space.
public struct VertexData
{
    public float3 pos_ws;
    public float3 normal_ws;
    public float3 tangent_ws;
    public float3 bitangent_ws;
    public float3 face_normal_ws;
    public float3 color;
    public float2 uv;
}

/// Hit information from ray intersection.
public struct HitInfo
{
    public bool valid;
    public float2 bary;
    public float t;
    public uint primitive_index;
};

/// Pinhole camera.
public struct Camera
{
    public float3 position;
    public float3 image_u;
    public float3 image_v;
    public float3 image_w;
    public int2 dims;

    public Ray get_ray(float2 uv)
    {
        uv = uv * 2 - 1;
        float3 dir = normalize(uv.x * image_u + uv.y * image_v + image_w);
        return Ray(position, dir);
    }
}

// ============================================================================
// Scene struct
// ============================================================================

/// Global scene parameter block.
public ParameterBlock<Scene> g_scene;

public struct Scene
{
    /// Top-level acceleration structure.
    public RaytracingAccelerationStructure tlas;

    /// Vertex buffer (single mesh).
    public StructuredBuffer<Vertex> vertices;

    /// Index buffer (single mesh).
    public StructuredBuffer<uint> indices;

    /// Single material.
    public MaterialData material;

    /// Runtime material mode. Non-neural modes use USED_MATERIAL for the MDL branch.
    public uint material_mode;

    /// Baked neural material, used when material_mode == NEURAL_BAKED_MATERIAL.
    public BakedNeuralMaterial neural_material;

    /// Shared texture sampler (bilinear, wrap).
    public SamplerState sampler;

    /// Environment map.
    public EnvMap env_map;

    /// Get vertex data for a hit by barycentric interpolation.
    public VertexData get_vertex_data(HitInfo hit)
    {
        uint i0 = indices[hit.primitive_index * 3 + 0];
        uint i1 = indices[hit.primitive_index * 3 + 1];
        uint i2 = indices[hit.primitive_index * 3 + 2];
        Vertex v0 = vertices[i0];
        Vertex v1 = vertices[i1];
        Vertex v2 = vertices[i2];

        float3 b = float3(1.0 - hit.bary.x - hit.bary.y, hit.bary.x, hit.bary.y);

        VertexData vertex = {};
        vertex.pos_ws = b.x * v0.position + b.y * v1.position + b.z * v2.position;
        vertex.normal_ws = normalize(b.x * v0.normal + b.y * v1.normal + b.z * v2.normal);
        vertex.tangent_ws = normalize(b.x * v0.tangent + b.y * v1.tangent + b.z * v2.tangent);
        vertex.bitangent_ws = normalize(b.x * v0.bitangent + b.y * v1.bitangent + b.z * v2.bitangent);
        vertex.face_normal_ws = normalize(cross(v1.position - v0.position, v2.position - v0.position));
        vertex.color = b.x * v0.color + b.y * v1.color + b.z * v2.color;
        vertex.uv = b.x * v0.uv + b.y * v1.uv + b.z * v2.uv;
        return vertex;
    }

    /// Sample a material texture.
    float4 sample_material_texture(Texture2D<float4> tex, float2 uv)
    {
        uv.y = 1 - uv.y;
        return tex.SampleLevel(sampler, uv, 0);
    }

    /// Get unpacked material at given UV.
    public Material get_material(float2 uv)
    {
        Material mat = {};
        mat.albedo = sample_material_texture(material.albedo, uv).xyz;
        mat.roughness = sample_material_texture(material.roughness, uv).x;
        mat.metallic = sample_material_texture(material.metallic, uv).x;
        mat.specular = sample_material_texture(material.specular, uv).xyz;

        // Normal map: convert from [0,1] to [-1,1] and apply strength
        float4 normal_sample = sample_material_texture(material.normal, uv);
        float3 n = normal_sample.xyz * 2.0 - 1.0;
        n.xy *= material.normal_map_strength;
        mat.normal = normalize(n);

        return mat;
    }
};

// ============================================================================
// Environment map
// ============================================================================

/// Environment map.
public struct EnvMap
{
    /// Environment map texture.
    Texture2D<float4> texture;

    /// Scaling factor for radiance.
    float3 scaling_factor;

    /// Whether the env map has a valid texture.
    bool valid;

    /// Evaluate radiance at UV coordinate.
    public float3 eval(float2 uv)
    {
        return texture.SampleLevel(g_scene.sampler, uv, 0).xyz * scaling_factor;
    }

    /// Evaluate radiance from world-space direction.
    public float3 eval(float3 dir_ws)
    {
        return eval(world_to_latlong_map(dir_ws));
    }

    /// Check if the env map has a texture assigned.
    public bool is_valid()
    {
        return valid;
    }
};

// ============================================================================
// Intersector
// ============================================================================

/// Inline ray-query intersection (single mesh, force opaque).
HitInfo intersect(Ray ray)
{
    RayQuery<RAY_FLAG_FORCE_OPAQUE> q;
    q.TraceRayInline(g_scene.tlas, 0, 0xff, ray.to_ray_desc());
    q.Proceed();

    HitInfo hit = {};
    if (q.CommittedStatus() == COMMITTED_TRIANGLE_HIT)
    {
        hit.valid = true;
        hit.bary = q.CommittedTriangleBarycentrics();
        hit.t = q.CommittedRayT();
        hit.primitive_index = q.CommittedPrimitiveIndex();
    }
    return hit;
}

// ============================================================================
// Path tracer
// ============================================================================

/// Maximum path depth.
public extern static const uint MAX_DEPTH = 5;

/// Basic bent normal adjustment.
float3 adjust_normal(float3 wi, float3 geom_normal, float3 shading_normal)
{
    const float kCosThetaThreshold = 0.01;
    float cosTheta = dot(-wi, shading_normal);
    if (cosTheta <= kCosThetaThreshold)
    {
        float t = saturate(cosTheta / kCosThetaThreshold);
        return normalize(lerp(geom_normal, shading_normal, t));
    }
    else
    {
        return shading_normal;
    }
}

/// Trace a path through the scene.
void trace_path(Ray ray, uint2 id, inout UniformSampleGenerator sg, out float3 color)
{
    float3 throughput = float3(1, 1, 1);
    float3 radiance = float3(0, 0, 0);

    uint depth = 1;
    [MaxIters(MAX_DEPTH)]
    while (depth <= MAX_DEPTH)
    {
        HitInfo hit = intersect(ray);

        if (!hit.valid)
        {
            // Background: environment map
            if (g_scene.env_map.is_valid())
                radiance += throughput * g_scene.env_map.eval(ray.dir);
            break;
        }

        VertexData v = g_scene.get_vertex_data(hit);

        if (g_scene.material_mode == NEURAL_BAKED_MATERIAL)
        {
            Frame frame = Frame(v.normal_ws, v.tangent_ws);
            float3 wi = frame.to_local(-ray.dir);
            float3 wo = square_to_cosine_hemisphere_concentric(next_float2(sg));
            float pdf = square_to_cosine_hemisphere_concentric_pdf(wo);
            if (min(wi.z, wo.z) <= 0.001f || pdf <= 0.001f)
                break;

            float3 weight = g_scene.neural_material.eval(v.uv, wi, wo) / pdf;
            if (any(isnan(weight)) || any(isinf(weight)))
                break;
            weight = clamp(weight, 0, 128);

            throughput *= weight;
            ray = Ray(offset_ray_origin(v.pos_ws, v.face_normal_ws), frame.to_global(wo));
        }
        else
        {
#if USED_MATERIAL == DEFAULT_MATERIAL
            Material mat = g_scene.get_material(v.uv);

            // Build shading frame with normal mapping
            Frame frame = Frame(v.normal_ws, v.tangent_ws);
            float3 adj_normal = normalize(frame.to_global(mat.normal));
            adj_normal = adjust_normal(ray.dir, v.face_normal_ws, adj_normal);
            frame = Frame(adj_normal, v.tangent_ws);

            float3 wi = frame.to_local(-ray.dir);

            // BRDF sampling
            DiffuseSpecularBRDF brdf = DiffuseSpecularBRDF(
                mat.albedo * v.color,
                mat.specular,
                mat.metallic,
                mat.roughness);

            float3 wo;
            float pdf;
            float3 weight;
            if (!brdf.sample(wi, wo, pdf, weight, sg))
                break;

            throughput *= weight;

            // Spawn new ray
            ray = Ray(offset_ray_origin(v.pos_ws, v.face_normal_ws), frame.to_global(wo));
#else
            ShadingData sd_ws = {};
            sd_ws.position = ray.origin + hit.t * ray.dir;
            sd_ws.view = -ray.dir;
            sd_ws.uv = v.uv;
            sd_ws.shading_frame = Frame(v.normal_ws, v.tangent_ws);
            sd_ws.geometric_normal = v.face_normal_ws;
            sd_ws.geometric_tangent = float4(v.tangent_ws, 1);
            sd_ws.front_facing = dot(ray.dir, v.face_normal_ws) < 0;
            sd_ws.ior = 1.0; // Assume air for simplicity

            let mi = MDLCeramicMaterialInstance(sd_ws);

            // Eval version (using cosine hemisphere sampling)
            float3 wo = square_to_cosine_hemisphere_concentric(next_float2(sg));
            float pdf = square_to_cosine_hemisphere_concentric_pdf(wo);
            float3 wo_ws = sd_ws.shading_frame.to_global(wo);
            float3 weight = mi.eval(sd_ws, wo_ws, sg);
            if (dot(wo_ws, v.normal_ws) <= 0.001f || pdf <= 0.001f)
                break;
            weight /= pdf;
            if (any(isnan(weight)) || any(isinf(weight)))
                break;
            weight = clamp(weight, 0, 128); // Avoid extreme values that can cause fireflies

            // Apply weight and spawn new ray
            throughput *= weight;
            ray = Ray(offset_ray_origin(v.pos_ws, v.face_normal_ws), wo_ws);
#endif
        }

        depth++;
    }

    color = radiance;
}

// ============================================================================
// Camera extension for slangpy dispatch
// ============================================================================

public extension Camera
{
    public void __slangpy_load(Context2D context, out RaySampler value)
    {
        value.camera = this;
        value.id = context.call_id_vec;

        float2 pix_size = 1.0 / this.dims;
        float2 uv = float2(context.call_id_vec) / this.dims;
        uv.y = 1 - uv.y;
        value.uv = uv;
        value.distribution = pix_size;
    }
    public void __slangpy_store(Context2D context, in RaySampler value) {};
}

public struct RaySampler
{
    public Camera camera;
    public uint2 id;
    public float2 uv;
    public float2 distribution;

    public Ray sample_ray(inout UniformSampleGenerator sg)
    {
        float2 offset = next_float2(sg) * float2(1, -1);
        float2 uv = this.uv + offset * this.distribution;
        return camera.get_ray(uv);
    }
}
// ============================================================================
// Main render entry point
// ============================================================================

/// Render entry point: N samples per pixel of forward path tracing.
public void render(
    RaySampler ray_sampler,
    out float4 output,
    uniform uint spp,
    uniform uint iteration)
{
    float3 radiance = 0;
    for (uint i = 0; i < spp; i++)
    {
        UniformSampleGenerator sg = UniformSampleGenerator(ray_sampler.id, iteration * spp + i);
        Ray ray = ray_sampler.sample_ray(sg);
        float3 color;
        trace_path(ray, ray_sampler.id, sg, color);
        radiance += color;
    }
    output = float4(radiance / float(spp), 1);
}

// ============================================================================
// Denoiser -- edge-aware a-trous wavelet filter
// ============================================================================

/// Single pass of the a-trous wavelet filter.
/// Run multiple passes with stepWidth = 1, 2, 4, 8, ... for increasing blur radius.
public void denoise_atrous(
    uint2 dispatchThreadID,
    Texture2D<float4> input,
    RWTexture2D<float4> output,
    uniform int step_width,
    uniform float color_sigma,
    uniform float kernel_sigma)
{
    uint2 dims;
    input.GetDimensions(dims.x, dims.y);
    if (any(dispatchThreadID >= dims))
        return;

    // 5x5 a-trous kernel weights (B3 spline)
    static const float kernel[5] = { 1.0 / 16.0, 4.0 / 16.0, 6.0 / 16.0, 4.0 / 16.0, 1.0 / 16.0 };

    float3 center_color = input[dispatchThreadID].xyz;
    float3 sum = float3(0.0);
    float weight_sum = 0.0;

    for (int j = -2; j <= 2; j++)
    {
        for (int i = -2; i <= 2; i++)
        {
            int2 offset = int2(i, j) * step_width;
            int2 sample_pos = int2(dispatchThreadID) + offset;

            // Clamp to image bounds
            sample_pos = clamp(sample_pos, int2(0), int2(dims) - 1);

            float3 sample_color = input[sample_pos].xyz;

            // Spatial kernel weight
            float spatial_w = kernel[i + 2] * kernel[j + 2];

            // Color-distance edge-stopping weight
            float3 diff = center_color - sample_color;
            float dist2 = dot(diff, diff);
            float color_w = exp(-dist2 / (color_sigma * color_sigma + 1e-6));

            float w = spatial_w * color_w;
            sum += sample_color * w;
            weight_sum += w;
        }
    }

    output[dispatchThreadID] = float4(sum / max(weight_sum, 1e-6), 1.0);
}

// ============================================================================
// Accumulator + tonemap
// ============================================================================

/// Reset the accumulator buffer.
public void accumulator_reset(out float4 accumulator)
{
    accumulator = 0;
}

/// Read accumulated result.
public void accumulator_output(float4 accumulator, out float4 output)
{
    output = float4(accumulator.xyz / accumulator.w, 1.0);
}

/// Add a new sample to the accumulator.
public void accumulator_update(float4 input, inout float4 accumulator)
{
    accumulator += float4(input.xyz, 1.0);
}

/// Apply ACES tone mapping.
public void apply_tonemap(float4 input, out float4 output)
{
    output = float4(tonemap_aces_film(input.xyz), 1.0);
}

/// Copy texture to texture with optional tone mapping (for viewer blit).
public void resample_rgb(
    uint2 dispatchThreadID,
    Texture2D<float4> input,
    SamplerState input_sampler,
    RWTexture2D<float4> output,
    uniform uint2 output_pos,
    uniform uint2 output_size,
    uniform float scale,
    uniform bool set_abs,
    uniform bool tone_map)
{
    uint2 output_dimensions;
    output.GetDimensions(output_dimensions.x, output_dimensions.y);
    if (any(dispatchThreadID >= output_dimensions))
        return;

    if (any(dispatchThreadID >= output_size))
        return;

    // Map output pixel to input pixel via normalized UV
    float2 uv = (float2(dispatchThreadID) + 0.5) / float2(output_size);

    float4 color = input.SampleLevel(input_sampler, uv, 0);
    color.xyz *= scale;

    if (set_abs)
        color.xyz = abs(color.xyz);

    if (tone_map)
        color.xyz = tonemap_aces_film(color.xyz);

    output[output_pos + dispatchThreadID] = color;
}
