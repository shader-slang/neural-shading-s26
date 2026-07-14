// utracermaterial.slang -- Material types, Fresnel, GGX, and BRDF for utracer
//
// No dependency on falcor2.

import utracerutils;

// ============================================================================
// Fresnel & GGX microfacet
// ============================================================================

/// Schlick Fresnel approximation (float3 version).
float3 eval_fresnel_schlick(float3 f0, float3 f90, float cos_theta)
{
    return f0 + (f90 - f0) * pow(max(1 - cos_theta, 0), 5);
}

/// Schlick Fresnel approximation (float version).
float eval_fresnel_schlick(float f0, float f90, float cos_theta)
{
    return f0 + (f90 - f0) * pow(max(1 - cos_theta, 0), 5);
}

/// GGX (Trowbridge-Reitz) normal distribution function.
float evalNdfGGX(float alpha, float cosTheta)
{
    float a2 = alpha * alpha;
    float d = ((cosTheta * a2 - cosTheta) * cosTheta + 1);
    return a2 / (d * d * M_PI);
}

/// PDF for sampling GGX VNDF.
float evalPdfGGX_VNDF(float alpha, float3 wi, float3 h)
{
    float G1 = evalG1GGX(alpha * alpha, wi.z);
    float D = evalNdfGGX(alpha, h.z);
    return G1 * D * max(0.0, dot(wi, h)) / wi.z;
}

/// Helper for VNDF hemisphere sampling (Dupuy & Benyoub 2023).
float3 SampleVndf_Hemisphere(float2 u, float3 Vh)
{
    float phi = 2.0 * M_PI * u.x;
    float z = fma((1.0 - u.y), (1.0 + Vh.z), -Vh.z);
    float sinTheta = sqrt(saturate(1.0 - z * z));
    float x = sinTheta * cos(phi);
    float y = sinTheta * sin(phi);
    float3 c = float3(x, y, z);
    float3 h = c + Vh;
    return h;
}

/// Sample GGX VNDF (Dupuy & Benyoub 2023 spherical caps method).
float3 sampleGGX_VNDF(float alpha, float3 wi, float2 u, out float pdf)
{
    float alpha_x = alpha, alpha_y = alpha;
    float3 Vh = normalize(float3(alpha_x * wi.x, alpha_y * wi.y, wi.z));
    float3 Nh = SampleVndf_Hemisphere(u, Vh);
    float3 h = normalize(float3(alpha_x * Nh.x, alpha_y * Nh.y, Nh.z));
    pdf = evalPdfGGX_VNDF(alpha, wi, h);
    return h;
}

/// Smith G1 masking function for GGX.
float evalG1GGX(float alphaSqr, float cosTheta)
{
    if (cosTheta <= 0)
        return 0;
    float cosThetaSqr = cosTheta * cosTheta;
    float tanThetaSqr = max(1 - cosThetaSqr, 0) / cosThetaSqr;
    return 2 / (1 + sqrt(1 + alphaSqr * tanThetaSqr));
}

/// Smith Lambda function for GGX.
float evalLambdaGGX(float alphaSqr, float cosTheta)
{
    if (cosTheta <= 0)
        return 0;
    float cosThetaSqr = cosTheta * cosTheta;
    float tanThetaSqr = max(1 - cosThetaSqr, 0) / cosThetaSqr;
    return 0.5 * (-1 + sqrt(1 + alphaSqr * tanThetaSqr));
}

/// Height-correlated Smith masking-shadowing for GGX.
float evalMaskingSmithGGXCorrelated(float alpha, float cosThetaI, float cosThetaO)
{
    float alphaSqr = alpha * alpha;
    float lambdaI = evalLambdaGGX(alphaSqr, cosThetaI);
    float lambdaO = evalLambdaGGX(alphaSqr, cosThetaO);
    return 1 / (1 + lambdaI + lambdaO);
}

// ============================================================================
// Material types
// ============================================================================

/// Material data with directly bound textures.
public struct MaterialData
{
    public Texture2D<float4> albedo;
    public Texture2D<float4> roughness;
    public Texture2D<float4> metallic;
    public Texture2D<float4> specular;
    public Texture2D<float4> normal;
    public float normal_map_strength;
}

/// Unpacked material values (after texture sampling).
public struct Material
{
    public float3 albedo;
    public float3 specular;
    public float3 normal;
    public float roughness;
    public float metallic;
}

// ============================================================================
// BRDF
// ============================================================================

static const float MIN_COS_THETA = 1e-6;

/// Diffuse/specular BRDF: Disney diffuse + isotropic GGX specular.
public struct DiffuseSpecularBRDF
{
    float3 diffuse;
    float3 specular;
    float roughness;

    public __init(float3 albedo, float3 specular_reflectance, float metallic, float roughness)
    {
        this.diffuse = albedo * (1.0 - metallic);
        this.specular = lerp(float3(specular_reflectance * 0.08), albedo, metallic);
        this.roughness = clamp(roughness, 0.05, 1.0);
    }

    public float3 eval(const float3 wi, const float3 wo)
    {
        if (min(wi.z, wo.z) < MIN_COS_THETA)
            return float3(0.0);

        float3 fd = diffuse_disney(wi, wo, diffuse, roughness);
        float3 fs = specular_microfacet(wi, wo, specular, roughness);
        return (fd + fs) * wo.z;
    }

    public bool sample(const float3 wi, out float3 wo, out float pdf, out float3 weight, inout UniformSampleGenerator sg)
    {
        wo = {};
        pdf = {};
        weight = {};

        float diffuse_weight = max(0.0, luminance(diffuse));
        float specular_weight = max(0.001, luminance(specular));
        float norm = 1.0 / (diffuse_weight + specular_weight);
        diffuse_weight *= norm;
        specular_weight *= norm;

        float alpha = roughness * roughness;
        float u_select = next_float(sg);
        float2 u = next_float2(sg);

        if (u_select < diffuse_weight) {
            wo = square_to_cosine_hemisphere_concentric(u);
            pdf = square_to_cosine_hemisphere_concentric_pdf(wo);
            pdf = pdf * diffuse_weight + specular_weight * specular_microfacet_pdf(wi, wo, alpha);
        } else {
            if (!specular_microfacet_sample(wi, alpha, u, wo, pdf))
                return false;
            pdf = pdf * specular_weight + diffuse_weight * diffuse_pdf(wo);
        }

        if (min(wi.z, wo.z) < MIN_COS_THETA || pdf == 0.0)
            return false;

        weight = eval(wi, wo) / pdf;
        return true;
    }

    // --- Internal helpers ---

    /// Disney diffuse BRDF lobe.
    float3 diffuse_disney(const float3 wi, const float3 wo, const float3 albedo, const float roughness)
    {
        float3 h = normalize(wi + wo);
        float woDotH = max(0.0, dot(wo, h));
        float fd90 = 0.5 + 2.0 * woDotH * woDotH * roughness;
        float fd0 = 1.0;
        float wiScatter = eval_fresnel_schlick(fd0, fd90, wi.z);
        float woScatter = eval_fresnel_schlick(fd0, fd90, wo.z);
        return albedo * (wiScatter * woScatter * M_INV_PI);
    }

    float diffuse_pdf(const float3 wo) { return max(0.0, wo.z) * M_INV_PI; }

    /// Microfacet specular BRDF lobe.
    float3 specular_microfacet(const float3 wi, const float3 wo, const float3 albedo, const float roughness)
    {
        float alpha = roughness * roughness;
        float3 h = normalize(wi + wo);
        float wiDotH = dot(wi, h);
        float D = evalNdfGGX(alpha, h.z);
        float G = evalMaskingSmithGGXCorrelated(alpha, wi.z, wo.z);
        float3 F = eval_fresnel_schlick(albedo, float3(1.0), wiDotH);
        return F * (D * G * 0.25 / max(1e-6, wi.z * wo.z));
    }

    bool specular_microfacet_sample(const float3 wi, const float alpha, const float2 u, out float3 wo, out float pdf)
    {
        float3 h = sampleGGX_VNDF(alpha, wi, u, pdf);
        float wiDotH = dot(wi, h);
        wo = 2.0 * wiDotH * h - wi;
        if (wo.z <= 0.0)
            return false;
        pdf /= (4.0 * wiDotH);
        return true;
    }

    float specular_microfacet_pdf(const float3 wi, const float3 wo, const float alpha)
    {
        float3 h = normalize(wi + wo);
        float wiDotH = max(0.0, dot(wi, h));
        float pdf = evalPdfGGX_VNDF(alpha, wi, h);
        return pdf / (4.0 * wiDotH);
    }
};
