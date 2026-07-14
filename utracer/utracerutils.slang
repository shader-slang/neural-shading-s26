// utracerutils.slang -- Utility functions for utracer
//
// Math, ray, frame, sampling, RNG, lat-long mapping.
// No dependency on falcor2.

import slangpy;

// ============================================================================
// Section 1: Math utilities
// ============================================================================

public static const float M_PI = 3.14159265358979323846;
public static const float M_INV_PI = 0.31830988618379067154;
public static const float M_INV_TWO_PI = 0.15915494309189533577;


/// Luminance of an RGB in Rec.709.
public float luminance(float3 rgb)
{
    return dot(rgb, float3(0.2126, 0.7152, 0.0722));
}

/// Returns the squared norm of a float2.
public float squared_norm(float2 x)
{
    return dot(x, x);
}

/// Returns the square root of the input value, or 0 if the input is negative.
public float safe_sqrt(float x)
{
    return sqrt(max(x, 0.0));
}

/// ACES filmic tone mapping curve.
public float3 tonemap_aces_film(float3 x)
{
    // Cancel out the pre-exposure mentioned in
    // https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
    x *= 0.6;
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

// ============================================================================
// Section 2: Ray & ray-tracing geometry
// ============================================================================

/// Ray with origin, direction and t-range.
public struct Ray
{
    public float3 origin;
    public float t_min;
    public float3 dir;
    public float t_max;

    public __init(float3 origin, float3 dir, float t_min = 0.0, float t_max = 1e30)
    {
        this.origin = origin;
        this.dir = dir;
        this.t_min = t_min;
        this.t_max = t_max;
    }

    public RayDesc to_ray_desc() { return { origin, t_min, dir, t_max }; }
};

/// Computes new ray origin based on hit position to avoid self-intersections.
/// Based on "A Fast and Robust Method for Avoiding Self-Intersection"
/// by Carsten Waechter and Nikolaus Binder (Ray Tracing Gems, Ch. 6).
public float3 offset_ray_origin(float3 pos, float3 normal)
{
    const float ORIGIN = 1.0 / 16.0;
    const float FLOAT_SCALE = 3.0 / 65536.0;
    const float INT_SCALE = 3.0 * 256.0;

    int3 offset_i = int3(normal * INT_SCALE);
    float3 pos_i = float3(
        asfloat(asint(pos[0]) + select(pos[0] < 0.0, -offset_i[0], offset_i[0])),
        asfloat(asint(pos[1]) + select(pos[1] < 0.0, -offset_i[1], offset_i[1])),
        asfloat(asint(pos[2]) + select(pos[2] < 0.0, -offset_i[2], offset_i[2])),
    );
    float3 offset_f = normal * FLOAT_SCALE;
    return float3(
        select(abs(pos[0]) < ORIGIN, pos[0] + offset_f[0], pos_i[0]),
        select(abs(pos[1]) < ORIGIN, pos[1] + offset_f[1], pos_i[1]),
        select(abs(pos[2]) < ORIGIN, pos[2] + offset_f[2], pos_i[2]),
    );
}

/// Tangent frame (normal, tangent, bitangent).
public struct Frame
{
    public float3 normal = {};
    public float3 tangent = {};
    public float3 bitangent = {};

    public __init() {}

    /// Construct frame from normal and tangent (normal is preserved).
    public __init(float3 normal, float3 tangent)
    {
        this.normal = normal;
        this.bitangent = normalize(cross(normal, tangent));
        this.tangent = cross(bitangent, normal);
    }

    /// Transform from world space to local shading space.
    public float3 to_local(float3 w) { return float3(dot(tangent, w), dot(bitangent, w), dot(normal, w)); }

    /// Transform from local shading space to world space.
    public float3 to_global(float3 w) { return w.x * tangent + w.y * bitangent + w.z * normal; }
};

// ============================================================================
// Section 3: Sampling & RNG
// ============================================================================

/// Uniform pseudorandom sample generator.
public struct UniformSampleGenerator
{
    public uint state;

    public __init(uint2 pixel, uint sample_index) {
        state = sample_index;
        next_uint();
        state = state ^ pixel.x;
        next_uint();
        state = state ^ pixel.y;
        next_uint();
    }

    [mutating]
    public uint next_uint()
    {
        const uint A = 1664525u;
        const uint C = 1013904223u;
        state = (A * state + C);
        return state;
    }
};

/// Return the next sample value as a float in [0,1).
public float next_float(inout UniformSampleGenerator sg)
{
    return (sg.next_uint() >> 8) * 0x1p-24;
}

/// Return the next 2 sample values as a float2 in [0,1).
public float2 next_float2(inout UniformSampleGenerator sg)
{
    float2 sample;
    sample.x = next_float(sg);
    sample.y = next_float(sg);
    return sample;
}

/// Return the next 4 sample values as a float4 in [0,1).
public float4 next_float4(inout UniformSampleGenerator sg)
{
    float4 sample;
    sample.x = next_float(sg);
    sample.y = next_float(sg);
    sample.z = next_float(sg);
    sample.w = next_float(sg);
    return sample;
}

public float3 next_dir_on_hemisphere(inout UniformSampleGenerator sg)
{
    // Random azimuthal angle [0, 2π)
    float phi = 2.0f * M_PI * next_float(sg);

    // Random polar angle [0, π/2) for hemisphere
    float cos_theta = next_float(sg);
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);

    // Convert to Cartesian coordinates
    return float3(sin_theta * cos(phi), sin_theta * sin(phi), cos_theta);
}

/// Low-distortion concentric square-to-disk mapping (Peter Shirley).
public float2 square_to_uniform_disk_concentric(float2 sample)
{
    float2 t = 2.0 * sample - 1.0;

    bool is_zero = all(t == 0.0);
    bool quadrant_1_or_3 = abs(t.x) < abs(t.y);

    float r = select(quadrant_1_or_3, t.y, t.x);
    float rp = select(quadrant_1_or_3, t.x, t.y);

    float phi = 0.25 * M_PI * rp / r;
    phi = select(quadrant_1_or_3, 0.5 * M_PI - phi, phi);
    phi = select(is_zero, 0.0, phi);

    float s, c;
    sincos(phi, s, c);
    return float2(c, s) * r;
}

/// Sample a cosine-weighted vector on the unit hemisphere (concentric mapping).
public float3 square_to_cosine_hemisphere_concentric(float2 sample)
{
    float2 p = square_to_uniform_disk_concentric(sample);
    return float3(p, safe_sqrt(1.0 - squared_norm(p)));
}

/// PDF of cosine-weighted hemisphere sampling w.r.t. solid angle.
public float square_to_cosine_hemisphere_concentric_pdf(float3 p)
{
    return M_INV_PI * p.z;
}

// ============================================================================
// Section 4: Lat-long mapping
// ============================================================================

/// Convert world-space direction to latitude-longitude map UV [0,1]^2.
public float2 world_to_latlong_map(float3 dir)
{
    dir = normalize(dir);
    float2 latlong;
    latlong.x = atan2(dir.x, -dir.z) * M_INV_TWO_PI + 0.5;
    latlong.y = acos(dir.y) * M_INV_PI;
    return latlong;
}
