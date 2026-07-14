module materials;
import utracer.utracerutils;



public interface IMaterialInstance
{
    public float3 eval(
        const ShadingData sd_ws,
        const float3 wo_ws,
        inout UniformSampleGenerator sg
    );

    public bool sample(
        const ShadingData sd_ws,
        inout UniformSampleGenerator sg,
        out BSDFSample result
    );

    public float
    eval_pdf(const ShadingData sd_ws, const float3 wo_ws);

    public MaterialProperties
    collect_properties(const ShadingData sd_ws);

    public Optional<ExtraBsdfProperties>
    collect_extra_bsdf_properties(const ShadingData sd_ws, const float3 wo) { return {}; }

    public LobeTypes get_lobe_types(const ShadingData sd_ws);
};

public struct ShadingData
{
    /// Hit position
    public float3 position = {};
    /// View/incident direction (-ray.dir)
    public float3 view = {};
    /// Texture coordiantes
    public float2 uv = {};

    /// Smooth interpolated shading frame in world space.
    public Frame shading_frame = {};
    /// Geometric normal in world space.
    public no_diff float3 geometric_normal = {};
    /// Geometric tangent (xyz) and sign (w) in world space. This is used for orthogonalization. Not
    /// normalized, but it is guaranteed to be nonzero and sign (w) is +-1.0.
    public no_diff float4 geometric_tangent = {};
    /// True if primitive is seen from the front face (outside), false when seen from the inside.
    public bool front_facing = {};
    /// Index of refraction for the medium on the front-facing side (i.e. "outside" the material at the hit).
    public float ior = 1.0;

    public __init() { }

    public float3 oriented_face_normal() { return front_facing ? geometric_normal : -geometric_normal; }

    public void adjust_shading_normal(inout Frame sf)
    {
        // Note: sd.V and Ng below always lie on the same side (as the front-facing flag is computed based on sd.V).
        // The shading normal sf.N may lie on either side depending on whether we're shading the front or back.
        // We orient Ns to lie on the same side as sd.V and Ng for the computations below.
        // The final adjusted normal is oriented to lie on the same side as the original shading normal.
        float3 Ng = oriented_face_normal();
        float sign_N = dot(sf.normal, Ng) >= 0.f ? 1.f : -1.f;
        float3 Ns = sign_N * sf.normal;

        // Blend the shading normal towards the geometric normal at grazing angles.
        // This is to avoid the view vector from becoming back-facing.
        const float COS_THETA_THRESHOLD = 0.1f;
        float cos_theta = dot(view, Ns);
        if (cos_theta <= COS_THETA_THRESHOLD) {
            float t = saturate(cos_theta * (1.f / COS_THETA_THRESHOLD));
            sf = Frame(sign_N * lerp(Ng, Ns, t), geometric_tangent.xyz);
        }
    }
}

public struct BSDFSample
{
    /// Sampled direction in world space (normalized).
    public float3 wo_ws = {};
    /// pdf with respect to solid angle for the sampled direction (wo).
    public float pdf = {};
    /// Sample weight f(wi, wo) * dot(wo, n) / pdf(wo).
    public float3 weight = {};
    /// Sampled lobe_type. This is a combination of LobeTypes flags (see bsdfs.slang).
    public LobeTypes lobe_types = LobeTypes::None;

    public bool isLobe(LobeTypes lobe_type) { return (lobe_type & lobe_types) != LobeTypes::None; }
}

public struct MaterialProperties
{
    public enum Flags : uint {
        None = 0x0,
        IsTransmissive = 0x1,
    };

    /// Radiance emitted in the incident direction (wi).
    public float3 emission = {};
    /// Surface roughness on a perceptually linear scale, where 0.0 = perfectly smooth and 1.0 =
    /// maximum roughness.
    public float roughness = {};
    /// Representative shading normal in world space that includes effects of normal mapping. Useful
    /// as guide for denoisers.
    public float3 guide_normal = {};
    ///< Flags storing additional properties.
    public Flags flags = {};

    // Approximate directional-hemispherical reflectance/transmittance of the BSDF (black-sky
    // albedo). The exact values are given by the integrals of the BSDF over wo given an incident
    // direction wi. The terms are separated into diffuse and non-diffuse components. Due to energy
    // conservation, the sum is expected to be <= 1.0.

    /// Directional-hemispherical diffuse reflectance. This is the ratio of total energy diffusely
    /// reflected to the energy incident along wi.
    public float3 diffuse_reflection_albedo = {};
    /// Directional-hemispherical diffuse transmittance. This is the ratio of total energy diffusely
    /// transmitted to the energy incident along wi.
    public float3 diffuse_transmission_albedo = {};
    /// Directional-hemispherical specular reflectance. This is the ratio of total energy
    /// non-diffusely reflected to the energy incident along wi.
    public float3 specular_reflection_albedo = {};
    /// Directional-hemispherical specular transmittance. This is the ratio of total energy
    /// non-diffusely transmitted to the energy incident along wi.
    public float3 specular_transmission_albedo = {};

    // Approximate specular reflectance. This is the color of specular reflection.
    // The diffuse reflectance is approximated as a Lambertian given by the diffuse albedo above.

    /// Specular reflectance at normal incidence (F0). This is in the range [0,1].
    public float3 specular_reflectance = {};

    public property is_transmissive : bool
    {
        get
        {
            return (flags & Flags::IsTransmissive) != 0;
        }
    }
}

public struct ExtraBsdfProperties
{
    public __init() { }

    public float3 bsdf_N[16] = {};         ///< Normal used by each BSDF
    public float3 bsdf_T[16] = {};         ///< Tangent used by each BSDF
    public float3 bsdf_B[16] = {};         ///< Bitangent used by each BSDF
    public float3 bsdf_albedo[16] = {};    ///< Albedo of individual BSDFs
    public float3 bsdf_weight[16] = {};    ///< Weight for the given BSDF
    public float2 bsdf_roughness[16] = {}; ///< Anisotropic roughness
    public float3 bsdf_scratch[16] = {};   ///< Scratch direction and depth
    public float bsdf_index[16] = {};      ///< A BSDF index, e.g. to differentiate between different MERL materials.

    public uint bsdf_count = 0; ///< Number of actually active BSDFs (0 == invalid)
}

public enum LobeTypes : uint32_t
{
    None = 0x00,

    DiffuseReflection = 0x01,
    SpecularReflection = 0x02,
    DeltaReflection = 0x04,

    DiffuseTransmission = 0x10,
    SpecularTransmission = 0x20,
    DeltaTransmission = 0x40,

    Diffuse = 0x11,
    Specular = 0x22,
    Delta = 0x44,
    NonDelta = 0x33,

    Reflection = 0x0f,
    Transmission = 0xf0,

    NonDeltaReflection = 0x03,
    NonDeltaTransmission = 0x30,

    All = 0xff,
};