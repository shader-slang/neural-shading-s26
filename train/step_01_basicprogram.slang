// SPDX-License-Identifier: Apache-2.0

import materials.materials;
import materials.ceramic.mdl_ceramic_material;
import utracer.utracerutils;

SamplerState sampler;
Texture2D<float4> environment_map;

float3 sample_env_map(float3 dir)
{
    // Note: the latlong map is stored with the "up" direction along -y, so we need to swap y and z here.
    float2 uv = world_to_latlong_map(float3(dir.x, dir.z, dir.y));
    uv += float2(0.7, 0.2); // Arbitrary offset to the sun in the right place for this demo
    return environment_map.SampleLevel(sampler, uv, 0).xyz;
}

// Render full res BRDF from given inputs.
float3 render(int2 pixel, inout float4 accumulator, int counter)
{
    float2 uv = (float2(pixel) + 0.5f) / float2(1024, 1024);
    
    float3 pos_ws = float3(uv, 0);
    float3 view_dir = normalize(float3(0.5, 0.5, 1) - pos_ws);    

    ShadingData sd;
    sd.position = pos_ws;
    sd.view = view_dir;
    sd.uv = uv;
    sd.shading_frame = Frame(float3(0, 0, 1), float3(1, 0, 0));
    sd.geometric_normal = sd.shading_frame.normal;
    sd.geometric_tangent = float4(sd.shading_frame.tangent,1);
    sd.front_facing = true;

    let material = make_instance(sd, true);

    UniformSampleGenerator sg = UniformSampleGenerator(pixel, counter*128);
    for(int i = 0; i < 128; ++i)
    {
        // Using sampler as normal
        BSDFSample bsdf_sample = {};
        if (material.sample(sd, sg, bsdf_sample))
        {
            float3 lighting = sample_env_map(bsdf_sample.wo_ws);
            accumulator.xyz += lighting * bsdf_sample.weight;
            accumulator.w += 1;
        }

        // I expected this to effectively do the same thing, but take longer to converge
        //float3 wo = square_to_cosine_hemisphere_concentric(next_float2(sg));
        //float pdf = square_to_cosine_hemisphere_concentric_pdf(wo);
        //float3 weight = material.eval(sd, wo, sg);
        //if (min(sd.view.z, wo.z) > 0.001f && pdf > 0.001f)
        //{
        //    weight /= pdf;
        //    float3 lighting = sample_env_map(wo);
        //    accumulator.xyz += lighting * weight;
        //    accumulator.w += 1;
        //}
    }
    return accumulator.xyz / accumulator.w;
}
