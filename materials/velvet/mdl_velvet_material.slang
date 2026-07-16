/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 */

module mdl_velvet_material;
import materials.materials;
import utracer.utracerutils;

namespace mdl_velvet_material_ns
{

#define MDL_NUM_TEXTURE_RESULTS 16
#define MDL_DF_HANDLE_SLOT_MODE 4
#define MDL_USE_RENDERER_ADAPT_NORMAL 1
#define MATERIAL_DATA_NAME g_material_data_mdl_velvet_material

#include "materials/mdl_runtime.slangh"

// functions
void init(inout Shading_state_material state)
{
    float3 tmp0;
    float2 tmp1;
    int tmp5;
    int tmp6;
    float tmp7;
    float tmp8;
    float2 tmp9;
    float tmp10;
    float tmp11;
    float3 tmp36;
    float3 tmp37;
    float3 tmp46;
    float3 phi_47;
    float3 phi_49;
    float3 phi_51;
    float3 tmp78;
    float3 tmp79;
    float3 tmp92;
    tmp0 = state.text_coords[0];
    tmp1 = tmp0.xy;
    float2 tmp2 = tmp1 * float2(3.0f, 3.0f);
    float tmp3 = tmp2.x * 0.9999999404f - tmp2.y * 0.5773502588f;
    float tmp4 = tmp2.y * 1.154700518f;
    tmp5 = int(floor(tmp3));
    tmp6 = int(floor(tmp4));
    tmp7 = frac(tmp3);
    tmp8 = frac(tmp4);
    tmp9 = float2(tmp7, tmp8);
    tmp10 = 1.0f - tmp7;
    tmp11 = tmp10 - tmp8;
    if (tmp11 > 0.0f)
    {
        float2 tmp12 = tmp1 * float2(0.75f, 0.75f);
        int tmp13 = (int(uint(tmp6) >> 16u) ^ tmp6) * 2146121005;
        int tmp14 = (int(uint(tmp13) >> 15u) ^ tmp13) * -2073254261;
        int tmp15 = int(uint(tmp14) >> 16u) ^ tmp14;
        int tmp16 = tmp15 + tmp5;
        int tmp17 = (int(uint(tmp16) >> 16u) ^ tmp16) * 2146121005;
        int tmp18 = (int(uint(tmp17) >> 15u) ^ tmp17) * -2073254261;
        int tmp19 = int(uint(tmp18) >> 16u) ^ tmp18;
        int tmp20 = tmp16 + 32000;
        int tmp21 = (int(uint(tmp20) >> 16u) ^ tmp20) * 2146121005;
        int tmp22 = (int(uint(tmp21) >> 15u) ^ tmp21) * -2073254261;
        int tmp23 = int(uint(tmp22) >> 16u) ^ tmp22;
        float3 tmp24 = float3(tmp11, 0.0f, 0.0f);
        int tmp25 = tmp6 + 1;
        int tmp26 = (int(uint(tmp25) >> 16u) ^ tmp25) * 2146121005;
        int tmp27 = (int(uint(tmp26) >> 15u) ^ tmp26) * -2073254261;
        int tmp28 = (int(uint(tmp27) >> 16u) ^ tmp27) + tmp5;
        int tmp29 = (int(uint(tmp28) >> 16u) ^ tmp28) * 2146121005;
        int tmp30 = (int(uint(tmp29) >> 15u) ^ tmp29) * -2073254261;
        int tmp31 = int(uint(tmp30) >> 16u) ^ tmp30;
        int tmp32 = tmp28 + 32000;
        int tmp33 = (int(uint(tmp32) >> 16u) ^ tmp32) * 2146121005;
        int tmp34 = (int(uint(tmp33) >> 15u) ^ tmp33) * -2073254261;
        int tmp35 = int(uint(tmp34) >> 16u) ^ tmp34;
        tmp36 = (tex_lookup_float3_2d(2, tmp12 - float2(((tmp31 < 0 ? 2147483648.0f : 0.0f) + float(tmp31 & 2147483647)) * 2.328306437e-10f, ((tmp35 < 0 ? 2147483648.0f : 0.0f) + float(tmp35 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp9.yyy + (tex_lookup_float3_2d(2, tmp12 - float2(((tmp19 < 0 ? 2147483648.0f : 0.0f) + float(tmp19 & 2147483647)) * 2.328306437e-10f, ((tmp23 < 0 ? 2147483648.0f : 0.0f) + float(tmp23 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp24.xxx;
        tmp37 = float3(tmp11, tmp8, tmp7);
        int tmp38 = tmp5 + 1 + tmp15;
        int tmp39 = (int(uint(tmp38) >> 16u) ^ tmp38) * 2146121005;
        int tmp40 = (int(uint(tmp39) >> 15u) ^ tmp39) * -2073254261;
        int tmp41 = int(uint(tmp40) >> 16u) ^ tmp40;
        int tmp42 = tmp38 + 32000;
        int tmp43 = (int(uint(tmp42) >> 16u) ^ tmp42) * 2146121005;
        int tmp44 = (int(uint(tmp43) >> 15u) ^ tmp43) * -2073254261;
        int tmp45 = int(uint(tmp44) >> 16u) ^ tmp44;
        tmp46 = (tex_lookup_float3_2d(2, tmp12 - float2(((tmp41 < 0 ? 2147483648.0f : 0.0f) + float(tmp41 & 2147483647)) * 2.328306437e-10f, ((tmp45 < 0 ? 2147483648.0f : 0.0f) + float(tmp45 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp9.xxx;
        phi_47 = tmp46;
        phi_49 = tmp36;
        phi_51 = tmp37;
    }
    else
    {
        float tmp52 = -tmp11;
        float2 tmp53 = tmp1 * float2(0.75f, 0.75f);
        int2 tmp54 = int2(tmp5, tmp6) + int2(1, 1);
        int tmp55 = (int(uint(tmp54.y) >> 16u) ^ tmp54.y) * 2146121005;
        int tmp56 = (int(uint(tmp55) >> 15u) ^ tmp55) * -2073254261;
        int tmp57 = (int(uint(tmp56) >> 16u) ^ tmp56) + tmp54.x;
        int tmp58 = (int(uint(tmp57) >> 16u) ^ tmp57) * 2146121005;
        int tmp59 = (int(uint(tmp58) >> 15u) ^ tmp58) * -2073254261;
        int tmp60 = int(uint(tmp59) >> 16u) ^ tmp59;
        int tmp61 = tmp57 + 32000;
        int tmp62 = (int(uint(tmp61) >> 16u) ^ tmp61) * 2146121005;
        int tmp63 = (int(uint(tmp62) >> 15u) ^ tmp62) * -2073254261;
        int tmp64 = int(uint(tmp63) >> 16u) ^ tmp63;
        float3 tmp65 = float3(tmp52, 0.0f, 0.0f);
        float tmp66 = 1.0f - tmp8;
        int tmp67 = (int(uint(tmp6) >> 16u) ^ tmp6) * 2146121005;
        int tmp68 = (int(uint(tmp67) >> 15u) ^ tmp67) * -2073254261;
        int tmp69 = tmp5 + 1 + (int(uint(tmp68) >> 16u) ^ tmp68);
        int tmp70 = (int(uint(tmp69) >> 16u) ^ tmp69) * 2146121005;
        int tmp71 = (int(uint(tmp70) >> 15u) ^ tmp70) * -2073254261;
        int tmp72 = int(uint(tmp71) >> 16u) ^ tmp71;
        int tmp73 = tmp69 + 32000;
        int tmp74 = (int(uint(tmp73) >> 16u) ^ tmp73) * 2146121005;
        int tmp75 = (int(uint(tmp74) >> 15u) ^ tmp74) * -2073254261;
        int tmp76 = int(uint(tmp75) >> 16u) ^ tmp75;
        float3 tmp77 = float3(tmp66, 0.0f, 0.0f);
        tmp78 = (tex_lookup_float3_2d(2, tmp53 - float2(((tmp72 < 0 ? 2147483648.0f : 0.0f) + float(tmp72 & 2147483647)) * 2.328306437e-10f, ((tmp76 < 0 ? 2147483648.0f : 0.0f) + float(tmp76 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp77.xxx + (tex_lookup_float3_2d(2, tmp53 - float2(((tmp60 < 0 ? 2147483648.0f : 0.0f) + float(tmp60 & 2147483647)) * 2.328306437e-10f, ((tmp64 < 0 ? 2147483648.0f : 0.0f) + float(tmp64 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp65.xxx;
        tmp79 = float3(tmp52, tmp66, tmp10);
        int tmp80 = tmp6 + 1;
        int tmp81 = (int(uint(tmp80) >> 16u) ^ tmp80) * 2146121005;
        int tmp82 = (int(uint(tmp81) >> 15u) ^ tmp81) * -2073254261;
        int tmp83 = (int(uint(tmp82) >> 16u) ^ tmp82) + tmp5;
        int tmp84 = (int(uint(tmp83) >> 16u) ^ tmp83) * 2146121005;
        int tmp85 = (int(uint(tmp84) >> 15u) ^ tmp84) * -2073254261;
        int tmp86 = int(uint(tmp85) >> 16u) ^ tmp85;
        int tmp87 = tmp83 + 32000;
        int tmp88 = (int(uint(tmp87) >> 16u) ^ tmp87) * 2146121005;
        int tmp89 = (int(uint(tmp88) >> 15u) ^ tmp88) * -2073254261;
        int tmp90 = int(uint(tmp89) >> 16u) ^ tmp89;
        float3 tmp91 = float3(tmp10, 0.0f, 0.0f);
        tmp92 = (tex_lookup_float3_2d(2, tmp53 - float2(((tmp86 < 0 ? 2147483648.0f : 0.0f) + float(tmp86 & 2147483647)) * 2.328306437e-10f, ((tmp90 < 0 ? 2147483648.0f : 0.0f) + float(tmp90 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.2529999912f, -0.2529999912f, -0.2529999912f)) * tmp91.xxx;
        phi_47 = tmp92;
        phi_49 = tmp78;
        phi_51 = tmp79;
    }
    float3 tmp93 = phi_49 + phi_47;
    float tmp94 = min(max(tmp93.x / sqrt(phi_51.x * phi_51.x + phi_51.y * phi_51.y + phi_51.z * phi_51.z) + 0.2529999912f, 0.0f), 1.0f) * 0.6399999857f;
    state.text_results[0].x = tmp94;
    float2 tmp95 = float2(tmp0.x * 6.25f, tmp0.y * 6.25f);
    float3 tmp96 = tex_lookup_color_2d(3, tmp95, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f);
    float3 tmp97 = float3(pow((tmp96.x + tmp96.y + tmp96.z) * 0.3333333433f, 1.50999999f), 0.0f, 0.0f);
    float3 tmp98 = tmp97.xxx * float3(0.09971226752f, 0.008343737572f, 0.01461886615f);
    float3 tmp99 = float3(1.0f - tmp94, 0.0f, 0.0f);
    float3 tmp100 = (tmp99.xxx * tmp98 - tmp98) * float3(0.3199999928f, 0.3199999928f, 0.3199999928f) + tmp98;
    state.text_results[0].y = tmp100.x;
    state.text_results[0].z = tmp100.y;
    state.text_results[0].w = tmp100.z;
    float3 tmp101 = state.tangent_u[0];
    float3 tmp102 = float3(sqrt(tmp101.x * tmp101.x + tmp101.y * tmp101.y + tmp101.z * tmp101.z), 0.0f, 0.0f);
    float3 tmp103 = tex_lookup_float3_2d(4, tmp95, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) * float3(2.0f, 2.0f, 2.0f) + float3(-1.0f, -1.0f, -1.0f);
    float3 tmp104 = state.tangent_v[0];
    float3 tmp105 = float3(sqrt(tmp104.x * tmp104.x + tmp104.y * tmp104.y + tmp104.z * tmp104.z), 0.0f, 0.0f);
    float3 tmp106 = tmp103.xxx * tmp101 / tmp102.xxx + tmp103.zzz * state.normal + tmp103.yyy * tmp104 / tmp105.xxx;
    float3 tmp107 = float3(sqrt(tmp106.x * tmp106.x + tmp106.y * tmp106.y + tmp106.z * tmp106.z), 0.0f, 0.0f);
    float3 tmp108 = tmp106 / tmp107.xxx;
    state.text_results[1].x = tmp108.x;
    state.text_results[1].y = tmp108.y;
    state.text_results[1].z = tmp108.z;
    return;
}

float3 ior(in Shading_state_material state)
{
    return float3(1.0f, 1.0f, 1.0f);
}

bool thin_walled(in Shading_state_material state)
{
    return false;
}

void gen_weighted_layer_pdf(inout Bsdf_pdf_data p_00, in Shading_state_material p_11)
{
    float3 tmp2;
    float tmp4;
    float tmp5;
    float tmp7;
    float tmp8;
    float tmp9;
    float3 tmp10;
    float tmp12;
    float tmp13;
    float tmp14;
    float tmp15;
    float tmp16;
    float tmp17;
    float tmp18;
    float tmp19;
    float phi;
    float tmp20;
    float phi22;
    float3 tmp23;
    float tmp25;
    float tmp26;
    float tmp27;
    float tmp28;
    float3 tmp29;
    float3 tmp30;
    float tmp32;
    bool tmp33;
    float phi35;
    float tmp42;
    float tmp44;
    float tmp47;
    float tmp48;
    float3 tmp50;
    float tmp52;
    float tmp55;
    float tmp56;
    float phi58;
    float phi60;
    float tmp65;
    float tmp66;
    float3 tmp67;
    float3 tmp68;
    float3 tmp69;
    float tmp71;
    float phi73;
    float3 tmp75;
    float3 tmp76;
    float tmp79;
    float3 tmp84;
    float tmp86;
    float tmp100;
    float tmp101;
    float phi103;
    float tmp106;
    float tmp107;
    tmp2 = p_11.text_results[1].xyz;
    float3 tmp3 = mdl_adapt_normal(p_11, tmp2);
    tmp4 = pow(0.5171840191f - p_11.text_results[0].x * 0.3392000198f, 3.789999962f);
    tmp5 = 1.0f / max(tmp4, 1.000000012e-07f);
    float3 tmp6 = p_11.geom_normal;
    tmp7 = p_00.k1.x;
    tmp8 = p_00.k1.y;
    tmp9 = p_00.k1.z;
    tmp10 = float3(tmp7, tmp8, tmp9);
    float3 tmp11 = tmp10 * tmp6;
    tmp12 = asfloat((asint(tmp11.x + tmp11.y + tmp11.z) & -2147483648) | 1065353216);
    tmp13 = tmp6.x * tmp12;
    tmp14 = tmp6.y * tmp12;
    tmp15 = tmp6.z * tmp12;
    tmp16 = tmp3.x * tmp12;
    tmp17 = tmp3.y * tmp12;
    tmp18 = tmp3.z * tmp12;
    tmp19 = p_00.ior1.x;
    phi = tmp19;
    if (tmp19 == -1.0f)
    {
        p_00.ior1.x = 1.0f;
        p_00.ior1.y = 1.0f;
        p_00.ior1.z = 1.0f;
        phi = 1.0f;
    }
    tmp20 = p_00.ior2.x;
    phi22 = tmp20;
    if (tmp20 == -1.0f)
    {
        p_00.ior2.x = 1.0f;
        p_00.ior2.y = 1.0f;
        p_00.ior2.z = 1.0f;
        phi22 = 1.0f;
    }
    tmp23 = float3(tmp16, tmp17, tmp18);
    float3 tmp24 = tmp23 * tmp10;
    tmp25 = abs(tmp24.x + tmp24.y + tmp24.z);
    tmp26 = p_00.k2.x;
    tmp27 = p_00.k2.y;
    tmp28 = p_00.k2.z;
    tmp29 = float3(tmp26, tmp27, tmp28);
    tmp30 = float3(tmp13, tmp14, tmp15);
    float3 tmp31 = tmp29 * tmp30;
    tmp32 = tmp31.x + tmp31.y + tmp31.z;
    tmp33 = tmp32 < 0.0f;
    if (tmp33)
    {
        p_00.pdf = 0.0f;
        phi35 = 0.0f;
    }
    else
    {
        float tmp36 = tmp26 + tmp7;
        float tmp37 = tmp27 + tmp8;
        float tmp38 = tmp28 + tmp9;
        float3 tmp39 = float3(sqrt(tmp37 * tmp37 + tmp36 * tmp36 + tmp38 * tmp38), 0.0f, 0.0f);
        float3 tmp40 = float3(tmp36, tmp37, tmp38) / tmp39.xxx;
        float3 tmp41 = tmp40 * tmp23;
        tmp42 = tmp41.x + tmp41.y + tmp41.z;
        float3 tmp43 = tmp40 * tmp10;
        tmp44 = tmp43.x + tmp43.y + tmp43.z;
        float3 tmp45 = tmp40 * tmp29;
        if (tmp45.x + tmp45.y + tmp45.z < 0.0f || (tmp42 < 0.0f || tmp44 < 0.0f))
        {
            p_00.pdf = 0.0f;
            phi35 = 0.0f;
        }
        else
        {
            float tmp46 = tmp42 * tmp25;
            tmp47 = tmp42 * (tmp5 * 0.03978873417f + 0.07957746834f) * min(tmp46 * 2.0f / tmp44, 1.0f) * pow(sqrt(max(1.0f - tmp42 * tmp42, 0.0f)), tmp5) / tmp46;
            p_00.pdf = tmp47;
            phi35 = tmp47;
        }
    }
    tmp48 = min(max(tmp4, 0.0f), 1.0f);
    float3 tmp49 = mdl_adapt_normal(p_11, tmp2);
    tmp50 = float3(tmp49.x * tmp12, tmp49.y * tmp12, tmp49.z * tmp12);
    float3 tmp51 = tmp50 * tmp10;
    tmp52 = tmp51.x + tmp51.y + tmp51.z;
    float tmp53 = 1.0f - min(max(min(max(tmp52, 0.0f), 1.0f), 0.0f), 1.0f);
    float tmp54 = tmp53 * tmp53;
    tmp55 = tmp54 * tmp54 * (tmp53 * 0.3299999833f);
    tmp56 = tmp55 + 0.02999999933f;
    phi58 = 0.0f;
    if (!(tmp56 < 0.0f))
    {
        phi60 = 0.0f;
        if (tmp56 > 0.0f)
        {
            float3 tmp61 = p_11.tangent_u[0];
            float3 tmp62 = float3(sqrt(tmp61.x * tmp61.x + tmp61.y * tmp61.y + tmp61.z * tmp61.z), 0.0f, 0.0f);
            float3 tmp63 = tmp61 / tmp62.xxx;
            float tmp64 = mdl_read_argblock_as_float(p_11.arg_block_offset);
            tmp65 = max(tmp64, 0.3136000037f);
            tmp66 = max(tmp64, 0.7395999432f);
            tmp67 = tmp50.zxy;
            tmp68 = tmp50.yzx;
            tmp69 = tmp63.yzx * tmp67 - tmp63.zxy * tmp68;
            float3 tmp70 = tmp69 * tmp69;
            tmp71 = tmp70.x + tmp70.y + tmp70.z;
            phi73 = 0.0f;
            if (!(tmp71 < 9.999999939e-09f))
            {
                float tmp74 = 1.0f / sqrt(tmp71);
                tmp75 = float3(tmp74 * tmp69.x, tmp74 * tmp69.y, tmp74 * tmp69.z);
                tmp76 = tmp75.zxy * tmp68 - tmp75.yzx * tmp67;
                bool tmp77 = phi == -1.0f;
                if (tmp77)
                {
                    p_00.ior1.x = 1.0f;
                    p_00.ior1.y = 1.0f;
                    p_00.ior1.z = 1.0f;
                }
                bool tmp78 = phi22 == -1.0f;
                if (tmp78)
                {
                    p_00.ior2.x = 1.0f;
                    p_00.ior2.y = 1.0f;
                    p_00.ior2.z = 1.0f;
                }
                tmp79 = abs(tmp52);
                phi73 = 0.0f;
                if (!tmp33)
                {
                    float tmp80 = tmp26 + tmp7;
                    float tmp81 = tmp27 + tmp8;
                    float tmp82 = tmp28 + tmp9;
                    float3 tmp83 = float3(sqrt(tmp81 * tmp81 + tmp80 * tmp80 + tmp82 * tmp82), 0.0f, 0.0f);
                    tmp84 = float3(tmp80, tmp81, tmp82) / tmp83.xxx;
                    float3 tmp85 = tmp50 * tmp84;
                    tmp86 = tmp85.x + tmp85.y + tmp85.z;
                    float3 tmp87 = tmp84 * tmp10;
                    float3 tmp88 = tmp84 * tmp29;
                    phi73 = 0.0f;
                    if (!(tmp88.x + tmp88.y + tmp88.z < 0.0f || (tmp87.x + tmp87.y + tmp87.z < 0.0f || tmp86 < 0.0f)))
                    {
                        float3 tmp89 = tmp76 * tmp84;
                        float3 tmp90 = tmp75 * tmp84;
                        float tmp91 = 1.0f / tmp65;
                        float tmp92 = 1.0f / tmp66;
                        float tmp93 = (tmp89.x + tmp89.y + tmp89.z) * tmp91;
                        float tmp94 = (tmp90.x + tmp90.y + tmp90.z) * tmp92;
                        float tmp95 = tmp94 * tmp94 + tmp86 * tmp86 + tmp93 * tmp93;
                        float3 tmp96 = tmp76 * tmp10;
                        float3 tmp97 = tmp75 * tmp10;
                        float tmp98 = (tmp96.x + tmp96.y + tmp96.z) * tmp65;
                        float tmp99 = (tmp97.x + tmp97.y + tmp97.z) * tmp66;
                        tmp100 = tmp86 * 0.1591549367f * tmp91 * tmp92 / (tmp95 * tmp95 * (tmp79 * tmp86) * (sqrt((tmp98 * tmp98 + tmp99 * tmp99) / (tmp52 * tmp52) + 1.0f) + 1.0f));
                        phi73 = tmp100;
                    }
                }
            }
            tmp101 = phi73 * tmp56;
            phi60 = tmp101;
        }
        phi58 = phi60;
        if (tmp56 < 1.0f)
        {
            phi103 = 0.0f;
            if (tmp32 > 0.0f)
            {
                float3 tmp104 = tmp23 * tmp30;
                float3 tmp105 = tmp29 * tmp23;
                tmp106 = max(tmp105.x + tmp105.y + tmp105.z, 0.0f) / (max(tmp104.x + tmp104.y + tmp104.z, 0.0f) * 1.570796371f + 1.570796371f);
                phi103 = tmp106;
            }
            tmp107 = phi103 * (0.9700000286f - tmp55) + phi60;
            phi58 = tmp107;
        }
    }
    p_00.pdf = tex_lookup_float3_3d(1, float3(min(max(acos(min(max(tmp25, 0.0f), 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, min(max(sqrt(tmp48 * tmp48), 0.0f), 1.0f) * 0.984375f + 0.0078125f, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x * (phi35 - phi58) + phi58;
    return;
}

void surface_scattering_sample(inout Bsdf_sample_data sret_ptr, in Shading_state_material state)
{
    Bsdf_pdf_data pdf_data;
    float3 tmp0;
    float tmp2;
    float tmp3;
    float tmp4;
    float3 tmp5;
    float tmp7;
    float tmp8;
    float tmp9;
    float3 tmp10;
    float tmp12;
    float tmp13;
    float tmp14;
    float tmp15;
    float tmp16;
    float tmp17;
    float tmp18;
    float3 tmp19;
    float3 tmp20;
    float3 tmp21;
    float3 tmp22;
    float tmp24;
    float tmp25;
    float tmp26;
    float phi_27;
    float phi_29;
    float tmp31;
    float tmp32;
    float tmp33;
    float3 tmp34;
    float3 tmp35;
    float tmp36;
    float phi;
    float tmp38;
    float phi40;
    float tmp42;
    float tmp43;
    float tmp45;
    float tmp46;
    float tmp47;
    float tmp48;
    float tmp61;
    float tmp62;
    float tmp63;
    float phi65;
    float phi67;
    float tmp68;
    float tmp69;
    float tmp70;
    float3 tmp71;
    float tmp73;
    float3 tmp78;
    float tmp83;
    float tmp84;
    float tmp86;
    float tmp87;
    float tmp89;
    float tmp90;
    float tmp91;
    float3 tmp92;
    float tmp94;
    float tmp97;
    float tmp98;
    bool tmp99;
    bool tmp100;
    bool phi_in101;
    bool phi102;
    bool phi_in103;
    bool phi104;
    bool phi_in105;
    bool phi106;
    float phi108;
    float tmp109;
    float tmp110;
    float tmp114;
    float tmp115;
    float3 tmp116;
    float3 tmp117;
    float3 tmp118;
    float tmp120;
    int index;
    float newPhi;
    float newPhi55;
    float3 newPhi56;
    float newPhi57;
    float newPhi58;
    float newPhi59;
    float newPhi60;
    float newPhi61;
    float newPhi62;
    float newPhi63;
    float newPhi64;
    float tmp134;
    float tmp135;
    float tmp136;
    float3 tmp137;
    float3 tmp138;
    float phi_141;
    float phi_144;
    float tmp147;
    float tmp148;
    float tmp151;
    float tmp152;
    float3 tmp154;
    float phi156;
    float phi158;
    float phi160;
    float tmp168;
    float tmp169;
    float tmp170;
    float tmp171;
    float phi173;
    float phi175;
    float tmp176;
    float tmp190;
    float tmp191;
    float tmp192;
    float tmp194;
    float tmp196;
    float tmp197;
    float tmp198;
    float3 tmp199;
    float3 tmp201;
    float tmp207;
    float tmp208;
    float tmp209;
    float tmp210;
    float tmp211;
    float3 tmp212;
    float tmp214;
    float tmp215;
    float tmp216;
    float tmp217;
    bool tmp218;
    float tmp219;
    float phi221;
    float tmp222;
    float tmp223;
    float3 phi226;
    float tmp229;
    float tmp230;
    float tmp231;
    float tmp232;
    float tmp233;
    float phi235;
    float phi237;
    float phi239;
    float tmp240;
    float tmp241;
    float3 tmp242;
    float tmp243;
    float tmp244;
    float tmp245;
    float phi_247;
    float phi_249;
    float phi_251;
    float phi253;
    float phi255;
    float phi257;
    float phi263;
    float phi265;
    float tmp266;
    float tmp267;
    float tmp268;
    float3 tmp273;
    float phi276;
    float phi278;
    float phi280;
    float tmp282;
    float tmp283;
    float tmp285;
    float tmp287;
    float phi289;
    float tmp290;
    float tmp292;
    float tmp293;
    float tmp294;
    float3 tmp295;
    float3 tmp300;
    float tmp303;
    float phi_305;
    float phi307;
    float phi309;
    float tmp312;
    tmp0 = state.text_results[1].xyz;
    float3 tmp1 = mdl_adapt_normal(state, tmp0);
    tmp2 = state.text_results[0].x;
    tmp3 = pow(0.5171840191f - tmp2 * 0.3392000198f, 3.789999962f);
    tmp4 = 1.0f / max(tmp3, 1.000000012e-07f);
    tmp5 = state.tangent_u[0];
    float3 tmp6 = state.geom_normal;
    tmp7 = sret_ptr.k1.x;
    tmp8 = sret_ptr.k1.y;
    tmp9 = sret_ptr.k1.z;
    tmp10 = float3(tmp7, tmp8, tmp9);
    float3 tmp11 = tmp10 * tmp6;
    tmp12 = asfloat((asint(tmp11.x + tmp11.y + tmp11.z) & -2147483648) | 1065353216);
    tmp13 = tmp6.x * tmp12;
    tmp14 = tmp6.y * tmp12;
    tmp15 = tmp6.z * tmp12;
    tmp16 = tmp1.x * tmp12;
    tmp17 = tmp1.y * tmp12;
    tmp18 = tmp1.z * tmp12;
    tmp19 = float3(tmp16, tmp17, tmp18);
    tmp20 = tmp19.zxy;
    tmp21 = tmp19.yzx;
    tmp22 = tmp20 * tmp5.yzx - tmp21 * tmp5.zxy;
    float3 tmp23 = tmp22 * tmp22;
    tmp24 = tmp23.x + tmp23.y + tmp23.z;
    if (tmp24 < 9.999999939e-09f)
    {
        sret_ptr.pdf = 0.0f;
        sret_ptr.event_type = 0;
        tmp25 = sret_ptr.ior1.x;
        tmp26 = sret_ptr.ior2.x;
        phi_27 = tmp26;
        phi_29 = tmp25;
    }
    else
    {
        float tmp30 = 1.0f / sqrt(tmp24);
        tmp31 = tmp30 * tmp22.x;
        tmp32 = tmp30 * tmp22.y;
        tmp33 = tmp30 * tmp22.z;
        tmp34 = float3(tmp31, tmp32, tmp33);
        tmp35 = tmp34.zxy * tmp21 - tmp34.yzx * tmp20;
        tmp36 = sret_ptr.ior1.x;
        phi = tmp36;
        if (tmp36 == -1.0f)
        {
            sret_ptr.ior1.x = 1.0f;
            sret_ptr.ior1.y = 1.0f;
            sret_ptr.ior1.z = 1.0f;
            phi = 1.0f;
        }
        tmp38 = sret_ptr.ior2.x;
        phi40 = tmp38;
        if (tmp38 == -1.0f)
        {
            sret_ptr.ior2.x = 1.0f;
            sret_ptr.ior2.y = 1.0f;
            sret_ptr.ior2.z = 1.0f;
            phi40 = 1.0f;
        }
        float3 tmp41 = tmp19 * tmp10;
        tmp42 = tmp41.x + tmp41.y + tmp41.z;
        tmp43 = abs(tmp42);
        float tmp44 = min(max(tmp3, 0.0f), 1.0f);
        tmp45 = min(max(sqrt(tmp44 * tmp44), 0.0f), 1.0f) * 0.984375f + 0.0078125f;
        tmp46 = tex_lookup_float3_3d(1, float3(min(max(acos(min(max(tmp43, 0.0f), 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, tmp45, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x;
        tmp47 = sret_ptr.xi.z;
        if (tmp47 < tmp46)
        {
            tmp48 = tmp47 / tmp46;
            float3 tmp49 = tmp35 * tmp10;
            float3 tmp50 = tmp34 * tmp10;
            float tmp51 = sret_ptr.xi.x * 6.283185482f;
            float tmp52 = pow(1.0f - sret_ptr.xi.y, 1.0f / (tmp4 + 2.0f));
            float tmp53 = 1.0f - tmp52 * tmp52;
            float tmp54 = cos(tmp51) * tmp52;
            float tmp55 = sin(tmp51) * tmp52;
            float3 tmp56 = float3(sqrt(tmp54 * tmp54 + tmp53 + tmp55 * tmp55), 0.0f, 0.0f);
            float3 tmp57 = float3(tmp54, sqrt(tmp53), tmp55) / tmp56.xxx;
            float tmp58 = tmp57.y * tmp43;
            float tmp59 = tmp57.z * (tmp50.x + tmp50.y + tmp50.z) + tmp57.x * (tmp49.x + tmp49.y + tmp49.z);
            float tmp60 = max(tmp58 - tmp59, 0.0f);
            tmp61 = tmp60 / (tmp60 + max(tmp59 + tmp58, 0.0f));
            if (tmp48 < tmp61)
            {
                sret_ptr.xi.z = tmp48 / tmp61;
                tmp62 = -tmp57.x;
                tmp63 = -tmp57.z;
                phi65 = tmp62;
                phi67 = tmp63;
            }
            else
            {
                sret_ptr.xi.z = min(max((tmp48 - tmp61) / (1.0f - tmp61), 0.0f), 0.9999999404f);
                phi65 = tmp57.x;
                phi67 = tmp57.z;
            }
            if (tmp57.y == 0.0f)
            {
                sret_ptr.pdf = 0.0f;
                sret_ptr.event_type = 0;
                phi_27 = phi40;
                phi_29 = phi;
            }
            else
            {
                tmp68 = phi65 * tmp35.x + tmp57.y * tmp16 + phi67 * tmp31;
                tmp69 = phi65 * tmp35.y + tmp57.y * tmp17 + phi67 * tmp32;
                tmp70 = phi65 * tmp35.z + tmp57.y * tmp18 + phi67 * tmp33;
                tmp71 = float3(tmp68, tmp69, tmp70);
                float3 tmp72 = tmp71 * tmp10;
                tmp73 = tmp72.x + tmp72.y + tmp72.z;
                if (tmp73 > 0.0f)
                {
                    float tmp74 = tmp73 * 2.0f;
                    float tmp75 = tmp74 * tmp68 - tmp7;
                    float tmp76 = tmp74 * tmp69 - tmp8;
                    float tmp77 = tmp74 * tmp70 - tmp9;
                    sret_ptr.k2.x = tmp75;
                    sret_ptr.k2.y = tmp76;
                    sret_ptr.k2.z = tmp77;
                    sret_ptr.event_type = 10;
                    sret_ptr.bsdf_over_pdf.x = 1.0f;
                    sret_ptr.bsdf_over_pdf.y = 1.0f;
                    sret_ptr.bsdf_over_pdf.z = 1.0f;
                    tmp78 = float3(tmp75, tmp76, tmp77);
                    float3 tmp79 = tmp78 * float3(tmp13, tmp14, tmp15);
                    if (tmp79.x + tmp79.y + tmp79.z > 0.0f)
                    {
                        float3 tmp80 = tmp78 * tmp19;
                        float3 tmp81 = tmp78 * tmp71;
                        float tmp82 = tmp57.y * 2.0f;
                        tmp83 = min(tmp82 * tmp43 / tmp73, 1.0f);
                        tmp84 = min(tmp83, min(abs(tmp80.x + tmp80.y + tmp80.z) * tmp82 / abs(tmp81.x + tmp81.y + tmp81.z), 1.0f));
                        if (tmp84 > 0.0f)
                        {
                            sret_ptr.handle = 0;
                            float tmp85 = tmp84 / (tmp83 * tmp46);
                            sret_ptr.bsdf_over_pdf.x = tmp85 * 0.7024400234f;
                            sret_ptr.bsdf_over_pdf.y = tmp85 * 0.1239600182f;
                            sret_ptr.bsdf_over_pdf.z = tmp85 * 0.1636896431f;
                            phi_27 = phi40;
                            phi_29 = phi;
                        }
                        else
                        {
                            sret_ptr.pdf = 0.0f;
                            sret_ptr.event_type = 0;
                            phi_27 = phi40;
                            phi_29 = phi;
                        }
                    }
                    else
                    {
                        sret_ptr.pdf = 0.0f;
                        sret_ptr.event_type = 0;
                        phi_27 = phi40;
                        phi_29 = phi;
                    }
                }
                else
                {
                    sret_ptr.pdf = 0.0f;
                    sret_ptr.event_type = 0;
                    phi_27 = phi40;
                    phi_29 = phi;
                }
            }
        }
        else
        {
            tmp86 = 1.0f - tmp46;
            tmp87 = min(max((tmp47 - tmp46) / tmp86, 0.0f), 0.9999999404f);
            sret_ptr.xi.z = tmp87;
            float3 tmp88 = mdl_adapt_normal(state, tmp0);
            tmp89 = tmp88.x * tmp12;
            tmp90 = tmp88.y * tmp12;
            tmp91 = tmp88.z * tmp12;
            tmp92 = float3(tmp89, tmp90, tmp91);
            float3 tmp93 = tmp92 * tmp10;
            tmp94 = tmp93.x + tmp93.y + tmp93.z;
            float tmp95 = 1.0f - min(max(min(max(tmp94, 0.0f), 1.0f), 0.0f), 1.0f);
            float tmp96 = tmp95 * tmp95;
            tmp97 = tmp96 * tmp96 * (tmp95 * 0.3299999833f);
            tmp98 = tmp97 + 0.02999999933f;
            tmp99 = tmp98 > 0.0f;
            tmp100 = tmp98 < 1.0f;
            phi_in101 = false;
            phi_in103 = true;
            phi_in105 = false;
            phi108 = 0.0f;
            if (tmp99 || tmp100)
            {
                if (tmp99 && (tmp87 < tmp98 || tmp100 != true))
                {
                    tmp109 = 1.0f / tmp98;
                    phi_in101 = true;
                    phi_in103 = false;
                    phi_in105 = true;
                    phi108 = 1.0f;
                    if (tmp100)
                    {
                        sret_ptr.xi.z = tmp109 * tmp87;
                        phi_in101 = true;
                        phi_in103 = false;
                        phi_in105 = true;
                        phi108 = tmp109;
                    }
                }
                else
                {
                    phi_in101 = false;
                    phi_in103 = true;
                    phi_in105 = false;
                    phi108 = 0.0f;
                    if (tmp100)
                    {
                        phi_in101 = false;
                        phi_in103 = true;
                        phi_in105 = true;
                        phi108 = 1.0f;
                        if (tmp99)
                        {
                            tmp110 = 1.0f / (0.9700000286f - tmp97);
                            sret_ptr.xi.z = min(max((tmp87 - tmp98) * tmp110, 0.0f), 0.9999999404f);
                            phi_in101 = false;
                            phi_in103 = true;
                            phi_in105 = true;
                            phi108 = tmp110;
                        }
                    }
                }
            }
            phi102 = phi_in101;
            phi104 = phi_in103;
            phi106 = phi_in105;
            if (phi106)
            {
                if (phi102)
                {
                    float3 tmp111 = float3(sqrt(tmp5.x * tmp5.x + tmp5.y * tmp5.y + tmp5.z * tmp5.z), 0.0f, 0.0f);
                    float3 tmp112 = tmp5 / tmp111.xxx;
                    float tmp113 = mdl_read_argblock_as_float(state.arg_block_offset);
                    tmp114 = max(tmp113, 0.3136000037f);
                    tmp115 = max(tmp113, 0.7395999432f);
                    tmp116 = tmp92.zxy;
                    tmp117 = tmp92.yzx;
                    tmp118 = tmp116 * tmp112.yzx - tmp117 * tmp112.zxy;
                    float3 tmp119 = tmp118 * tmp118;
                    tmp120 = tmp119.x + tmp119.y + tmp119.z;
                    if (tmp120 < 9.999999939e-09f)
                    {
                        sret_ptr.pdf = 0.0f;
                        sret_ptr.event_type = 0;
                        index = 1;
                        newPhi = 0.0f;
                        newPhi55 = 0.0f;
                        newPhi56 = float3(0.0f, 0.0f, 0.0f);
                        newPhi57 = 0.0f;
                        newPhi58 = 0.0f;
                        newPhi59 = 0.0f;
                        newPhi60 = 0.0f;
                        newPhi61 = 0.0f;
                        newPhi62 = 0.0f;
                        newPhi63 = phi40;
                        newPhi64 = phi;
                    }
                    else
                    {
                        float tmp133 = 1.0f / sqrt(tmp120);
                        tmp134 = tmp133 * tmp118.x;
                        tmp135 = tmp133 * tmp118.y;
                        tmp136 = tmp133 * tmp118.z;
                        tmp137 = float3(tmp134, tmp135, tmp136);
                        tmp138 = tmp137.zxy * tmp117 - tmp137.yzx * tmp116;
                        bool tmp139 = phi == -1.0f;
                        phi_141 = phi;
                        if (tmp139)
                        {
                            sret_ptr.ior1.x = 1.0f;
                            sret_ptr.ior1.y = 1.0f;
                            sret_ptr.ior1.z = 1.0f;
                            phi_141 = 1.0f;
                        }
                        bool tmp142 = phi40 == -1.0f;
                        phi_144 = phi40;
                        if (tmp142)
                        {
                            sret_ptr.ior2.x = 1.0f;
                            sret_ptr.ior2.y = 1.0f;
                            sret_ptr.ior2.z = 1.0f;
                            phi_144 = 1.0f;
                        }
                        float3 tmp145 = tmp138 * tmp10;
                        float3 tmp146 = tmp137 * tmp10;
                        tmp147 = sret_ptr.xi.x;
                        tmp148 = sret_ptr.xi.y;
                        float tmp149 = tmp114 * (tmp145.x + tmp145.y + tmp145.z);
                        float tmp150 = tmp115 * (tmp146.x + tmp146.y + tmp146.z);
                        tmp151 = tmp94 * tmp94;
                        tmp152 = tmp149 * tmp149 + tmp150 * tmp150;
                        float3 tmp153 = float3(sqrt(tmp152 + tmp151), 0.0f, 0.0f);
                        tmp154 = float3(tmp149, abs(tmp94), tmp150) / tmp153.xxx;
                        phi156 = 1.0f;
                        phi158 = 0.0f;
                        phi160 = 0.0f;
                        if (tmp154.y < 0.9999899864f)
                        {
                            float3 tmp161 = tmp154 * float3(1.0f, 0.0f, 0.0f);
                            float3 tmp162 = tmp154 * float3(0.0f, 0.0f, 1.0f);
                            float3 tmp163 = tmp161.yzx - tmp162.zxy;
                            float3 tmp164 = float3(sqrt(tmp163.x * tmp163.x + tmp163.y * tmp163.y + tmp163.z * tmp163.z), 0.0f, 0.0f);
                            float3 tmp165 = tmp163 / tmp164.xxx;
                            phi156 = tmp165.x;
                            phi158 = tmp165.y;
                            phi160 = tmp165.z;
                        }
                        float3 tmp166 = float3(phi156, phi158, phi160);
                        float3 tmp167 = tmp166.yzx * tmp154.zxy - tmp166.zxy * tmp154.yzx;
                        tmp168 = tmp154.y + 1.0f;
                        tmp169 = 1.0f / tmp168;
                        tmp170 = sqrt(tmp147);
                        if (tmp148 < tmp169)
                        {
                            tmp171 = tmp168 * 3.141592741f * tmp148;
                            phi173 = 1.0f;
                            phi175 = tmp171;
                        }
                        else
                        {
                            tmp176 = (tmp148 - tmp169) * 3.141592741f / (1.0f - tmp169) + 3.141592741f;
                            phi173 = tmp154.y;
                            phi175 = tmp176;
                        }
                        float tmp177 = sin(phi175);
                        float tmp178 = cos(phi175);
                        float tmp179 = tmp178 * tmp170;
                        float tmp180 = phi173 * tmp170;
                        float tmp181 = tmp180 * tmp177;
                        float tmp182 = tmp179 * phi156;
                        float tmp183 = tmp179 * phi158;
                        float tmp184 = sqrt(max(1.0f - (tmp181 * tmp181 + tmp179 * tmp179), 0.0f));
                        float tmp185 = (tmp181 * tmp167.x + tmp182 + tmp184 * tmp154.x) * tmp114;
                        float tmp186 = max(tmp181 * tmp167.y + tmp183 + tmp184 * tmp154.y, 0.0f);
                        float tmp187 = (tmp181 * tmp167.z + tmp179 * phi160 + tmp184 * tmp154.z) * tmp115;
                        float3 tmp188 = float3(sqrt(tmp185 * tmp185 + tmp186 * tmp186 + tmp187 * tmp187), 0.0f, 0.0f);
                        float3 tmp189 = float3(tmp185, tmp186, tmp187) / tmp188.xxx;
                        if (tmp189.y == 0.0f)
                        {
                            sret_ptr.pdf = 0.0f;
                            sret_ptr.event_type = 0;
                            index = 1;
                            newPhi = 0.0f;
                            newPhi55 = 0.0f;
                            newPhi56 = float3(0.0f, 0.0f, 0.0f);
                            newPhi57 = 0.0f;
                            newPhi58 = 0.0f;
                            newPhi59 = 0.0f;
                            newPhi60 = 0.0f;
                            newPhi61 = 0.0f;
                            newPhi62 = 0.0f;
                            newPhi63 = phi_144;
                            newPhi64 = phi_141;
                        }
                        else
                        {
                            tmp190 = tmp189.x * tmp138.x + tmp189.y * tmp89 + tmp189.z * tmp134;
                            tmp191 = tmp189.x * tmp138.y + tmp189.y * tmp90 + tmp189.z * tmp135;
                            tmp192 = tmp189.x * tmp138.z + tmp189.y * tmp91 + tmp189.z * tmp136;
                            float3 tmp193 = float3(tmp190, tmp191, tmp192) * tmp10;
                            tmp194 = tmp193.x + tmp193.y + tmp193.z;
                            if (tmp194 > 0.0f)
                            {
                                float tmp195 = tmp194 * 2.0f;
                                tmp196 = tmp195 * tmp190 - tmp7;
                                tmp197 = tmp195 * tmp191 - tmp8;
                                tmp198 = tmp195 * tmp192 - tmp9;
                                sret_ptr.k2.x = tmp196;
                                sret_ptr.k2.y = tmp197;
                                sret_ptr.k2.z = tmp198;
                                sret_ptr.event_type = 10;
                                sret_ptr.bsdf_over_pdf.x = 1.0f;
                                sret_ptr.bsdf_over_pdf.y = 1.0f;
                                sret_ptr.bsdf_over_pdf.z = 1.0f;
                                tmp199 = float3(tmp196, tmp197, tmp198);
                                float3 tmp200 = tmp199 * float3(tmp13, tmp14, tmp15);
                                if (tmp200.x + tmp200.y + tmp200.z > 0.0f)
                                {
                                    tmp201 = tmp199 * tmp92;
                                    float tmp202 = tmp201.x + tmp201.y + tmp201.z;
                                    float3 tmp203 = tmp199 * tmp138;
                                    float3 tmp204 = tmp199 * tmp137;
                                    float tmp205 = (tmp203.x + tmp203.y + tmp203.z) * tmp114;
                                    float tmp206 = (tmp204.x + tmp204.y + tmp204.z) * tmp115;
                                    tmp207 = 2.0f / (sqrt((tmp206 * tmp206 + tmp205 * tmp205) / (tmp202 * tmp202) + 1.0f) + 1.0f);
                                    if (tmp207 * 2.0f / (sqrt(tmp152 / tmp151 + 1.0f) + 1.0f) > 0.0f)
                                    {
                                        sret_ptr.handle = 1;
                                        index = 0;
                                        newPhi = phi_144;
                                        newPhi55 = phi_141;
                                        newPhi56 = tmp201;
                                        newPhi57 = tmp207;
                                        newPhi58 = tmp207;
                                        newPhi59 = tmp207;
                                        newPhi60 = tmp198;
                                        newPhi61 = tmp197;
                                        newPhi62 = tmp196;
                                        newPhi63 = 0.0f;
                                        newPhi64 = 0.0f;
                                    }
                                    else
                                    {
                                        sret_ptr.pdf = 0.0f;
                                        sret_ptr.event_type = 0;
                                        index = 1;
                                        newPhi = 0.0f;
                                        newPhi55 = 0.0f;
                                        newPhi56 = float3(0.0f, 0.0f, 0.0f);
                                        newPhi57 = 0.0f;
                                        newPhi58 = 0.0f;
                                        newPhi59 = 0.0f;
                                        newPhi60 = 0.0f;
                                        newPhi61 = 0.0f;
                                        newPhi62 = 0.0f;
                                        newPhi63 = phi_144;
                                        newPhi64 = phi_141;
                                    }
                                }
                                else
                                {
                                    sret_ptr.pdf = 0.0f;
                                    sret_ptr.event_type = 0;
                                    index = 1;
                                    newPhi = 0.0f;
                                    newPhi55 = 0.0f;
                                    newPhi56 = float3(0.0f, 0.0f, 0.0f);
                                    newPhi57 = 0.0f;
                                    newPhi58 = 0.0f;
                                    newPhi59 = 0.0f;
                                    newPhi60 = 0.0f;
                                    newPhi61 = 0.0f;
                                    newPhi62 = 0.0f;
                                    newPhi63 = phi_144;
                                    newPhi64 = phi_141;
                                }
                            }
                            else
                            {
                                sret_ptr.pdf = 0.0f;
                                sret_ptr.event_type = 0;
                                index = 1;
                                newPhi = 0.0f;
                                newPhi55 = 0.0f;
                                newPhi56 = float3(0.0f, 0.0f, 0.0f);
                                newPhi57 = 0.0f;
                                newPhi58 = 0.0f;
                                newPhi59 = 0.0f;
                                newPhi60 = 0.0f;
                                newPhi61 = 0.0f;
                                newPhi62 = 0.0f;
                                newPhi63 = phi_144;
                                newPhi64 = phi_141;
                            }
                        }
                    }
                }
                else
                {
                    tmp208 = tmp2 * 0.6399999857f + 0.1999999881f;
                    tmp209 = min(max(state.text_results[0].y, 0.0f), 1.0f);
                    tmp210 = min(max(state.text_results[0].z, 0.0f), 1.0f);
                    tmp211 = min(max(state.text_results[0].w, 0.0f), 1.0f);
                    tmp212 = float3(tmp13, tmp14, tmp15);
                    float3 tmp213 = tmp212 * tmp19;
                    tmp214 = max(tmp213.x + tmp213.y + tmp213.z, 0.0f);
                    tmp215 = 3.141592741f / (tmp214 * 1.570796371f + 1.570796371f);
                    tmp216 = tmp215 + -1.0f;
                    tmp217 = sret_ptr.xi.x;
                    tmp218 = tmp217 < tmp216;
                    if (tmp218)
                    {
                        tmp219 = tmp217 / tmp216;
                        phi221 = tmp219;
                    }
                    else
                    {
                        tmp222 = min(max((tmp217 - tmp216) / (2.0f - tmp215), 0.0f), 0.9999999404f);
                        phi221 = tmp222;
                    }
                    sret_ptr.xi.x = phi221;
                    tmp223 = sret_ptr.xi.y;
                    bool tmp224 = phi221 == 0.0f;
                    phi226 = float3(0.0f, 1.0f, 0.0f);
                    if (!(tmp224 && tmp223 == 0.0f))
                    {
                        float tmp227 = phi221 * 2.0f;
                        float tmp228 = tmp223 * 2.0f;
                        tmp229 = tmp227 < 1.0f ? tmp227 : tmp227 + -2.0f;
                        tmp230 = tmp228 < 1.0f ? tmp228 : tmp228 + -2.0f;
                        tmp231 = tmp229 * tmp229;
                        tmp232 = tmp230 * tmp230;
                        if (tmp231 > tmp232)
                        {
                            tmp233 = tmp230 * -0.7853981853f / tmp229;
                            phi235 = tmp229;
                            phi237 = tmp233;
                            phi239 = tmp231;
                        }
                        else
                        {
                            tmp240 = tmp229 * 0.7853981853f / tmp230 + -1.570796371f;
                            phi235 = tmp230;
                            phi237 = tmp240;
                            phi239 = tmp232;
                        }
                        tmp241 = 1.0f - phi239;
                        phi226 = float3(0.0f, 1.0f, 0.0f);
                        if (tmp241 > 0.0f)
                        {
                            tmp242 = float3(sin(phi237) * phi235, sqrt(tmp241), cos(phi237) * phi235);
                            phi226 = tmp242;
                        }
                    }
                    tmp243 = phi226.x;
                    tmp244 = phi226.y;
                    tmp245 = phi226.z;
                    phi_247 = tmp35.x;
                    phi_249 = tmp35.y;
                    phi_251 = tmp35.z;
                    phi253 = tmp31;
                    phi255 = tmp32;
                    phi257 = tmp33;
                    if (tmp214 < 0.9990000129f)
                    {
                        float3 tmp258 = tmp20 * tmp212.yzx - tmp21 * tmp212.zxy;
                        float3 tmp259 = float3(sqrt(tmp258.x * tmp258.x + tmp258.y * tmp258.y + tmp258.z * tmp258.z), 0.0f, 0.0f);
                        float3 tmp260 = tmp258 / tmp259.xxx;
                        float3 tmp261 = tmp260.yzx * tmp20 - tmp260.zxy * tmp21;
                        phi_247 = tmp260.x;
                        phi_249 = tmp260.y;
                        phi_251 = tmp260.z;
                        phi253 = tmp261.x;
                        phi255 = tmp261.y;
                        phi257 = tmp261.z;
                    }
                    phi263 = tmp244;
                    phi265 = tmp245;
                    if (tmp245 > 0.0f)
                    {
                        if (tmp218)
                        {
                            tmp266 = -tmp245;
                            phi263 = tmp244;
                            phi265 = tmp266;
                        }
                        else
                        {
                            tmp267 = tmp245 * tmp214;
                            tmp268 = sqrt(max(1.0f - (tmp267 * tmp267 + tmp243 * tmp243), 0.0f));
                            phi263 = tmp268;
                            phi265 = tmp267;
                        }
                    }
                    float tmp269 = phi263 * tmp16 + phi_247 * tmp243 + phi265 * phi253;
                    float tmp270 = phi263 * tmp17 + phi_249 * tmp243 + phi265 * phi255;
                    float tmp271 = phi263 * tmp18 + phi_251 * tmp243 + phi265 * phi257;
                    float3 tmp272 = float3(sqrt(tmp269 * tmp269 + tmp270 * tmp270 + tmp271 * tmp271), 0.0f, 0.0f);
                    tmp273 = float3(tmp269, tmp270, tmp271) / tmp272.xxx;
                    sret_ptr.k2.x = tmp273.x;
                    sret_ptr.k2.y = tmp273.y;
                    sret_ptr.k2.z = tmp273.z;
                    float3 tmp274 = tmp273 * tmp212;
                    if (tmp274.x + tmp274.y + tmp274.z > 0.0f)
                    {
                        phi276 = tmp211;
                        phi278 = tmp210;
                        phi280 = tmp209;
                        if (tmp208 > 0.0f)
                        {
                            float tmp281 = min(max(tmp208, 0.0f), 1.0f);
                            tmp282 = 1.0f / (tmp281 * 0.2877933979f + 1.0f);
                            tmp283 = tmp282 * tmp281;
                            float3 tmp284 = tmp273 * tmp19;
                            tmp285 = tmp284.x + tmp284.y + tmp284.z;
                            float3 tmp286 = tmp273 * tmp10;
                            tmp287 = tmp286.x + tmp286.y + tmp286.z - tmp285 * tmp42;
                            phi289 = tmp287;
                            if (tmp287 > 0.0f)
                            {
                                tmp290 = tmp287 / max(tmp285, tmp42);
                                phi289 = tmp290;
                            }
                            float tmp291 = tmp283 * phi289 + tmp282;
                            tmp292 = tmp291 * tmp209;
                            tmp293 = tmp291 * tmp210;
                            tmp294 = tmp291 * tmp211;
                            phi276 = tmp294;
                            phi278 = tmp293;
                            phi280 = tmp292;
                        }
                        sret_ptr.event_type = 9;
                        sret_ptr.handle = 2;
                        tmp295 = tmp273 * tmp92;
                        index = 0;
                        newPhi = phi40;
                        newPhi55 = phi;
                        newPhi56 = tmp295;
                        newPhi57 = phi276;
                        newPhi58 = phi278;
                        newPhi59 = phi280;
                        newPhi60 = tmp273.z;
                        newPhi61 = tmp273.y;
                        newPhi62 = tmp273.x;
                        newPhi63 = 0.0f;
                        newPhi64 = 0.0f;
                    }
                    else
                    {
                        sret_ptr.pdf = 0.0f;
                        sret_ptr.event_type = 0;
                        index = 1;
                        newPhi = 0.0f;
                        newPhi55 = 0.0f;
                        newPhi56 = float3(0.0f, 0.0f, 0.0f);
                        newPhi57 = 0.0f;
                        newPhi58 = 0.0f;
                        newPhi59 = 0.0f;
                        newPhi60 = 0.0f;
                        newPhi61 = 0.0f;
                        newPhi62 = 0.0f;
                        newPhi63 = phi40;
                        newPhi64 = phi;
                    }
                }
                bool indexCmp = index == 0;
                phi_27 = newPhi63;
                phi_29 = newPhi64;
                if (indexCmp)
                {
                    float tmp296 = newPhi61 + tmp8;
                    float tmp297 = newPhi62 + tmp7;
                    float tmp298 = newPhi60 + tmp9;
                    float3 tmp299 = float3(sqrt(tmp296 * tmp296 + tmp298 * tmp298 + tmp297 * tmp297), 0.0f, 0.0f);
                    tmp300 = float3(tmp297, tmp296, tmp298) * tmp10 / tmp299.xxx;
                    if (phi104)
                    {
                        float tmp301 = 1.0f - min(max(abs(newPhi56.x + newPhi56.y + newPhi56.z), 0.0f), 1.0f);
                        float tmp302 = tmp301 * tmp301;
                        tmp303 = (1.0f - max(tmp98, tmp302 * tmp302 * (tmp301 * 0.3299999833f) + 0.02999999933f)) * phi108;
                        phi_305 = tmp303;
                        phi307 = newPhi57;
                        phi309 = tmp303;
                    }
                    else
                    {
                        float tmp310 = 1.0f - min(max(abs(tmp300.x + tmp300.y + tmp300.z), 0.0f), 1.0f);
                        float tmp311 = tmp310 * tmp310;
                        tmp312 = (tmp311 * tmp311 * (tmp310 * 0.3299999833f) + 0.02999999933f) * phi108;
                        phi_305 = tmp312;
                        phi307 = tmp312;
                        phi309 = newPhi57;
                    }
                    float3 tmp313 = float3(newPhi62, 0.0f, 0.0f);
                    float3 tmp314 = float3(tmp313.x, newPhi61, tmp313.z);
                    float3 tmp315 = float3(tmp314.x, tmp314.y, newPhi60);
                    float3 tmp316 = tmp315 * tmp19;
                    float tmp317 = (1.0f - max(tmp46, tex_lookup_float3_3d(1, float3(min(max(acos(min(max(abs(tmp316.x + tmp316.y + tmp316.z), 0.0f), 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, tmp45, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x)) / tmp86;
                    float tmp318 = tmp317 * phi_305;
                    sret_ptr.bsdf_over_pdf.x = tmp318 * newPhi59;
                    sret_ptr.bsdf_over_pdf.y = tmp318 * newPhi58;
                    sret_ptr.bsdf_over_pdf.z = phi309 * phi307 * tmp317;
                    phi_27 = newPhi;
                    phi_29 = newPhi55;
                }
            }
            else
            {
                sret_ptr.pdf = 0.0f;
                sret_ptr.event_type = 0;
                phi_27 = phi40;
                phi_29 = phi;
            }
        }
    }
    pdf_data.ior1.x = phi_29;
    pdf_data.ior1.y = sret_ptr.ior1.y;
    pdf_data.ior1.z = sret_ptr.ior1.z;
    pdf_data.ior2.x = phi_27;
    pdf_data.ior2.y = sret_ptr.ior2.y;
    pdf_data.ior2.z = sret_ptr.ior2.z;
    pdf_data.k1.x = tmp7;
    pdf_data.k1.y = tmp8;
    pdf_data.k1.z = tmp9;
    pdf_data.k2.x = sret_ptr.k2.x;
    pdf_data.k2.y = sret_ptr.k2.y;
    pdf_data.k2.z = sret_ptr.k2.z;
    gen_weighted_layer_pdf(pdf_data, state);
    float tmp319 = pdf_data.pdf;
    sret_ptr.pdf = tmp319;
    return;
}

void surface_scattering_evaluate(inout Bsdf_evaluate_data sret_ptr, in Shading_state_material state)
{
    float3 tmp0;
    float tmp2;
    float tmp3;
    float tmp4;
    float3 tmp5;
    float tmp7;
    float tmp8;
    float tmp9;
    float3 tmp10;
    float tmp12;
    float tmp13;
    float tmp14;
    float tmp15;
    float3 tmp16;
    float phi;
    float phi20;
    float phi22;
    float3 phi24;
    float tmp26;
    float tmp27;
    float tmp28;
    float tmp29;
    float3 tmp30;
    float tmp32;
    float tmp40;
    float tmp42;
    float tmp44;
    float3 tmp49;
    float tmp50;
    int tmp51;
    int tmp52;
    float tmp56;
    float tmp58;
    float tmp60;
    float tmp61;
    float tmp62;
    float3 tmp63;
    float tmp65;
    float tmp68;
    float phi_70;
    float tmp71;
    float tmp72;
    float tmp73;
    float3 tmp74;
    float3 tmp75;
    float tmp77;
    bool tmp78;
    float tmp80;
    float tmp81;
    float phi83;
    float phi_85;
    float phi_87;
    float tmp89;
    float tmp90;
    float tmp91;
    float tmp99;
    float tmp103;
    float tmp104;
    float3 tmp105;
    float3 tmp106;
    float3 tmp107;
    float tmp109;
    float phi111;
    float3 phi113;
    float3 tmp115;
    float3 tmp116;
    float tmp117;
    float3 tmp122;
    float tmp124;
    float tmp142;
    float3 tmp144;
    int tmp145;
    float tmp149;
    float tmp150;
    float tmp151;
    float tmp152;
    float tmp153;
    float phi155;
    float tmp158;
    float tmp160;
    float phi162;
    float phi164;
    float phi166;
    float tmp167;
    float tmp168;
    float tmp169;
    float tmp171;
    float tmp172;
    float tmp174;
    float tmp176;
    float phi178;
    float tmp179;
    float tmp181;
    float tmp182;
    float tmp183;
    int tmp184;
    float tmp186;
    sret_ptr.bsdf_diffuse[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[3] = float3(0.0f, 0.0f, 0.0f);
    tmp0 = state.text_results[1].xyz;
    float3 tmp1 = mdl_adapt_normal(state, tmp0);
    tmp2 = state.text_results[0].x;
    tmp3 = pow(0.5171840191f - tmp2 * 0.3392000198f, 3.789999962f);
    tmp4 = 1.0f / max(tmp3, 1.000000012e-07f);
    tmp5 = state.tangent_u[0];
    float3 tmp6 = state.geom_normal;
    tmp7 = sret_ptr.k1.x;
    tmp8 = sret_ptr.k1.y;
    tmp9 = sret_ptr.k1.z;
    tmp10 = float3(tmp7, tmp8, tmp9);
    float3 tmp11 = tmp10 * tmp6;
    tmp12 = asfloat((asint(tmp11.x + tmp11.y + tmp11.z) & -2147483648) | 1065353216);
    tmp13 = tmp6.x * tmp12;
    tmp14 = tmp6.y * tmp12;
    tmp15 = tmp6.z * tmp12;
    tmp16 = float3(tmp1.x * tmp12, tmp1.y * tmp12, tmp1.z * tmp12);
    float3 tmp17 = tmp16.zxy * tmp5.yzx - tmp16.yzx * tmp5.zxy;
    float3 tmp18 = tmp17 * tmp17;
    if (tmp18.x + tmp18.y + tmp18.z < 9.999999939e-09f)
    {
        sret_ptr.pdf = 0.0f;
        phi = 0.0f;
        phi20 = 0.0f;
        phi22 = 0.0f;
        phi24 = float3(0.0f, 0.0f, 0.0f);
    }
    else
    {
        if (sret_ptr.ior1.x == -1.0f)
        {
            sret_ptr.ior1.x = 1.0f;
            sret_ptr.ior1.y = 1.0f;
            sret_ptr.ior1.z = 1.0f;
        }
        if (sret_ptr.ior2.x == -1.0f)
        {
            sret_ptr.ior2.x = 1.0f;
            sret_ptr.ior2.y = 1.0f;
            sret_ptr.ior2.z = 1.0f;
        }
        float3 tmp25 = tmp16 * tmp10;
        tmp26 = abs(tmp25.x + tmp25.y + tmp25.z);
        tmp27 = sret_ptr.k2.x;
        tmp28 = sret_ptr.k2.y;
        tmp29 = sret_ptr.k2.z;
        tmp30 = float3(tmp27, tmp28, tmp29);
        float3 tmp31 = tmp30 * tmp16;
        tmp32 = abs(tmp31.x + tmp31.y + tmp31.z);
        float3 tmp33 = tmp30 * float3(tmp13, tmp14, tmp15);
        if (tmp33.x + tmp33.y + tmp33.z < 0.0f)
        {
            sret_ptr.pdf = 0.0f;
            phi = 0.0f;
            phi20 = tmp32;
            phi22 = tmp26;
            phi24 = float3(0.0f, 0.0f, 0.0f);
        }
        else
        {
            float tmp34 = tmp27 + tmp7;
            float tmp35 = tmp28 + tmp8;
            float tmp36 = tmp29 + tmp9;
            float3 tmp37 = float3(sqrt(tmp35 * tmp35 + tmp34 * tmp34 + tmp36 * tmp36), 0.0f, 0.0f);
            float3 tmp38 = float3(tmp34, tmp35, tmp36) / tmp37.xxx;
            float3 tmp39 = tmp38 * tmp16;
            tmp40 = tmp39.x + tmp39.y + tmp39.z;
            float3 tmp41 = tmp38 * tmp10;
            tmp42 = tmp41.x + tmp41.y + tmp41.z;
            float3 tmp43 = tmp38 * tmp30;
            tmp44 = tmp43.x + tmp43.y + tmp43.z;
            if (tmp44 < 0.0f || (tmp40 < 0.0f || tmp42 < 0.0f))
            {
                sret_ptr.pdf = 0.0f;
                phi = 0.0f;
                phi20 = tmp32;
                phi22 = tmp26;
                phi24 = float3(0.0f, 0.0f, 0.0f);
            }
            else
            {
                float tmp45 = tmp40 * 2.0f;
                float tmp46 = min(tmp45 * tmp26 / tmp42, 1.0f);
                float tmp47 = tmp40 * (tmp4 * 0.03978873417f + 0.07957746834f) * pow(sqrt(max(1.0f - tmp40 * tmp40, 0.0f)), tmp4) / (tmp40 * tmp26);
                float tmp48 = tmp47 * min(tmp46, min(tmp45 * tmp32 / tmp44, 1.0f));
                tmp49 = float3(tmp48, tmp48, tmp48);
                tmp50 = tmp47 * tmp46;
                sret_ptr.pdf = tmp50;
                phi = tmp50;
                phi20 = tmp32;
                phi22 = tmp26;
                phi24 = tmp49;
            }
        }
    }
    tmp51 = sret_ptr.handle_offset;
    tmp52 = -tmp51;
    if (uint(tmp52) < 4u)
    {
        int tmp53 = tmp52;
        sret_ptr.bsdf_glossy[tmp53].x = sret_ptr.bsdf_glossy[tmp53].x + phi24.x * 0.7024400234f;
        sret_ptr.bsdf_glossy[tmp53].y = sret_ptr.bsdf_glossy[tmp53].y + phi24.y * 0.1239600182f;
        sret_ptr.bsdf_glossy[tmp53].z = sret_ptr.bsdf_glossy[tmp53].z + phi24.z * 0.1636896431f;
    }
    float tmp54 = min(max(tmp3, 0.0f), 1.0f);
    float tmp55 = min(max(sqrt(tmp54 * tmp54), 0.0f), 1.0f) * 0.984375f + 0.0078125f;
    tmp56 = tex_lookup_float3_3d(1, float3(min(max(acos(min(max(phi22, 0.0f), 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, tmp55, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x;
    float tmp57 = max(phi20, 0.0f);
    tmp58 = 1.0f - max(tmp56, tex_lookup_float3_3d(1, float3(min(max(acos(min(tmp57, 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, tmp55, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x);
    float3 tmp59 = mdl_adapt_normal(state, tmp0);
    tmp60 = tmp59.x * tmp12;
    tmp61 = tmp59.y * tmp12;
    tmp62 = tmp59.z * tmp12;
    tmp63 = float3(tmp60, tmp61, tmp62);
    float3 tmp64 = tmp63 * tmp10;
    tmp65 = tmp64.x + tmp64.y + tmp64.z;
    float tmp66 = 1.0f - min(max(min(max(tmp65, 0.0f), 1.0f), 0.0f), 1.0f);
    float tmp67 = tmp66 * tmp66;
    tmp68 = tmp67 * tmp67 * (tmp66 * 0.3299999833f) + 0.02999999933f;
    phi_70 = 0.0f;
    if (!(tmp68 < 0.0f))
    {
        tmp71 = sret_ptr.k2.x;
        tmp72 = sret_ptr.k2.y;
        tmp73 = sret_ptr.k2.z;
        tmp74 = float3(tmp71, tmp72, tmp73);
        tmp75 = float3(tmp13, tmp14, tmp15);
        float3 tmp76 = tmp74 * tmp75;
        tmp77 = tmp76.x + tmp76.y + tmp76.z;
        tmp78 = tmp77 < 0.0f;
        float3 tmp79 = tmp74 * tmp63;
        tmp80 = tmp79.x + tmp79.y + tmp79.z;
        tmp81 = abs(tmp80);
        phi83 = tmp73;
        phi_85 = tmp71;
        phi_87 = tmp72;
        if (tmp78)
        {
            float tmp88 = tmp81 * 2.0f;
            tmp89 = tmp88 * tmp60 + tmp71;
            tmp90 = tmp88 * tmp61 + tmp72;
            tmp91 = tmp88 * tmp62 + tmp73;
            phi83 = tmp91;
            phi_85 = tmp89;
            phi_87 = tmp90;
        }
        float tmp92 = phi_87 + tmp8;
        float tmp93 = phi_85 + tmp7;
        float tmp94 = phi83 + tmp9;
        float3 tmp95 = float3(sqrt(tmp93 * tmp93 + tmp94 * tmp94 + tmp92 * tmp92), 0.0f, 0.0f);
        float3 tmp96 = float3(tmp93, tmp92, tmp94) * tmp10 / tmp95.xxx;
        float tmp97 = 1.0f - min(max(abs(tmp96.x + tmp96.y + tmp96.z), 0.0f), 1.0f);
        float tmp98 = tmp97 * tmp97;
        tmp99 = (tmp98 * tmp98 * (tmp97 * 0.3299999833f) + 0.02999999933f) * tmp58;
        float3 tmp100 = float3(sqrt(tmp5.x * tmp5.x + tmp5.y * tmp5.y + tmp5.z * tmp5.z), 0.0f, 0.0f);
        float3 tmp101 = tmp5 / tmp100.xxx;
        float tmp102 = mdl_read_argblock_as_float(state.arg_block_offset);
        tmp103 = max(tmp102, 0.3136000037f);
        tmp104 = max(tmp102, 0.7395999432f);
        tmp105 = tmp63.zxy;
        tmp106 = tmp63.yzx;
        tmp107 = tmp105 * tmp101.yzx - tmp106 * tmp101.zxy;
        float3 tmp108 = tmp107 * tmp107;
        tmp109 = tmp108.x + tmp108.y + tmp108.z;
        phi111 = 0.0f;
        phi113 = float3(0.0f, 0.0f, 0.0f);
        if (!(tmp109 < 9.999999939e-09f))
        {
            float tmp114 = 1.0f / sqrt(tmp109);
            tmp115 = float3(tmp114 * tmp107.x, tmp114 * tmp107.y, tmp114 * tmp107.z);
            tmp116 = tmp115.zxy * tmp106 - tmp115.yzx * tmp105;
            if (sret_ptr.ior1.x == -1.0f)
            {
                sret_ptr.ior1.x = 1.0f;
                sret_ptr.ior1.y = 1.0f;
                sret_ptr.ior1.z = 1.0f;
            }
            if (sret_ptr.ior2.x == -1.0f)
            {
                sret_ptr.ior2.x = 1.0f;
                sret_ptr.ior2.y = 1.0f;
                sret_ptr.ior2.z = 1.0f;
            }
            tmp117 = abs(tmp65);
            phi111 = 0.0f;
            phi113 = float3(0.0f, 0.0f, 0.0f);
            if (!tmp78)
            {
                float tmp118 = tmp71 + tmp7;
                float tmp119 = tmp72 + tmp8;
                float tmp120 = tmp73 + tmp9;
                float3 tmp121 = float3(sqrt(tmp119 * tmp119 + tmp118 * tmp118 + tmp120 * tmp120), 0.0f, 0.0f);
                tmp122 = float3(tmp118, tmp119, tmp120) / tmp121.xxx;
                float3 tmp123 = tmp122 * tmp63;
                tmp124 = tmp123.x + tmp123.y + tmp123.z;
                float3 tmp125 = tmp122 * tmp10;
                float3 tmp126 = tmp122 * tmp74;
                phi111 = 0.0f;
                phi113 = float3(0.0f, 0.0f, 0.0f);
                if (!(tmp126.x + tmp126.y + tmp126.z < 0.0f || (tmp124 < 0.0f || tmp125.x + tmp125.y + tmp125.z < 0.0f)))
                {
                    float3 tmp127 = tmp122 * tmp116;
                    float3 tmp128 = tmp122 * tmp115;
                    float tmp129 = 1.0f / tmp103;
                    float tmp130 = 1.0f / tmp104;
                    float tmp131 = tmp129 * (tmp127.x + tmp127.y + tmp127.z);
                    float tmp132 = tmp130 * (tmp128.x + tmp128.y + tmp128.z);
                    float tmp133 = tmp131 * tmp131 + tmp124 * tmp124 + tmp132 * tmp132;
                    float3 tmp134 = tmp116 * tmp10;
                    float3 tmp135 = tmp115 * tmp10;
                    float3 tmp136 = tmp74 * tmp116;
                    float3 tmp137 = tmp74 * tmp115;
                    float tmp138 = tmp103 * (tmp134.x + tmp134.y + tmp134.z);
                    float tmp139 = tmp104 * (tmp135.x + tmp135.y + tmp135.z);
                    float tmp140 = tmp103 * (tmp136.x + tmp136.y + tmp136.z);
                    float tmp141 = tmp104 * (tmp137.x + tmp137.y + tmp137.z);
                    tmp142 = tmp124 * 0.1591549367f * tmp129 * tmp130 / (tmp133 * tmp133 * (tmp124 * tmp117) * (sqrt((tmp138 * tmp138 + tmp139 * tmp139) / (tmp65 * tmp65) + 1.0f) + 1.0f));
                    float tmp143 = tmp142 * 2.0f / (sqrt((tmp141 * tmp141 + tmp140 * tmp140) / (tmp80 * tmp80) + 1.0f) + 1.0f);
                    tmp144 = float3(tmp143, tmp143, tmp143);
                    phi111 = tmp142;
                    phi113 = tmp144;
                }
            }
        }
        tmp145 = 1 - tmp51;
        if (uint(tmp145) < 4u)
        {
            int tmp146 = tmp145;
            sret_ptr.bsdf_glossy[tmp146].x = sret_ptr.bsdf_glossy[tmp146].x + phi113.x * tmp99;
            sret_ptr.bsdf_glossy[tmp146].y = sret_ptr.bsdf_glossy[tmp146].y + phi113.y * tmp99;
            sret_ptr.bsdf_glossy[tmp146].z = sret_ptr.bsdf_glossy[tmp146].z + phi113.z * tmp99;
        }
        float tmp147 = 1.0f - min(max(tmp81, 0.0f), 1.0f);
        float tmp148 = tmp147 * tmp147;
        tmp149 = (1.0f - max(tmp68, tmp148 * tmp148 * (tmp147 * 0.3299999833f) + 0.02999999933f)) * tmp58;
        tmp150 = tmp2 * 0.6399999857f + 0.1999999881f;
        tmp151 = min(max(state.text_results[0].y, 0.0f), 1.0f);
        tmp152 = min(max(state.text_results[0].z, 0.0f), 1.0f);
        tmp153 = min(max(state.text_results[0].w, 0.0f), 1.0f);
        phi155 = 0.0f;
        if (tmp77 > 0.0f)
        {
            float3 tmp156 = tmp16 * tmp75;
            float3 tmp157 = tmp74 * tmp16;
            tmp158 = tmp157.x + tmp157.y + tmp157.z;
            float tmp159 = max(tmp158, 0.0f);
            tmp160 = tmp159 / (max(tmp156.x + tmp156.y + tmp156.z, 0.0f) * 1.570796371f + 1.570796371f);
            phi162 = 0.0f;
            phi164 = 0.0f;
            phi166 = 0.0f;
            if (tmp159 > 0.0f)
            {
                tmp167 = tmp151 * tmp160;
                tmp168 = tmp152 * tmp160;
                tmp169 = tmp153 * tmp160;
                phi162 = tmp167;
                phi164 = tmp168;
                phi166 = tmp169;
                if (tmp150 > 0.0f)
                {
                    float tmp170 = min(max(tmp150, 0.0f), 1.0f);
                    tmp171 = 1.0f / (tmp170 * 0.2877933979f + 1.0f);
                    tmp172 = tmp171 * tmp170;
                    float3 tmp173 = tmp16 * tmp10;
                    tmp174 = tmp173.x + tmp173.y + tmp173.z;
                    float3 tmp175 = tmp74 * tmp10;
                    tmp176 = tmp175.x + tmp175.y + tmp175.z - tmp158 * tmp174;
                    phi178 = tmp176;
                    if (tmp176 > 0.0f)
                    {
                        tmp179 = tmp176 / max(tmp174, tmp158);
                        phi178 = tmp179;
                    }
                    float tmp180 = tmp172 * phi178 + tmp171;
                    tmp181 = tmp180 * tmp167;
                    tmp182 = tmp180 * tmp168;
                    tmp183 = tmp180 * tmp169;
                    phi162 = tmp181;
                    phi164 = tmp182;
                    phi166 = tmp183;
                }
            }
            tmp184 = 2 - tmp51;
            phi155 = tmp160;
            if (uint(tmp184) < 4u)
            {
                int tmp185 = tmp184;
                sret_ptr.bsdf_diffuse[tmp185].x = sret_ptr.bsdf_diffuse[tmp185].x + phi162 * tmp149;
                sret_ptr.bsdf_diffuse[tmp185].y = sret_ptr.bsdf_diffuse[tmp185].y + phi164 * tmp149;
                sret_ptr.bsdf_diffuse[tmp185].z = sret_ptr.bsdf_diffuse[tmp185].z + phi166 * tmp149;
                phi155 = tmp160;
            }
        }
        tmp186 = (phi111 - phi155) * tmp68 + phi155;
        phi_70 = tmp186;
    }
    sret_ptr.pdf = (phi - phi_70) * tmp56 + phi_70;
    return;
}

void surface_scattering_pdf(inout Bsdf_pdf_data sret_ptr, in Shading_state_material state)
{
    gen_weighted_layer_pdf(sret_ptr, state);
    return;
}

void surface_scattering_auxiliary(inout Bsdf_auxiliary_data sret_ptr, in Shading_state_material state)
{
    float tmp7;
    float tmp11;
    float tmp12;
    float tmp13;
    float tmp17;
    int tmp18;
    int post_loop_index;
    int tmp20;
    float tmp21;
    float tmp22;
    float tmp23;
    float tmp25;
    int tmp26;
    sret_ptr.albedo_diffuse[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[3] = float3(0.0f, 0.0f, 0.0f);
    float3 tmp0 = mdl_adapt_normal(state, state.text_results[1].xyz);
    float tmp1 = sret_ptr.k1.x;
    float tmp2 = sret_ptr.k1.y;
    float tmp3 = sret_ptr.k1.z;
    float3 tmp4 = float3(tmp1, tmp2, tmp3);
    float3 tmp5 = tmp4 * tmp0;
    float tmp6 = min(max(pow(0.5171840191f - state.text_results[0].x * 0.3392000198f, 3.789999962f), 0.0f), 1.0f);
    tmp7 = tex_lookup_float3_3d(1, float3(min(max(acos(min(max(min(max(tmp5.x + tmp5.y + tmp5.z, 0.0f), 1.0f), 0.0f), 1.0f)) * 0.6366197467f, 0.0f), 1.0f) * 0.9692307711f + 0.007692307699f, min(max(sqrt(tmp6 * tmp6), 0.0f), 1.0f) * 0.984375f + 0.0078125f, 0.0f), 0, 0, 0, float2(0.0f, 1.0f), float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f).x;
    float3 tmp8 = state.tangent_u[0];
    float3 tmp9 = state.geom_normal * tmp4;
    float tmp10 = asfloat((asint(tmp9.x + tmp9.y + tmp9.z) & -2147483648) | 1065353216);
    tmp11 = tmp0.x * tmp10;
    tmp12 = tmp0.y * tmp10;
    tmp13 = tmp0.z * tmp10;
    float3 tmp14 = float3(tmp11, tmp12, tmp13);
    float3 tmp15 = tmp14.zxy * tmp8.yzx - tmp14.yzx * tmp8.zxy;
    float3 tmp16 = tmp15 * tmp15;
    if (!(tmp16.x + tmp16.y + tmp16.z < 9.999999939e-09f))
    {
        tmp17 = min(max(1.0f - tmp7, 0.0f), 1.0f);
        tmp18 = -sret_ptr.handle_offset;
        if (uint(tmp18) < 4u)
        {
            int tmp19 = tmp18;
            sret_ptr.albedo_diffuse[tmp19].x = sret_ptr.albedo_diffuse[tmp19].x + tmp17;
            sret_ptr.albedo_diffuse[tmp19].y = sret_ptr.albedo_diffuse[tmp19].y + tmp17;
            sret_ptr.albedo_diffuse[tmp19].z = sret_ptr.albedo_diffuse[tmp19].z + tmp17;
            sret_ptr.albedo_glossy[tmp19].x = sret_ptr.albedo_glossy[tmp19].x + min(max(tmp7 * 0.7024400234f, 0.0f), 1.0f);
            sret_ptr.albedo_glossy[tmp19].y = sret_ptr.albedo_glossy[tmp19].y + min(max(tmp7 * 0.1239600182f, 0.0f), 1.0f);
            sret_ptr.albedo_glossy[tmp19].z = sret_ptr.albedo_glossy[tmp19].z + min(max(tmp7 * 0.1636896431f, 0.0f), 1.0f);
            sret_ptr.normal[tmp19].x = sret_ptr.normal[tmp19].x + tmp11;
            sret_ptr.normal[tmp19].y = sret_ptr.normal[tmp19].y + tmp12;
            sret_ptr.normal[tmp19].z = sret_ptr.normal[tmp19].z + tmp13;
            sret_ptr.roughness[tmp19].z = sret_ptr.roughness[tmp19].z + 1.0f;
        }
    }
    post_loop_index = 0;
    do
    {
        tmp20 = post_loop_index;
        tmp21 = sret_ptr.normal[tmp20].x;
        tmp22 = sret_ptr.normal[tmp20].y;
        tmp23 = sret_ptr.normal[tmp20].z;
        if (tmp21 != 0.0f || (tmp22 != 0.0f || tmp23 != 0.0f))
        {
            float3 tmp24 = float3(sqrt(tmp22 * tmp22 + tmp21 * tmp21 + tmp23 * tmp23), 0.0f, 0.0f);
            sret_ptr.normal[tmp20] = float3(tmp21, tmp22, tmp23) / tmp24.xxx;
        }
        tmp25 = sret_ptr.roughness[tmp20].z;
        if (!(tmp25 == 0.0f))
        {
            sret_ptr.roughness[tmp20].x = sret_ptr.roughness[tmp20].x / tmp25;
            sret_ptr.roughness[tmp20].y = sret_ptr.roughness[tmp20].y / tmp25;
        }
        tmp26 = post_loop_index + 1;
        bool tmp27 = uint(post_loop_index) < 3u;
        post_loop_index = tmp26;
        if (!tmp27)
            break;
    } while (true);
    return;
}

void surface_emission_emission_sample(inout Edf_sample_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.k1.x = 0.0f;
    sret_ptr.k1.y = 0.0f;
    sret_ptr.k1.z = 0.0f;
    sret_ptr.edf_over_pdf.x = 0.0f;
    sret_ptr.edf_over_pdf.y = 0.0f;
    sret_ptr.edf_over_pdf.z = 0.0f;
    sret_ptr.event_type = 0;
    sret_ptr.pdf = 0.0f;
    return;
}

void surface_emission_emission_evaluate(inout Edf_evaluate_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.edf[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.pdf = 0.0f;
    return;
}

void surface_emission_emission_pdf(inout Edf_pdf_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.pdf = 0.0f;
    return;
}

void surface_emission_emission_auxiliary(inout Edf_auxiliary_data sret_ptr, inout Shading_state_material state)
{
    return;
}

float3 surface_emission_intensity(in Shading_state_material state)
{
    return float3(0.0f, 0.0f, 0.0f);
}

int surface_emission_mode(in Shading_state_material state)
{
    return 0;
}

void backface_scattering_sample(inout Bsdf_sample_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.event_type = 0;
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_scattering_evaluate(inout Bsdf_evaluate_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.bsdf_diffuse[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_scattering_pdf(inout Bsdf_pdf_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_scattering_auxiliary(inout Bsdf_auxiliary_data sret_ptr, in Shading_state_material state)
{
    int post_loop_index;
    int tmp0;
    float tmp1;
    float tmp2;
    float tmp3;
    float tmp5;
    int tmp6;
    sret_ptr.albedo_diffuse[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_diffuse[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.albedo_glossy[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.normal[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.roughness[3] = float3(0.0f, 0.0f, 0.0f);
    post_loop_index = 0;
    do
    {
        tmp0 = post_loop_index;
        tmp1 = sret_ptr.normal[tmp0].x;
        tmp2 = sret_ptr.normal[tmp0].y;
        tmp3 = sret_ptr.normal[tmp0].z;
        if (tmp1 != 0.0f || (tmp2 != 0.0f || tmp3 != 0.0f))
        {
            float3 tmp4 = float3(sqrt(tmp2 * tmp2 + tmp1 * tmp1 + tmp3 * tmp3), 0.0f, 0.0f);
            sret_ptr.normal[tmp0] = float3(tmp1, tmp2, tmp3) / tmp4.xxx;
        }
        tmp5 = sret_ptr.roughness[tmp0].z;
        if (!(tmp5 == 0.0f))
        {
            sret_ptr.roughness[tmp0].x = sret_ptr.roughness[tmp0].x / tmp5;
            sret_ptr.roughness[tmp0].y = sret_ptr.roughness[tmp0].y / tmp5;
        }
        tmp6 = post_loop_index + 1;
        bool tmp7 = uint(post_loop_index) < 3u;
        post_loop_index = tmp6;
        if (!tmp7)
            break;
    } while (true);
    return;
}

void backface_emission_emission_sample(inout Edf_sample_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.k1.x = 0.0f;
    sret_ptr.k1.y = 0.0f;
    sret_ptr.k1.z = 0.0f;
    sret_ptr.edf_over_pdf.x = 0.0f;
    sret_ptr.edf_over_pdf.y = 0.0f;
    sret_ptr.edf_over_pdf.z = 0.0f;
    sret_ptr.event_type = 0;
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_emission_emission_evaluate(inout Edf_evaluate_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.edf[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.edf[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_emission_emission_pdf(inout Edf_pdf_data sret_ptr, in Shading_state_material state)
{
    sret_ptr.pdf = 0.0f;
    return;
}

void backface_emission_emission_auxiliary(inout Edf_auxiliary_data sret_ptr, inout Shading_state_material state)
{
    return;
}

float3 backface_emission_intensity(in Shading_state_material state)
{
    return float3(0.0f, 0.0f, 0.0f);
}

int backface_emission_mode(in Shading_state_material state)
{
    return 0;
}

float3 volume_absorption_coefficient(in Shading_state_material state)
{
    return float3(0.0f, 0.0f, 0.0f);
}

float3 volume_scattering_coefficient(in Shading_state_material state)
{
    return float3(0.0f, 0.0f, 0.0f);
}

float3 geometry_normal(in Shading_state_material state)
{
    return state.normal;
}

float geometry_cutout_opacity(in Shading_state_material state)
{
    return 1.0f;
}

float3 geometry_displacement(in Shading_state_material state)
{
    return float3(0.0f, 0.0f, 0.0f);
}

float surface_scattering_layer_multiscatter_layer_roughness_u(in Shading_state_material state)
{
    return max(mdl_read_argblock_as_float(state.arg_block_offset), 0.3136000037f);
}

float surface_scattering_layer_multiscatter_layer_roughness_v(in Shading_state_material state)
{
    return max(mdl_read_argblock_as_float(state.arg_block_offset), 0.7395999432f);
}

float3 surface_scattering_layer_multiscatter_layer_tangent_u(in Shading_state_material state)
{
    float3 tmp0 = state.tangent_u[0];
    float3 tmp1 = float3(sqrt(tmp0.x * tmp0.x + tmp0.y * tmp0.y + tmp0.z * tmp0.z), 0.0f, 0.0f);
    return tmp0 / tmp1.xxx;
}

float3 surface_scattering_layer_multiscatter_layer_tint(in Shading_state_material state)
{
    return float3(1.0f, 1.0f, 1.0f);
}

float surface_scattering_layer_multiscatter_base_roughness(in Shading_state_material state)
{
    return state.text_results[0].x * 0.6399999857f + 0.1999999881f;
}

float3 surface_scattering_layer_multiscatter_base_tint(in Shading_state_material state)
{
    return state.text_results[0].yzw;
}
float mdl_lambda_roughness_u(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 1:
        return surface_scattering_layer_multiscatter_layer_roughness_u(state);
    case 2:
        return surface_scattering_layer_multiscatter_base_roughness(state);
    default:
        break;
    }
    return 0.0f;
}

float mdl_lambda_roughness_v(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 1:
        return surface_scattering_layer_multiscatter_layer_roughness_v(state);
    default:
        break;
    }
    return 0.0f;
}

float3 mdl_lambda_tangent(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 1:
        return surface_scattering_layer_multiscatter_layer_tangent_u(state);
    default:
        break;
    }
    return float3(0.0f, 0.0f, 0.0f);
}

float3 mdl_lambda_tint(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 1:
        return surface_scattering_layer_multiscatter_layer_tint(state);
    case 2:
        return surface_scattering_layer_multiscatter_base_tint(state);
    default:
        break;
    }
    return float3(0.0f, 0.0f, 0.0f);
}

} // mdl_velvet_material_ns

public struct MDLVelvetMaterialInstance : IMaterialInstance
{
    mdl_velvet_material_ns::Shading_state_material state;
    float3 ior1, ior2;

    public __init(const ShadingData sd_ws,
                  const bool fix_normal = true)
    {
        state = {};

        Frame sf = sd_ws.shading_frame;

#if !MDL_USE_RENDERER_ADAPT_NORMAL
        if (fix_normal)
            sd_ws.adjust_shading_normal(sf);
#endif

        state.normal = sf.normal;
        state.geom_normal = sd_ws.oriented_face_normal();
        if (dot(state.normal, state.geom_normal) < 0.f)
            state.normal = -state.normal;
        state.position = sd_ws.position;
        state.animation_time = 0.f;
        // Flipping v coordinate (within the same given udim range)
        state.text_coords[0] = float3(sd_ws.uv.x, floor(sd_ws.uv.y) + 1 - frac(sd_ws.uv.y), 0);
        state.tangent_u[0] = sf.tangent;
        state.tangent_v[0] = -sf.bitangent;
        state.ro_data_segment_offset = 0;
        state.world_to_object = float4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
        state.object_to_world = float4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
        // state.object_id
        state.meters_per_scene_unit = 1.f;
        state.arg_block_offset = 0;
        state.renderer_state.V = sd_ws.view;

        mdl_velvet_material_ns::init(state);

        const float3 exteriorIoR = sd_ws.ior;
        const float3 interiorIoR = mdl_velvet_material_ns::ior(state);

        this.ior1 = select(sd_ws.front_facing, exteriorIoR, interiorIoR);
        this.ior2 = select(sd_ws.front_facing, interiorIoR, exteriorIoR);
    }

    __init(const mdl_velvet_material_ns::Shading_state_material state, const float3 ior1, const float3 ior2)
    {
        this.state = state;
        this.ior1 = ior1;
        this.ior2 = ior2;
    }

    float3 eval(const ShadingData sd_ws, const float3 wo, inout UniformSampleGenerator sg)
    {
        mdl_velvet_material_ns::Bsdf_evaluate_data eval_data = {};
        eval_data.ior1 = ior1;     // IOR current medium
        eval_data.ior2 = ior2;     // IOR other side
        eval_data.k1 = sd_ws.view; // outgoing direction
        eval_data.k2 = wo;         // incoming direction

        float3 result = float3(0.f);
        uint surface_scatter_bsdf_count = mdl_velvet_material_ns::MATERIAL_DATA_NAME.surface_scatter_bsdf_count;
        uint offset = 0;
        for (; offset < surface_scatter_bsdf_count; offset += MDL_DF_HANDLE_SLOT_MODE)
        {
            eval_data.handle_offset = offset;
            mdl_velvet_material_ns::surface_scattering_evaluate(eval_data, state);
            for (uint lobe = 0; (lobe < MDL_DF_HANDLE_SLOT_MODE) && ((offset + lobe) < surface_scatter_bsdf_count);
                 ++lobe)
            {
                result += (eval_data.bsdf_diffuse[lobe] + eval_data.bsdf_glossy[lobe]);
            }
        }
        return result;
    }

    bool sample(const ShadingData sd_ws, inout UniformSampleGenerator sg, out BSDFSample result)
    {
        mdl_velvet_material_ns::Bsdf_sample_data sample_data = {};
        sample_data.ior1 = ior1;          // IOR current medium
        sample_data.ior2 = ior2;          // IOR other side
        sample_data.k1 = sd_ws.view;      // outgoing direction
        sample_data.xi = next_float4(sg); // pseudo-random sample numbers

        mdl_velvet_material_ns::surface_scattering_sample(sample_data, state);

        result = {};
        result.wo_ws = sample_data.k2;
        result.weight = sample_data.bsdf_over_pdf;
        result.pdf = sample_data.pdf;

        if (sample_data.event_type == BSDF_EVENT_DIFFUSE_REFLECTION)
            result.lobe_types = LobeTypes::DiffuseReflection;
        else if (sample_data.event_type == BSDF_EVENT_DIFFUSE_TRANSMISSION)
            result.lobe_types = LobeTypes::DiffuseTransmission;
        else if (sample_data.event_type == BSDF_EVENT_GLOSSY_REFLECTION)
            result.lobe_types = LobeTypes::SpecularReflection;
        else if (sample_data.event_type == BSDF_EVENT_GLOSSY_TRANSMISSION)
            result.lobe_types = LobeTypes::SpecularTransmission;
        else if (sample_data.event_type == BSDF_EVENT_SPECULAR_REFLECTION)
            result.lobe_types = LobeTypes::DeltaReflection;
        else if (sample_data.event_type == BSDF_EVENT_SPECULAR_TRANSMISSION)
            result.lobe_types = LobeTypes::DeltaTransmission;

        return sample_data.event_type != 0;
    }

    float eval_pdf(const ShadingData sd_ws, const float3 wo_ws)
    {
        mdl_velvet_material_ns::Bsdf_pdf_data pdf_data = {};
        pdf_data.ior1 = ior1;     // IOR current medium
        pdf_data.ior2 = ior2;     // IOR other side
        pdf_data.k1 = sd_ws.view; // outgoing direction
        pdf_data.k2 = wo_ws;      // incoming direction

        mdl_velvet_material_ns::surface_scattering_pdf(pdf_data, state);

        return pdf_data.pdf;
    }

    MaterialProperties collect_properties(const ShadingData sd_ws)
    {
        MaterialProperties result = {};

        mdl_velvet_material_ns::Bsdf_auxiliary_data aux = {};
        mdl_velvet_material_ns::surface_scattering_auxiliary(aux, state);

        result.guide_normal = aux.normal[0];
        result.diffuse_reflection_albedo = aux.albedo_diffuse[0];
        result.specular_reflection_albedo = aux.albedo_glossy[0];
        result.roughness = aux.roughness[0].x * 0.5f + aux.roughness[0].y * 0.5f;

        return result;
    }

    LobeTypes get_lobe_types(const ShadingData sd_ws)
    {
        return LobeTypes::All;
    }

    override Optional<ExtraBsdfProperties> collect_extra_bsdf_properties(const ShadingData sd_ws, const float3 wo)
    {
        ExtraBsdfProperties result = {};

        mdl_velvet_material_ns::Bsdf_auxiliary_data aux = {};

        aux.ior1 = ior1;     // IOR current medium
        aux.ior2 = ior2;     // IOR other side
        aux.k1 = sd_ws.view; // outgoing direction

        uint surface_scatter_bsdf_count =
            mdl_velvet_material_ns::MATERIAL_DATA_NAME.surface_scatter_bsdf_count;
        result.bsdf_count =
            surface_scatter_bsdf_count;
        uint offset = 0;
        for (; offset < result.bsdf_count; offset +=
                                           MDL_DF_HANDLE_SLOT_MODE)
        {
            aux.handle_offset = offset;
            mdl_velvet_material_ns::surface_scattering_auxiliary(aux, state);
            for (uint lobe = 0; (lobe < MDL_DF_HANDLE_SLOT_MODE) && ((offset + lobe) < result.bsdf_count); ++lobe)
            {
                float3 N = aux.normal[lobe];
                if (any(isnan(N)) || any(isinf(N)))
                    N = sd_ws.geometric_normal;
                float3 T = mdl_velvet_material_ns::mdl_lambda_tangent(lobe + offset, state);
                float3 B = cross(N, T);

                N = sd_ws.shading_frame.to_local(N);
                T = sd_ws.shading_frame.to_local(T);
                B = sd_ws.shading_frame.to_local(B);

                result.bsdf_N[lobe + offset] = N;
                result.bsdf_T[lobe + offset] = T;
                result.bsdf_B[lobe + offset] = B;
                // MDL Albedo is weight*tint
                result.bsdf_albedo[lobe + offset] = aux.albedo_diffuse[lobe] + aux.albedo_glossy[lobe];
                // MDL doesn't provide pure weight
                result.bsdf_weight[lobe + offset] = mdl_velvet_material_ns::mdl_lambda_tint(lobe + offset, state);
                result.bsdf_roughness[lobe + offset].x = mdl_velvet_material_ns::mdl_lambda_roughness_u(lobe + offset, state);
                result.bsdf_roughness[lobe + offset].y = mdl_velvet_material_ns::mdl_lambda_roughness_v(lobe + offset, state);
            }
        }

        return result;
    }
};
