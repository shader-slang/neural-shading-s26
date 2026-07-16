// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import slangpy;

float2 pixel_to_uv(int2 pixel, int2 resolution)
{
    return (float2(pixel) + 0.5f) / float2(resolution);
}

float3 tonemap_aces_film(float3 input)
{
    float3 x = max(input, float3(0.0f));
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

public void blit(
    int2 pixel,
    int2 size,
    int2 offset,
    bool tonemap,
    bool bilinear,
    Tensor<float3, 2> input,
    RWTexture2D<float4> output)
{
    uint2 output_dimensions;
    output.GetDimensions(output_dimensions.x, output_dimensions.y);

    int2 output_pixel = offset + pixel;
    if (any(output_pixel < int2(0)) || output_pixel.x >= int(output_dimensions.x) || output_pixel.y >= int(output_dimensions.y))
        return;

    float2 uv = pixel_to_uv(pixel, size);
    uint[2] shape = input.shape;

    uint2 texel = min(uint2(float2(shape[1], shape[0]) * uv), uint2(shape[1] - 1, shape[0] - 1));
    float3 color = bilinear ? input.sample(uv) : input.load(texel);

    if (tonemap)
        color = tonemap_aces_film(color);

    if (any(isnan(color)) || any(isinf(color)))
        output[output_pixel] = float4(1.0f, 0.0f, 1.0f, 1.0f);
    else
        output[output_pixel] = float4(color, 1.0f);
}

public void clear(
    int2 pixel,
    float4 color,
    RWTexture2D<float4> output)
{
    uint2 output_dimensions;
    output.GetDimensions(output_dimensions.x, output_dimensions.y);

    if (pixel.x >= int(output_dimensions.x) || pixel.y >= int(output_dimensions.y))
        return;

    output[pixel] = color;
}
