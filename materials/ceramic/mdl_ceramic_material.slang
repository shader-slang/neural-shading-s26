/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 */

module mdl_ceramic_material;
import materials.materials;
import utracer.utracerutils;

namespace mdl_ceramic_material_ns
{

#define MDL_NUM_TEXTURE_RESULTS 16
#define MDL_DF_HANDLE_SLOT_MODE 4
#define MDL_USE_RENDERER_ADAPT_NORMAL 1
#define MATERIAL_DATA_NAME g_material_data_mdl_ceramic_material

#include "materials/mdl_runtime.slangh"

// user defined structs
struct _ZN4base23texture_coordinate_infoE
{
    float3 m_0;
    float3 m_1;
    float3 m_2;
    int m_3;
};
struct structtype0
{
    float3 m_0;
    float m_1;
    float m_2;
    float m_3;
    float3 m_4;
    float4 m_5;
    _ZN4base23texture_coordinate_infoE m_6;
};
struct _ZN4base11color_layerE
{
    float3 m_0;
    float m_1;
    int m_2;
};
// globals
static const int glob_cnst452[256] = { 151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180 };
static const int glob_cnst455[256] = { 120, 73, 105, 71, 106, 25, 159, 92, 184, 93, 179, 181, 51, 168, 252, 235, 114, 143, 108, 82, 4, 72, 9, 192, 214, 112, 12, 200, 188, 8, 187, 117, 157, 88, 70, 87, 56, 38, 115, 96, 59, 24, 215, 231, 123, 44, 144, 119, 243, 245, 212, 249, 197, 109, 76, 66, 183, 58, 232, 113, 86, 234, 203, 80, 163, 254, 140, 62, 174, 118, 167, 18, 55, 99, 126, 170, 52, 149, 156, 142, 89, 189, 178, 240, 255, 251, 169, 226, 236, 153, 223, 219, 54, 130, 133, 7, 173, 77, 242, 190, 1, 122, 27, 147, 196, 180, 238, 124, 145, 101, 195, 57, 61, 39, 53, 154, 45, 47, 107, 233, 20, 176, 83, 36, 136, 138, 15, 230, 246, 94, 69, 6, 135, 132, 29, 131, 172, 199, 228, 177, 182, 216, 134, 151, 95, 17, 218, 155, 19, 175, 41, 191, 85, 23, 160, 125, 248, 42, 209, 165, 110, 102, 79, 221, 32, 26, 217, 2, 46, 81, 74, 16, 63, 202, 220, 37, 75, 205, 13, 21, 68, 148, 40, 253, 241, 250, 141, 164, 35, 104, 49, 50, 224, 166, 247, 208, 162, 193, 150, 30, 14, 10, 60, 98, 207, 84, 11, 239, 100, 116, 152, 90, 225, 129, 128, 64, 28, 158, 186, 127, 97, 204, 206, 65, 5, 194, 91, 67, 198, 48, 111, 211, 227, 229, 237, 244, 43, 146, 139, 222, 137, 201, 22, 103, 210, 34, 213, 31, 0, 33, 185, 161, 78, 121, 171, 3 };
static const int glob_cnst458[256] = { 88, 147, 251, 140, 206, 77, 107, 169, 5, 222, 84, 97, 116, 234, 24, 90, 201, 133, 40, 216, 229, 34, 37, 158, 186, 49, 98, 61, 47, 9, 124, 123, 65, 249, 2, 66, 76, 172, 198, 179, 218, 210, 78, 170, 132, 32, 60, 110, 213, 223, 151, 225, 115, 83, 180, 161, 42, 41, 164, 250, 233, 70, 231, 27, 217, 244, 114, 96, 183, 228, 63, 195, 236, 192, 177, 209, 246, 109, 171, 72, 101, 23, 35, 112, 182, 162, 57, 69, 146, 81, 248, 215, 7, 154, 178, 252, 136, 55, 150, 8, 1, 142, 167, 199, 39, 3, 14, 135, 152, 74, 33, 243, 121, 13, 181, 26, 211, 19, 64, 168, 58, 67, 52, 143, 113, 43, 25, 240, 166, 59, 4, 187, 53, 238, 103, 159, 220, 204, 208, 245, 85, 122, 62, 120, 93, 191, 224, 16, 68, 80, 226, 207, 134, 188, 73, 232, 102, 125, 196, 254, 253, 130, 241, 46, 119, 38, 94, 221, 153, 100, 163, 175, 242, 131, 255, 214, 87, 139, 92, 12, 203, 117, 219, 21, 239, 6, 31, 20, 44, 50, 28, 111, 141, 18, 157, 145, 11, 30, 237, 82, 129, 200, 89, 148, 95, 194, 144, 128, 176, 45, 79, 106, 235, 75, 0, 230, 160, 126, 138, 227, 247, 91, 17, 173, 29, 51, 71, 22, 36, 118, 149, 189, 155, 156, 197, 54, 202, 99, 174, 137, 105, 184, 205, 108, 10, 193, 165, 127, 56, 212, 104, 190, 185, 48, 86, 15 };
static const int glob_cnst461[256] = { 249, 199, 162, 114, 17, 55, 64, 57, 29, 137, 194, 247, 45, 70, 210, 106, 184, 178, 219, 122, 156, 193, 214, 126, 138, 28, 148, 121, 19, 37, 135, 132, 173, 225, 221, 161, 180, 220, 36, 84, 224, 10, 185, 209, 238, 119, 89, 253, 165, 248, 120, 235, 198, 52, 3, 190, 125, 226, 20, 6, 168, 2, 170, 167, 94, 54, 201, 179, 42, 208, 242, 33, 146, 158, 245, 196, 166, 83, 86, 34, 74, 188, 44, 49, 85, 11, 243, 4, 99, 100, 102, 78, 252, 26, 35, 24, 113, 236, 237, 9, 1, 72, 63, 204, 13, 15, 129, 53, 79, 163, 212, 213, 48, 92, 97, 38, 189, 68, 230, 234, 41, 22, 246, 133, 250, 202, 77, 112, 18, 218, 229, 124, 181, 14, 108, 107, 255, 91, 145, 223, 134, 142, 96, 88, 222, 207, 141, 175, 203, 27, 69, 95, 62, 47, 147, 164, 130, 232, 39, 244, 21, 154, 239, 153, 110, 172, 59, 46, 81, 176, 217, 80, 150, 159, 182, 186, 66, 174, 169, 98, 231, 123, 215, 12, 128, 187, 127, 58, 32, 111, 160, 149, 31, 195, 65, 152, 144, 82, 197, 216, 75, 61, 101, 117, 93, 51, 60, 0, 67, 211, 241, 206, 90, 87, 56, 240, 73, 177, 43, 155, 157, 71, 191, 136, 103, 116, 140, 205, 143, 228, 109, 23, 16, 171, 115, 7, 131, 192, 183, 105, 251, 5, 139, 40, 200, 30, 254, 227, 76, 151, 50, 8, 104, 118, 233, 25 };
// functions
_ZN4base23texture_coordinate_infoE constr__ZN4base23texture_coordinate_infoE(
    float3 m_0,
    float3 m_1,
    float3 m_2,
    int m_3)
{
    _ZN4base23texture_coordinate_infoE res;
    res.m_0 = m_0;
    res.m_1 = m_1;
    res.m_2 = m_2;
    res.m_3 = m_3;
    return res;
}

structtype0 constr_structtype0(
    float3 m_0,
    float m_1,
    float m_2,
    float m_3,
    float3 m_4,
    float4 m_5,
    _ZN4base23texture_coordinate_infoE m_6)
{
    structtype0 res;
    res.m_0 = m_0;
    res.m_1 = m_1;
    res.m_2 = m_2;
    res.m_3 = m_3;
    res.m_4 = m_4;
    res.m_5 = m_5;
    res.m_6 = m_6;
    return res;
}

structtype0 _ZN7Ceramic31Ceramic_Tiles_Glazed_Versailles30Ceramic_Tiles_Glazed_GeneratorEU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2du5coloru5coloru5coloru5colorffiU7uniformffffffffffU7uniformfU7uniformfU7uniformiU7uniformu6float3fffffffU7uniformfU7uniformffU7uniformu6float2U7uniformfU7uniformu6float2U7uniformi(in Shading_state_material state)
{
    _ZN4base11color_layerE tmp[8];
    float3 tmp0;
    float3 tmp1;
    float3 tmp2;
    float3 tmp6;
    float3 tmp8;
    float3 tmp10;
    float2 tmp11;
    float3 tmp13;
    int tmp32;
    int tmp36;
    int tmp40;
    float tmp44;
    float tmp45;
    float tmp46;
    float3 tmp48;
    float3 tmp49;
    float3 tmp50;
    int tmp54;
    int tmp55;
    float tmp56;
    float tmp57;
    float2 tmp58;
    float tmp59;
    float tmp60;
    float3 tmp85;
    float3 tmp86;
    float3 tmp95;
    float3 phi_96;
    float3 phi_98;
    float3 phi_100;
    float3 tmp127;
    float3 tmp128;
    float3 tmp141;
    float tmp144;
    float tmp145;
    float phi_147;
    float tmp149;
    float3 grout_diff_lookup;
    float3 tmp153;
    bool phi_in154;
    bool phi;
    float3 phi_156;
    float3 phi_158;
    float3 tmp159;
    float3 tmp160;
    float3 phi_162;
    float3 tmp163;
    float3 phi_165;
    float3 tmp166;
    float3 phi_168;
    float3 tmp169;
    float3 tmp170;
    float3 tiles_diff;
    float3 phi_177;
    int phi_179;
    float3 phi_182;
    float3 tmp184;
    float tmp185;
    int tmp186;
    float3 tmp187;
    float3 phi_189;
    float3 tmp190;
    float3 tmp191;
    float3 tmp192;
    float3 tmp193;
    float3 phi_195;
    float3 tmp196;
    float3 phi_198;
    float3 tmp199;
    float3 phi_201;
    float3 tmp202;
    float3 tmp203;
    float tmp204;
    float tmp205;
    float3 tmp207;
    float3 tmp209;
    float tmp210;
    float tmp211;
    float3 tmp213;
    float3 tmp215;
    float3 tmp216;
    float3 tmp217;
    float3 tmp218;
    float3 tmp219;
    float3 tmp220;
    float3 tmp222;
    float3 tmp224;
    float tmp225;
    float phi_227;
    float tmp228;
    float tmp229;
    float tmp230;
    float phi_232;
    float tmp233;
    float tmp234;
    float tmp235;
    float phi_237;
    float tmp238;
    float3 tmp239;
    float phi_241;
    float tmp242;
    float3 tmp243;
    float phi_245;
    float tmp246;
    float3 tmp247;
    float phi_249;
    float tmp250;
    float3 tmp251;
    float phi_253;
    float tmp254;
    float3 tmp255;
    float phi_257;
    float tmp258;
    float3 tmp259;
    float phi_261;
    float tmp262;
    float3 tmp263;
    float phi_265;
    float tmp266;
    float3 tmp267;
    float phi_269;
    float tmp270;
    float3 tmp271;
    float phi_273;
    float tmp274;
    float3 tmp275;
    float3 tmp276;
    float3 tmp277;
    float3 tmp278;
    float3 phi_280;
    float3 tmp281;
    float3 phi_283;
    float3 tmp284;
    float3 phi_286;
    float3 tmp287;
    float3 tmp288;
    bool tmp289;
    int index;
    float phi_292;
    float3 tmp293;
    bool tmp294;
    int index195;
    float phi_297;
    float3 tmp298;
    bool tmp299;
    int index200;
    float phi_302;
    float3 tmp303;
    float3 tmp304;
    float3 tmp306;
    float3 tmp308;
    float3 tmp309;
    float3 tmp310;
    float tmp311;
    float tmp313;
    float phi_315;
    float tmp316;
    float phi_318;
    float tmp319;
    float tmp320;
    float tmp321;
    float tmp322;
    float tmp323;
    float phi_325;
    float tmp326;
    float tmp330;
    float tmp332;
    float tmp333;
    int tmp334;
    float3 tmp335;
    float3 tmp336;
    float3 tmp337;
    float3 tmp338;
    float3 tmp339;
    float3 tmp340;
    float tmp341;
    float tmp343;
    float phi_345;
    float tmp346;
    float phi_348;
    float tmp349;
    float tmp350;
    float tmp351;
    float tmp352;
    float tmp353;
    float phi_355;
    float tmp356;
    float tmp360;
    float tmp362;
    float tmp363;
    int tmp364;
    float3 tmp365;
    float3 tmp366;
    float3 tmp367;
    float3 tmp368;
    float3 tmp369;
    float3 tmp370;
    float3 tmp372;
    int tmp373;
    float3 tmp375;
    bool phi_in376;
    bool phi377;
    float3 phi_379;
    float3 phi_381;
    float3 tmp382;
    float3 tmp383;
    bool phi_in384;
    bool phi385;
    float3 phi_387;
    float3 phi_389;
    float3 tmp390;
    float tmp391;
    int index205;
    float3 tmp394;
    float3 tmp398;
    float3 phi400;
    float3 phi_402;
    float3 tmp403;
    float3 phi_405;
    float3 tmp410;
    float4 tmp412;
    int tmp413;
    float4 phi_415;
    float phi_417;
    float3 phi_419;
    float phi_421;
    int phi_423;
    float3 phi_426;
    float phi_428;
    int tmp429;
    float4 tmp603;
    float3 tmp604;
    float tmp605;
    float tmp606;
    tmp0 = state.text_coords[0];
    tmp1 = state.tangent_u[0];
    tmp2 = state.tangent_v[0];
    float tmp3 = tmp0.x * 2.0f;
    float tmp4 = tmp0.y * 2.0f;
    float3 tmp5 = float3(tmp3, tmp4, 0.0f);
    tmp6 = float3(tmp5.x, tmp5.y, tmp0.z);
    float3 tmp7 = float3(sqrt(tmp1.x * tmp1.x + tmp1.y * tmp1.y + tmp1.z * tmp1.z), 0.0f, 0.0f);
    tmp8 = tmp1 / tmp7.xxx;
    float3 tmp9 = float3(sqrt(tmp2.x * tmp2.x + tmp2.y * tmp2.y + tmp2.z * tmp2.z), 0.0f, 0.0f);
    tmp10 = tmp2 / tmp9.xxx;
    tmp11 = tmp5.xy;
    float2 tmp12 = tmp11 * float2(2.0f, 2.0f);
    tmp13 = tex_texel_float3_2d(1, int2(int(frac(tmp12.x) * float(tex_width_2d(1, int2(0, 0), 0.0f))), int(frac(tmp12.y) * float(tex_height_2d(1, int2(0, 0), 0.0f)))), int2(0, 0), 0.0f);
    int tmp14 = int(floor(tmp12.y) - (tmp13.y < 0.5f ? 0.0f : 1.0f));
    int tmp15 = (int(uint(tmp14) >> 16u) ^ tmp14) * 2146121005;
    int tmp16 = (int(uint(tmp15) >> 15u) ^ tmp15) * -2073254261;
    int tmp17 = (int(uint(tmp16) >> 16u) ^ tmp16) + int(floor(tmp12.x) - float(tmp13.y >= 0.25f && tmp13.y < 0.75f));
    int tmp18 = (int(uint(tmp17) >> 16u) ^ tmp17) * 2146121005;
    int tmp19 = (int(uint(tmp18) >> 15u) ^ tmp18) * -2073254261;
    int tmp20 = int(tmp13.x * 254.0f) + 9 + (int(uint(tmp19) >> 16u) ^ tmp19);
    int tmp21 = (int(uint(tmp20) >> 16u) ^ tmp20) * 2146121005;
    int tmp22 = int(uint(tmp21) >> 15u) ^ tmp21;
    int tmp23 = tmp22 * -2073254261;
    int tmp24 = int(uint(tmp23) >> 16u) ^ tmp23;
    int tmp25 = tmp22 * -1674769041;
    int tmp26 = int(uint(tmp25) >> 15u) ^ tmp25;
    int tmp27 = tmp26 * -2073254261;
    int tmp28 = int(uint(tmp27) >> 16u) ^ tmp27;
    int tmp29 = tmp26 * -1674769041;
    int tmp30 = int(uint(tmp29) >> 15u) ^ tmp29;
    int tmp31 = tmp30 * -2073254261;
    tmp32 = int(uint(tmp31) >> 16u) ^ tmp31;
    int tmp33 = tmp30 * -1674769041;
    int tmp34 = int(uint(tmp33) >> 15u) ^ tmp33;
    int tmp35 = tmp34 * -2073254261;
    tmp36 = int(uint(tmp35) >> 16u) ^ tmp35;
    int tmp37 = tmp34 * -1674769041;
    int tmp38 = int(uint(tmp37) >> 15u) ^ tmp37;
    int tmp39 = tmp38 * -2073254261;
    tmp40 = int(uint(tmp39) >> 16u) ^ tmp39;
    int tmp41 = tmp38 * -1674769041;
    int tmp42 = (int(uint(tmp41) >> 15u) ^ tmp41) * -2073254261;
    int tmp43 = int(uint(tmp42) >> 16u) ^ tmp42;
    tmp44 = ((tmp24 < 0 ? 2147483648.0f : 0.0f) + float(tmp24 & 2147483647)) * 2.328306437e-10f;
    tmp45 = ((tmp28 < 0 ? 2147483648.0f : 0.0f) + float(tmp28 & 2147483647)) * 2.328306437e-10f;
    tmp46 = ((tmp43 < 0 ? 2147483648.0f : 0.0f) + float(tmp43 & 2147483647)) * 2.328306437e-10f;
    float2 tmp47 = float2(tmp44, tmp45) * float2(17.77000046f, 17.77000046f);
    tmp48 = float3(tmp47.x + tmp3, tmp47.y + tmp4, 0.0f);
    tmp49 = tex_lookup_float3_2d(4, tmp11, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f);
    tmp50 = tex_lookup_float3_2d(2, tmp48.xy, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f);
    float2 tmp51 = tmp11 * float2(6.666666508f, 6.666666508f);
    float tmp52 = tmp51.x * 0.9999999404f - tmp51.y * 0.5773502588f;
    float tmp53 = tmp51.y * 1.154700518f;
    tmp54 = int(floor(tmp52));
    tmp55 = int(floor(tmp53));
    tmp56 = frac(tmp52);
    tmp57 = frac(tmp53);
    tmp58 = float2(tmp56, tmp57);
    tmp59 = 1.0f - tmp56;
    tmp60 = tmp59 - tmp57;
    if (tmp60 > 0.0f)
    {
        float2 tmp61 = tmp11 * float2(1.111111164f, 1.111111164f);
        int tmp62 = (int(uint(tmp55) >> 16u) ^ tmp55) * 2146121005;
        int tmp63 = (int(uint(tmp62) >> 15u) ^ tmp62) * -2073254261;
        int tmp64 = int(uint(tmp63) >> 16u) ^ tmp63;
        int tmp65 = tmp64 + tmp54;
        int tmp66 = (int(uint(tmp65) >> 16u) ^ tmp65) * 2146121005;
        int tmp67 = (int(uint(tmp66) >> 15u) ^ tmp66) * -2073254261;
        int tmp68 = int(uint(tmp67) >> 16u) ^ tmp67;
        int tmp69 = tmp65 + 9;
        int tmp70 = (int(uint(tmp69) >> 16u) ^ tmp69) * 2146121005;
        int tmp71 = (int(uint(tmp70) >> 15u) ^ tmp70) * -2073254261;
        int tmp72 = int(uint(tmp71) >> 16u) ^ tmp71;
        float3 tmp73 = float3(tmp60, 0.0f, 0.0f);
        int tmp74 = tmp55 + 1;
        int tmp75 = (int(uint(tmp74) >> 16u) ^ tmp74) * 2146121005;
        int tmp76 = (int(uint(tmp75) >> 15u) ^ tmp75) * -2073254261;
        int tmp77 = (int(uint(tmp76) >> 16u) ^ tmp76) + tmp54;
        int tmp78 = (int(uint(tmp77) >> 16u) ^ tmp77) * 2146121005;
        int tmp79 = (int(uint(tmp78) >> 15u) ^ tmp78) * -2073254261;
        int tmp80 = int(uint(tmp79) >> 16u) ^ tmp79;
        int tmp81 = tmp77 + 9;
        int tmp82 = (int(uint(tmp81) >> 16u) ^ tmp81) * 2146121005;
        int tmp83 = (int(uint(tmp82) >> 15u) ^ tmp82) * -2073254261;
        int tmp84 = int(uint(tmp83) >> 16u) ^ tmp83;
        tmp85 = (tex_lookup_float3_2d(3, tmp61 - float2(((tmp80 < 0 ? 2147483648.0f : 0.0f) + float(tmp80 & 2147483647)) * 2.328306437e-10f, ((tmp84 < 0 ? 2147483648.0f : 0.0f) + float(tmp84 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp58.yyy + (tex_lookup_float3_2d(3, tmp61 - float2(((tmp68 < 0 ? 2147483648.0f : 0.0f) + float(tmp68 & 2147483647)) * 2.328306437e-10f, ((tmp72 < 0 ? 2147483648.0f : 0.0f) + float(tmp72 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp73.xxx;
        tmp86 = float3(tmp60, tmp57, tmp56);
        int tmp87 = tmp54 + 1 + tmp64;
        int tmp88 = (int(uint(tmp87) >> 16u) ^ tmp87) * 2146121005;
        int tmp89 = (int(uint(tmp88) >> 15u) ^ tmp88) * -2073254261;
        int tmp90 = int(uint(tmp89) >> 16u) ^ tmp89;
        int tmp91 = tmp87 + 9;
        int tmp92 = (int(uint(tmp91) >> 16u) ^ tmp91) * 2146121005;
        int tmp93 = (int(uint(tmp92) >> 15u) ^ tmp92) * -2073254261;
        int tmp94 = int(uint(tmp93) >> 16u) ^ tmp93;
        tmp95 = (tex_lookup_float3_2d(3, tmp61 - float2(((tmp90 < 0 ? 2147483648.0f : 0.0f) + float(tmp90 & 2147483647)) * 2.328306437e-10f, ((tmp94 < 0 ? 2147483648.0f : 0.0f) + float(tmp94 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp58.xxx;
        phi_96 = tmp95;
        phi_98 = tmp85;
        phi_100 = tmp86;
    }
    else
    {
        float tmp101 = -tmp60;
        float2 tmp102 = tmp11 * float2(1.111111164f, 1.111111164f);
        int2 tmp103 = int2(tmp54, tmp55) + int2(1, 1);
        int tmp104 = (int(uint(tmp103.y) >> 16u) ^ tmp103.y) * 2146121005;
        int tmp105 = (int(uint(tmp104) >> 15u) ^ tmp104) * -2073254261;
        int tmp106 = (int(uint(tmp105) >> 16u) ^ tmp105) + tmp103.x;
        int tmp107 = (int(uint(tmp106) >> 16u) ^ tmp106) * 2146121005;
        int tmp108 = (int(uint(tmp107) >> 15u) ^ tmp107) * -2073254261;
        int tmp109 = int(uint(tmp108) >> 16u) ^ tmp108;
        int tmp110 = tmp106 + 9;
        int tmp111 = (int(uint(tmp110) >> 16u) ^ tmp110) * 2146121005;
        int tmp112 = (int(uint(tmp111) >> 15u) ^ tmp111) * -2073254261;
        int tmp113 = int(uint(tmp112) >> 16u) ^ tmp112;
        float3 tmp114 = float3(tmp101, 0.0f, 0.0f);
        float tmp115 = 1.0f - tmp57;
        int tmp116 = (int(uint(tmp55) >> 16u) ^ tmp55) * 2146121005;
        int tmp117 = (int(uint(tmp116) >> 15u) ^ tmp116) * -2073254261;
        int tmp118 = tmp54 + 1 + (int(uint(tmp117) >> 16u) ^ tmp117);
        int tmp119 = (int(uint(tmp118) >> 16u) ^ tmp118) * 2146121005;
        int tmp120 = (int(uint(tmp119) >> 15u) ^ tmp119) * -2073254261;
        int tmp121 = int(uint(tmp120) >> 16u) ^ tmp120;
        int tmp122 = tmp118 + 9;
        int tmp123 = (int(uint(tmp122) >> 16u) ^ tmp122) * 2146121005;
        int tmp124 = (int(uint(tmp123) >> 15u) ^ tmp123) * -2073254261;
        int tmp125 = int(uint(tmp124) >> 16u) ^ tmp124;
        float3 tmp126 = float3(tmp115, 0.0f, 0.0f);
        tmp127 = (tex_lookup_float3_2d(3, tmp102 - float2(((tmp121 < 0 ? 2147483648.0f : 0.0f) + float(tmp121 & 2147483647)) * 2.328306437e-10f, ((tmp125 < 0 ? 2147483648.0f : 0.0f) + float(tmp125 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp126.xxx + (tex_lookup_float3_2d(3, tmp102 - float2(((tmp109 < 0 ? 2147483648.0f : 0.0f) + float(tmp109 & 2147483647)) * 2.328306437e-10f, ((tmp113 < 0 ? 2147483648.0f : 0.0f) + float(tmp113 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp114.xxx;
        tmp128 = float3(tmp101, tmp115, tmp59);
        int tmp129 = tmp55 + 1;
        int tmp130 = (int(uint(tmp129) >> 16u) ^ tmp129) * 2146121005;
        int tmp131 = (int(uint(tmp130) >> 15u) ^ tmp130) * -2073254261;
        int tmp132 = (int(uint(tmp131) >> 16u) ^ tmp131) + tmp54;
        int tmp133 = (int(uint(tmp132) >> 16u) ^ tmp132) * 2146121005;
        int tmp134 = (int(uint(tmp133) >> 15u) ^ tmp133) * -2073254261;
        int tmp135 = int(uint(tmp134) >> 16u) ^ tmp134;
        int tmp136 = tmp132 + 9;
        int tmp137 = (int(uint(tmp136) >> 16u) ^ tmp136) * 2146121005;
        int tmp138 = (int(uint(tmp137) >> 15u) ^ tmp137) * -2073254261;
        int tmp139 = int(uint(tmp138) >> 16u) ^ tmp138;
        float3 tmp140 = float3(tmp59, 0.0f, 0.0f);
        tmp141 = (tex_lookup_float3_2d(3, tmp102 - float2(((tmp135 < 0 ? 2147483648.0f : 0.0f) + float(tmp135 & 2147483647)) * 2.328306437e-10f, ((tmp139 < 0 ? 2147483648.0f : 0.0f) + float(tmp139 & 2147483647)) * 2.328306437e-10f), 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) + float3(-0.4990000129f, -0.3650000095f, -0.01499999966f)) * tmp140.xxx;
        phi_96 = tmp141;
        phi_98 = tmp127;
        phi_100 = tmp128;
    }
    float3 tmp142 = float3(sqrt(phi_100.x * phi_100.x + phi_100.y * phi_100.y + phi_100.z * phi_100.z), 0.0f, 0.0f);
    float3 tmp143 = (phi_98 + phi_96) / tmp142.xxx + float3(0.4990000129f, 0.0f, 0.01499999966f);
    tmp144 = min(max(tmp143.x, 0.0f), 1.0f);
    tmp145 = min(max(tmp143.z, 0.0f), 1.0f);
    phi_147 = 0.0f;
    if (!(tmp49.x < 0.400000006f))
    {
        phi_147 = 1.0f;
        if (tmp49.x < 0.5f)
        {
            float tmp148 = tmp49.x * 10.00000095f + -4.000000477f;
            tmp149 = tmp148 * tmp148 * (3.0f - tmp148 * 2.0f);
            phi_147 = tmp149;
        }
    }
    bool tmp150 = phi_147 < 0.9990000129f;
    grout_diff_lookup = float3(0.5f, 1.5f, 0.5f);
    if (tmp150)
    {
        float4 tmp152 = tex_lookup_float4_2d(6, tmp11, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f);
        tmp153 = tmp152.xyz;
        phi_in154 = true;
        phi_156 = tmp153;
        do
        {
            phi = phi_in154;
            phi_158 = phi_156;
            if (phi)
            {
                tmp159 = phi_156 * float3(0.6999999881f, 0.6999999881f, 0.6999999881f);
                tmp160 = phi_156 + float3(0.6999999881f, 0.6999999881f, 0.6999999881f);
                phi_162 = tmp159;
                if (!(phi_156.x < 0.5f))
                {
                    tmp163 = float3(-0.5f - tmp159.x + tmp160.x, tmp159.y, tmp159.z);
                    phi_162 = tmp163;
                }
                phi_165 = phi_162;
                if (!(phi_156.y < 0.5f))
                {
                    tmp166 = float3(phi_162.x, tmp160.y + -0.5f - phi_162.y, phi_162.z);
                    phi_165 = tmp166;
                }
                phi_168 = phi_165;
                if (!(phi_156.z < 0.5f))
                {
                    tmp169 = float3(phi_165.x, phi_165.y, tmp160.z + -0.5f - phi_165.z);
                    phi_168 = tmp169;
                }
                tmp170 = phi_168 * float3(2.0f, 2.0f, 2.0f);
                phi_in154 = false;
                phi_156 = tmp170;
            }
            else
                break;
        } while (true);
        grout_diff_lookup = phi_158;
    }
    bool tmp171 = phi_147 < 0.001000000047f;
    tiles_diff = float3(1.0f, 0.0f, 0.0f);
    if (!tmp171)
    {
        float tmp173 = 1.0f - tmp13.z;
        float3 tmp174 = float3(tmp46, 0.0f, 0.0f);
        float3 tmp175 = float3(pow(tmp50.z, 2.200000048f), 0.0f, 0.0f);
        tmp[0].m_0 = float3(0.03688900173f, 0.03560100123f, 0.02315299958f);
        tmp[0].m_1 = tmp13.z;
        tmp[0].m_2 = 0;
        tmp[1].m_0 = float3(0.4880000055f, 0.4309999943f, 0.04780000076f);
        tmp[1].m_1 = tmp50.x * tmp173;
        tmp[1].m_2 = 0;
        tmp[2].m_0 = float3(0.003347000107f, 0.03434000164f, 0.00303500006f);
        tmp[2].m_1 = tmp50.y * tmp173;
        tmp[2].m_2 = 0;
        tmp[3].m_0 = float3(0.0f, 0.0f, 0.0f);
        tmp[3].m_1 = tmp13.z * 0.200000003f * tmp50.y;
        tmp[3].m_2 = 4;
        tmp[4].m_0 = tmp174.xxx;
        tmp[4].m_1 = 0.6299999952f;
        tmp[4].m_2 = 4;
        tmp[5].m_0 = float3(1.0f, 1.0f, 1.0f);
        tmp[5].m_1 = 0.0f;
        tmp[5].m_2 = 0;
        tmp[6].m_0 = float3(1.0f, 1.0f, 1.0f);
        tmp[6].m_1 = tmp49.y * 0.2899999917f;
        tmp[6].m_2 = 0;
        tmp[7].m_0 = tmp175.xxx;
        tmp[7].m_1 = 0.0f;
        tmp[7].m_2 = 4;
        phi_177 = float3(0.01228599995f, 0.3613069952f, 0.1301359981f);
        phi_179 = 0;
        do
        {
            bool tmp180 = uint(phi_179) < 8u;
            phi_182 = phi_177;
            if (tmp180)
            {
                int tmp183 = phi_179;
                tmp184 = tmp[tmp183].m_0;
                tmp185 = tmp[tmp183].m_1;
                tmp186 = tmp[tmp183].m_2;
                if (tmp186 == 1)
                {
                    tmp187 = tmp184 + phi_177;
                    phi_189 = tmp187;
                }
                else if (tmp186 == 2)
                {
                    tmp190 = tmp184 * phi_177;
                    phi_189 = tmp190;
                }
                else if (tmp186 == 3)
                {
                    tmp191 = tmp184 + phi_177 - tmp184 * phi_177;
                    phi_189 = tmp191;
                }
                else if (tmp186 == 4)
                {
                    tmp192 = tmp184 * phi_177;
                    tmp193 = tmp184 + phi_177;
                    phi_195 = tmp192;
                    if (!(phi_177.x < 0.5f))
                    {
                        tmp196 = float3(-0.5f - tmp192.x + tmp193.x, tmp192.y, tmp192.z);
                        phi_195 = tmp196;
                    }
                    phi_198 = phi_195;
                    if (!(phi_177.y < 0.5f))
                    {
                        tmp199 = float3(phi_195.x, tmp193.y + -0.5f - phi_195.y, phi_195.z);
                        phi_198 = tmp199;
                    }
                    phi_201 = phi_198;
                    if (!(phi_177.z < 0.5f))
                    {
                        tmp202 = float3(phi_198.x, phi_198.y, tmp193.z + -0.5f - phi_198.z);
                        phi_201 = tmp202;
                    }
                    tmp203 = phi_201 * float3(2.0f, 2.0f, 2.0f);
                    phi_189 = tmp203;
                }
                else if (tmp186 == 5)
                {
                    tmp204 = max(max(tmp184.x, tmp184.y), tmp184.z);
                    tmp205 = max(max(phi_177.x, phi_177.y), phi_177.z);
                    if (tmp205 == 0.0f)
                    {
                        float3 tmp206 = float3(tmp204, 0.0f, 0.0f);
                        tmp207 = tmp206.xxx;
                        phi_189 = tmp207;
                    }
                    else
                    {
                        float3 tmp208 = float3(tmp204 / tmp205, 0.0f, 0.0f);
                        tmp209 = tmp208.xxx * phi_177;
                        phi_189 = tmp209;
                    }
                }
                else if (tmp186 == 6)
                {
                    tmp210 = max(max(tmp184.x, tmp184.y), tmp184.z);
                    tmp211 = max(max(phi_177.x, phi_177.y), phi_177.z);
                    if (tmp210 == 0.0f)
                    {
                        float3 tmp212 = float3(tmp211, 0.0f, 0.0f);
                        tmp213 = tmp212.xxx;
                        phi_189 = tmp213;
                    }
                    else
                    {
                        float3 tmp214 = float3(tmp211 / tmp210, 0.0f, 0.0f);
                        tmp215 = tmp214.xxx * tmp184;
                        phi_189 = tmp215;
                    }
                }
                else if (tmp186 == 7)
                {
                    tmp216 = tmp184 + phi_177 + tmp184 * phi_177 * float3(-2.0f, -2.0f, -2.0f);
                    phi_189 = tmp216;
                }
                else if (tmp186 == 8)
                {
                    tmp217 = (tmp184 + phi_177) * float3(0.5f, 0.5f, 0.5f);
                    phi_189 = tmp217;
                }
                else if (tmp186 == 9)
                {
                    tmp218 = float3(max(tmp184.x, phi_177.x), max(tmp184.y, phi_177.y), max(tmp184.z, phi_177.z));
                    phi_189 = tmp218;
                }
                else if (tmp186 == 10)
                {
                    tmp219 = float3(min(tmp184.x, phi_177.x), min(tmp184.y, phi_177.y), min(tmp184.z, phi_177.z));
                    phi_189 = tmp219;
                }
                else if (tmp186 == 11)
                {
                    tmp220 = tmp184 + phi_177 + float3(-1.0f, -1.0f, -1.0f);
                    phi_189 = tmp220;
                }
                else if (tmp186 == 12)
                {
                    float3 tmp221 = float3(1.0f, 1.0f, 1.0f) - (phi_177 + tmp184);
                    tmp222 = float3(1.0f, 1.0f, 1.0f) - float3(abs(tmp221.x), abs(tmp221.y), abs(tmp221.z));
                    phi_189 = tmp222;
                }
                else if (tmp186 == 13)
                {
                    float3 tmp223 = tmp184 - phi_177;
                    tmp224 = float3(abs(tmp223.x), abs(tmp223.y), abs(tmp223.z));
                    phi_189 = tmp224;
                }
                else if (tmp186 == 14)
                {
                    if (tmp184.x < 0.5f)
                    {
                        tmp225 = ((0.5f - tmp184.x) * phi_177.x + tmp184.x) * phi_177.x;
                        phi_227 = tmp225;
                    }
                    else
                    {
                        tmp228 = phi_177.x - tmp184.x * phi_177.x + (tmp184.x + -0.5f) * sqrt(phi_177.x);
                        phi_227 = tmp228;
                    }
                    tmp229 = phi_227 * 2.0f;
                    if (tmp184.y < 0.5f)
                    {
                        tmp230 = ((0.5f - tmp184.y) * phi_177.y + tmp184.y) * phi_177.y;
                        phi_232 = tmp230;
                    }
                    else
                    {
                        tmp233 = phi_177.y - tmp184.y * phi_177.y + (tmp184.y + -0.5f) * sqrt(phi_177.y);
                        phi_232 = tmp233;
                    }
                    tmp234 = phi_232 * 2.0f;
                    if (tmp184.z < 0.5f)
                    {
                        tmp235 = ((0.5f - tmp184.z) * phi_177.z + tmp184.z) * phi_177.z;
                        phi_237 = tmp235;
                    }
                    else
                    {
                        tmp238 = phi_177.z - tmp184.z * phi_177.z + (tmp184.z + -0.5f) * sqrt(phi_177.z);
                        phi_237 = tmp238;
                    }
                    tmp239 = float3(tmp229, tmp234, phi_237 * 2.0f);
                    phi_189 = tmp239;
                }
                else if (tmp186 == 15)
                {
                    phi_241 = 1.0f;
                    if (!(tmp184.x == 1.0f))
                    {
                        tmp242 = min(phi_177.x / (1.0f - tmp184.x), 1.0f);
                        phi_241 = tmp242;
                    }
                    tmp243 = float3(phi_241, 0.0f, 0.0f);
                    phi_245 = 1.0f;
                    if (!(tmp184.y == 1.0f))
                    {
                        tmp246 = min(phi_177.y / (1.0f - tmp184.y), 1.0f);
                        phi_245 = tmp246;
                    }
                    tmp247 = float3(tmp243.x, phi_245, tmp243.z);
                    phi_249 = 1.0f;
                    if (!(tmp184.z == 1.0f))
                    {
                        tmp250 = min(phi_177.z / (1.0f - tmp184.z), 1.0f);
                        phi_249 = tmp250;
                    }
                    tmp251 = float3(tmp247.x, tmp247.y, phi_249);
                    phi_189 = tmp251;
                }
                else if (tmp186 == 16)
                {
                    phi_253 = 1.0f;
                    if (!(tmp184.x == 1.0f))
                    {
                        tmp254 = min(phi_177.x * phi_177.x / (1.0f - tmp184.x), 1.0f);
                        phi_253 = tmp254;
                    }
                    tmp255 = float3(phi_253, 0.0f, 0.0f);
                    phi_257 = 1.0f;
                    if (!(tmp184.y == 1.0f))
                    {
                        tmp258 = min(phi_177.y * phi_177.y / (1.0f - tmp184.y), 1.0f);
                        phi_257 = tmp258;
                    }
                    tmp259 = float3(tmp255.x, phi_257, tmp255.z);
                    phi_261 = 1.0f;
                    if (!(tmp184.z == 1.0f))
                    {
                        tmp262 = min(phi_177.z * phi_177.z / (1.0f - tmp184.z), 1.0f);
                        phi_261 = tmp262;
                    }
                    tmp263 = float3(tmp259.x, tmp259.y, phi_261);
                    phi_189 = tmp263;
                }
                else if (tmp186 == 17)
                {
                    phi_265 = 0.0f;
                    if (!(tmp184.x == 0.0f))
                    {
                        tmp266 = max(1.0f - (1.0f - phi_177.x) / tmp184.x, 0.0f);
                        phi_265 = tmp266;
                    }
                    tmp267 = float3(phi_265, 0.0f, 0.0f);
                    phi_269 = 0.0f;
                    if (!(tmp184.y == 0.0f))
                    {
                        tmp270 = max(1.0f - (1.0f - phi_177.y) / tmp184.y, 0.0f);
                        phi_269 = tmp270;
                    }
                    tmp271 = float3(tmp267.x, phi_269, tmp267.z);
                    phi_273 = 0.0f;
                    if (!(tmp184.z == 0.0f))
                    {
                        tmp274 = max(1.0f - (1.0f - phi_177.z) / tmp184.z, 0.0f);
                        phi_273 = tmp274;
                    }
                    tmp275 = float3(tmp271.x, tmp271.y, phi_273);
                    phi_189 = tmp275;
                }
                else if (tmp186 == 18)
                {
                    tmp276 = float3(1.0f, 1.0f, 1.0f) - float3(max(tmp184.x, phi_177.x), max(tmp184.y, phi_177.y), max(tmp184.z, phi_177.z)) + float3(min(tmp184.x, phi_177.x), min(tmp184.y, phi_177.y), min(tmp184.z, phi_177.z));
                    phi_189 = tmp276;
                }
                else if (tmp186 == 19)
                {
                    tmp277 = tmp184 * phi_177;
                    tmp278 = tmp184 + phi_177;
                    phi_280 = tmp277;
                    if (tmp184.x > 0.5f)
                    {
                        tmp281 = float3(-0.5f - tmp277.x + tmp278.x, tmp277.y, tmp277.z);
                        phi_280 = tmp281;
                    }
                    phi_283 = phi_280;
                    if (tmp184.y > 0.5f)
                    {
                        tmp284 = float3(phi_280.x, tmp278.y + -0.5f - phi_280.y, phi_280.z);
                        phi_283 = tmp284;
                    }
                    phi_286 = phi_283;
                    if (tmp184.z > 0.5f)
                    {
                        tmp287 = float3(phi_283.x, phi_283.y, tmp278.z + -0.5f - phi_283.z);
                        phi_286 = tmp287;
                    }
                    tmp288 = phi_286 * float3(2.0f, 2.0f, 2.0f);
                    phi_189 = tmp288;
                }
                else if (tmp186 == 20)
                {
                    tmp289 = tmp184.x > phi_177.x;
                    if (tmp184.x > 0.5f)
                    {
                        index = 0;
                        if (!tmp289)
                            index = 1;
                    }
                    else
                    {
                        index = 0;
                        if (tmp289)
                            index = 1;
                    }
                    bool indexCmp = index == 0;
                    phi_292 = tmp184.x;
                    if (!indexCmp)
                        phi_292 = phi_177.x;
                    tmp293 = float3(phi_292, 0.0f, 0.0f);
                    tmp294 = tmp184.y > phi_177.y;
                    if (tmp184.y > 0.5f)
                    {
                        index195 = 0;
                        if (!tmp294)
                            index195 = 1;
                    }
                    else
                    {
                        index195 = 0;
                        if (tmp294)
                            index195 = 1;
                    }
                    bool indexCmp198 = index195 == 0;
                    phi_297 = tmp184.y;
                    if (!indexCmp198)
                        phi_297 = phi_177.y;
                    tmp298 = float3(tmp293.x, phi_297, tmp293.z);
                    tmp299 = tmp184.z > phi_177.z;
                    if (tmp184.z > 0.5f)
                    {
                        index200 = 0;
                        if (!tmp299)
                            index200 = 1;
                    }
                    else
                    {
                        index200 = 0;
                        if (tmp299)
                            index200 = 1;
                    }
                    bool indexCmp203 = index200 == 0;
                    phi_302 = tmp184.z;
                    if (!indexCmp203)
                        phi_302 = phi_177.z;
                    tmp303 = float3(tmp298.x, tmp298.y, phi_302);
                    phi_189 = tmp303;
                }
                else if (tmp186 == 21)
                {
                    tmp304 = float3(tmp184.x + phi_177.x > 1.0f ? 1.0f : 0.0f, tmp184.y + phi_177.y > 1.0f ? 1.0f : 0.0f, tmp184.z + phi_177.z > 1.0f ? 1.0f : 0.0f);
                    phi_189 = tmp304;
                }
                else if (tmp186 == 22)
                {
                    float3 tmp305 = tmp184 + phi_177;
                    tmp306 = float3(min(tmp305.x, 1.0f), min(tmp305.y, 1.0f), min(tmp305.z, 1.0f));
                    phi_189 = tmp306;
                }
                else if (tmp186 == 23)
                {
                    float3 tmp307 = tmp184 + phi_177 + float3(-1.0f, -1.0f, -1.0f);
                    tmp308 = float3(max(tmp307.x, 0.0f), max(tmp307.y, 0.0f), max(tmp307.z, 0.0f));
                    phi_189 = tmp308;
                }
                else if (tmp186 == 24)
                {
                    tmp309 = tmp184 * phi_177 * float3(2.0f, 2.0f, 2.0f);
                    phi_189 = tmp309;
                }
                else if (tmp186 == 25)
                {
                    tmp310 = tmp184 * phi_177 + phi_177;
                    phi_189 = tmp310;
                }
                else if (tmp186 == 26)
                {
                    tmp311 = max(max(tmp184.x, tmp184.y), tmp184.z);
                    float tmp312 = tmp311 - min(min(tmp184.x, tmp184.y), tmp184.z);
                    tmp313 = 1.0f / tmp312;
                    phi_315 = 0.0f;
                    if (tmp312 != 0.0f)
                    {
                        if (tmp311 == tmp184.x)
                        {
                            tmp316 = tmp313 * (tmp184.y - tmp184.z);
                            phi_318 = tmp316;
                        }
                        else if (tmp311 == tmp184.y)
                        {
                            tmp319 = tmp313 * (tmp184.z - tmp184.x) + 2.0f;
                            phi_318 = tmp319;
                        }
                        else
                        {
                            tmp320 = tmp313 * (tmp184.x - tmp184.y) + 4.0f;
                            phi_318 = tmp320;
                        }
                        tmp321 = phi_318 * 0.1666666716f;
                        phi_315 = tmp321;
                    }
                    tmp322 = phi_315 < 0.0f ? phi_315 + 1.0f : phi_315;
                    tmp323 = max(max(phi_177.x, phi_177.y), phi_177.z);
                    phi_325 = 0.0f;
                    if (tmp323 != 0.0f)
                    {
                        tmp326 = 1.0f - min(min(phi_177.x, phi_177.y), phi_177.z) / tmp323;
                        phi_325 = tmp326;
                    }
                    float tmp327 = tmp322 != 1.0f ? tmp322 * 6.0f : 0.0f;
                    float tmp328 = floor(tmp327);
                    float tmp329 = phi_325 * tmp323;
                    tmp330 = tmp323 - tmp329;
                    float tmp331 = (tmp327 - tmp328) * tmp329;
                    tmp332 = tmp323 - tmp331;
                    tmp333 = tmp331 + tmp330;
                    tmp334 = int(tmp328);
                    if (tmp334 == 5)
                    {
                        tmp335 = float3(tmp323, tmp330, tmp332);
                        phi_189 = tmp335;
                    }
                    else if (tmp334 == 1)
                    {
                        tmp336 = float3(tmp332, tmp323, tmp330);
                        phi_189 = tmp336;
                    }
                    else if (tmp334 == 2)
                    {
                        tmp337 = float3(tmp330, tmp323, tmp333);
                        phi_189 = tmp337;
                    }
                    else if (tmp334 == 3)
                    {
                        tmp338 = float3(tmp330, tmp332, tmp323);
                        phi_189 = tmp338;
                    }
                    else if (tmp334 == 4)
                    {
                        tmp339 = float3(tmp333, tmp330, tmp323);
                        phi_189 = tmp339;
                    }
                    else
                    {
                        tmp340 = float3(tmp323, tmp333, tmp330);
                        phi_189 = tmp340;
                    }
                }
                else if (tmp186 == 27)
                {
                    tmp341 = max(max(phi_177.x, phi_177.y), phi_177.z);
                    float tmp342 = tmp341 - min(min(phi_177.x, phi_177.y), phi_177.z);
                    tmp343 = 1.0f / tmp342;
                    phi_345 = 0.0f;
                    if (tmp342 != 0.0f)
                    {
                        if (tmp341 == phi_177.x)
                        {
                            tmp346 = tmp343 * (phi_177.y - phi_177.z);
                            phi_348 = tmp346;
                        }
                        else if (tmp341 == phi_177.y)
                        {
                            tmp349 = tmp343 * (phi_177.z - phi_177.x) + 2.0f;
                            phi_348 = tmp349;
                        }
                        else
                        {
                            tmp350 = tmp343 * (phi_177.x - phi_177.y) + 4.0f;
                            phi_348 = tmp350;
                        }
                        tmp351 = phi_348 * 0.1666666716f;
                        phi_345 = tmp351;
                    }
                    tmp352 = phi_345 < 0.0f ? phi_345 + 1.0f : phi_345;
                    tmp353 = max(max(tmp184.x, tmp184.y), tmp184.z);
                    phi_355 = 0.0f;
                    if (tmp353 != 0.0f)
                    {
                        tmp356 = 1.0f - min(min(tmp184.x, tmp184.y), tmp184.z) / tmp353;
                        phi_355 = tmp356;
                    }
                    float tmp357 = tmp352 != 1.0f ? tmp352 * 6.0f : 0.0f;
                    float tmp358 = floor(tmp357);
                    float tmp359 = phi_355 * tmp341;
                    tmp360 = tmp341 - tmp359;
                    float tmp361 = (tmp357 - tmp358) * tmp359;
                    tmp362 = tmp341 - tmp361;
                    tmp363 = tmp361 + tmp360;
                    tmp364 = int(tmp358);
                    if (tmp364 == 5)
                    {
                        tmp365 = float3(tmp341, tmp360, tmp362);
                        phi_189 = tmp365;
                    }
                    else if (tmp364 == 1)
                    {
                        tmp366 = float3(tmp362, tmp341, tmp360);
                        phi_189 = tmp366;
                    }
                    else if (tmp364 == 2)
                    {
                        tmp367 = float3(tmp360, tmp341, tmp363);
                        phi_189 = tmp367;
                    }
                    else if (tmp364 == 3)
                    {
                        tmp368 = float3(tmp360, tmp362, tmp341);
                        phi_189 = tmp368;
                    }
                    else if (tmp364 == 4)
                    {
                        tmp369 = float3(tmp363, tmp360, tmp341);
                        phi_189 = tmp369;
                    }
                    else
                    {
                        tmp370 = float3(tmp341, tmp363, tmp360);
                        phi_189 = tmp370;
                    }
                }
                else
                    phi_189 = tmp184;
                float3 tmp371 = float3(tmp185, 0.0f, 0.0f);
                tmp372 = (phi_189 - phi_177) * tmp371.xxx + phi_177;
                tmp373 = phi_179 + 1;
                phi_177 = tmp372;
                phi_179 = tmp373;
            }
            else
                break;
        } while (true);
        tiles_diff = phi_182;
    }
    float3 tmp374 = float3(phi_147, 0.0f, 0.0f);
    tmp375 = tmp374.xxx;
    phi_in376 = true;
    phi_379 = grout_diff_lookup;
    do
    {
        phi377 = phi_in376;
        phi_381 = phi_379;
        if (phi377)
        {
            tmp382 = (tiles_diff - phi_379) * tmp375 + phi_379;
            phi_in376 = false;
            phi_379 = tmp382;
        }
        else
            break;
    } while (true);
    tmp383 = tmp49.zzz;
    phi_in384 = true;
    phi_387 = phi_381;
    do
    {
        phi385 = phi_in384;
        phi_389 = phi_387;
        if (phi385)
        {
            tmp390 = (phi_387 * tmp383 - phi_387) * float3(0.3000000119f, 0.3000000119f, 0.3000000119f) + phi_387;
            phi_in384 = false;
            phi_387 = tmp390;
        }
        else
            break;
    } while (true);
    tmp391 = phi_147 * (tmp145 * 0.6000000238f + -0.8000000119f + tmp144 * 0.200000003f) + 0.8000000119f;
    index205 = 1;
    if (tex_width_2d(5, int2(0, 0), 0.0f) != 0)
    {
        index205 = 1;
        if (tex_height_2d(5, int2(0, 0), 0.0f) != 0)
        {
            float3 tmp393 = tex_lookup_float3_2d(5, tmp11, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) * float3(2.0f, 2.0f, 2.0f) + float3(-1.0f, -1.0f, -1.0f);
            tmp394 = state.normal;
            float3 tmp395 = float3(abs(tmp393.z), 0.0f, 0.0f);
            float3 tmp396 = tmp393.xxx * tmp8 + tmp393.yyy * tmp10 + tmp395.xxx * tmp394;
            float3 tmp397 = float3(sqrt(tmp396.x * tmp396.x + tmp396.y * tmp396.y + tmp396.z * tmp396.z), 0.0f, 0.0f);
            tmp398 = tmp396 / tmp397.xxx;
            index205 = 0;
        }
    }
    bool indexCmp206 = index205 == 0;
    phi400 = tmp394;
    phi_402 = tmp398;
    if (!indexCmp206)
    {
        tmp403 = state.normal;
        phi400 = tmp403;
        phi_402 = tmp403;
    }
    phi_405 = phi400;
    if (tex_width_2d(7, int2(0, 0), 0.0f) != 0)
    {
        phi_405 = phi400;
        if (tex_height_2d(7, int2(0, 0), 0.0f) != 0)
        {
            float3 tmp406 = tex_lookup_float3_2d(7, tmp11, 1, 1, float2(0.0f, 1.0f), float2(0.0f, 1.0f), 0.0f) * float3(2.0f, 2.0f, 2.0f) + float3(-1.0f, -1.0f, -1.0f);
            float3 tmp407 = float3(abs(tmp406.z), 0.0f, 0.0f);
            float3 tmp408 = tmp406.xxx * tmp8 + tmp406.yyy * tmp10 + tmp407.xxx * phi400;
            float3 tmp409 = float3(sqrt(tmp408.x * tmp408.x + tmp408.y * tmp408.y + tmp408.z * tmp408.z), 0.0f, 0.0f);
            tmp410 = tmp408 / tmp409.xxx;
            phi_405 = tmp410;
        }
    }
    float3 tmp411 = tmp6 * float3(20.0f, 20.0f, 20.0f);
    tmp412 = float4(tmp411.xyzx.x, tmp411.xyzx.y, tmp411.xyzx.z, 0.0f);
    tmp413 = state.ro_data_segment_offset;
    phi_415 = tmp412;
    phi_417 = 1.0f;
    phi_419 = float3(0.0f, 0.0f, 0.0f);
    phi_421 = 0.0f;
    phi_423 = 4;
    do
    {
        bool tmp424 = phi_423 == 0;
        phi_426 = phi_419;
        phi_428 = phi_421;
        if (tmp424)
            break;
        else
        {
            tmp429 = phi_423 + -1;
            float tmp430 = floor(phi_415.x);
            int tmp431 = int(tmp430);
            float tmp432 = floor(phi_415.y);
            int tmp433 = int(tmp432);
            float tmp434 = floor(phi_415.z);
            int tmp435 = int(tmp434);
            float tmp436 = floor(phi_415.w);
            int tmp437 = int(tmp436);
            float tmp438 = phi_415.x - tmp430;
            float tmp439 = phi_415.y - tmp432;
            float tmp440 = phi_415.z - tmp434;
            float tmp441 = phi_415.w - tmp436;
            float tmp442 = tmp438 * tmp438;
            float tmp443 = tmp442 * tmp438 * ((tmp438 * 6.0f + -15.0f) * tmp438 + 10.0f);
            float tmp444 = tmp439 * tmp439;
            float tmp445 = tmp444 * tmp439 * ((tmp439 * 6.0f + -15.0f) * tmp439 + 10.0f);
            float tmp446 = tmp440 * tmp440;
            float tmp447 = tmp446 * tmp440 * ((tmp440 * 6.0f + -15.0f) * tmp440 + 10.0f);
            float tmp448 = tmp441 * tmp441 * tmp441 * ((tmp441 * 6.0f + -15.0f) * tmp441 + 10.0f);
            float tmp449 = ((tmp438 * 30.0f + -60.0f) * tmp438 + 30.0f) * tmp442;
            float tmp450 = ((tmp439 * 30.0f + -60.0f) * tmp439 + 30.0f) * tmp444;
            int tmp451 = (glob_cnst452[tmp431 & 255]) & 127;
            int tmp453 = (glob_cnst452[(tmp431 + 1) & 255]) & 127;
            int tmp454 = (glob_cnst455[tmp433 & 255]) & 127;
            int tmp456 = (glob_cnst455[(tmp433 + 1) & 255]) & 127;
            int tmp457 = (glob_cnst458[tmp435 & 255]) & 127;
            int tmp459 = (glob_cnst458[(tmp435 + 1) & 255]) & 127;
            int tmp460 = (glob_cnst461[tmp437 & 255]) & 127;
            int tmp462 = (glob_cnst461[(tmp437 + 1) & 255]) & 127;
            int tmp463 = tmp454 ^ tmp451;
            int tmp464 = tmp457 ^ tmp463;
            int tmp465 = ((tmp460 ^ tmp464) << 4) + tmp413;
            float tmp466 = mdl_read_rodata_as_float(tmp465);
            float tmp467 = mdl_read_rodata_as_float(tmp465 + 4);
            float tmp468 = mdl_read_rodata_as_float(tmp465 + 8);
            float4 tmp469 = float4(tmp466, tmp467, tmp468, tmp467 * tmp439 + tmp466 * tmp438 + tmp468 * tmp440 + mdl_read_rodata_as_float(tmp465 + 12) * tmp441);
            int tmp470 = tmp454 ^ tmp453;
            int tmp471 = tmp457 ^ tmp470;
            int tmp472 = ((tmp460 ^ tmp471) << 4) + tmp413;
            float tmp473 = mdl_read_rodata_as_float(tmp472);
            float tmp474 = mdl_read_rodata_as_float(tmp472 + 4);
            float tmp475 = mdl_read_rodata_as_float(tmp472 + 8);
            float4 tmp476 = float4(tmp473, tmp474, tmp475, tmp473 * tmp438 - tmp473 + tmp474 * tmp439 + tmp475 * tmp440 + mdl_read_rodata_as_float(tmp472 + 12) * tmp441);
            int tmp477 = tmp456 ^ tmp451;
            int tmp478 = tmp477 ^ tmp457;
            int tmp479 = ((tmp460 ^ tmp478) << 4) + tmp413;
            float tmp480 = mdl_read_rodata_as_float(tmp479);
            float tmp481 = mdl_read_rodata_as_float(tmp479 + 4);
            float tmp482 = mdl_read_rodata_as_float(tmp479 + 8);
            float4 tmp483 = float4(tmp480, tmp481, tmp482, tmp480 * tmp438 - tmp481 + tmp481 * tmp439 + tmp482 * tmp440 + mdl_read_rodata_as_float(tmp479 + 12) * tmp441);
            int tmp484 = tmp456 ^ tmp453;
            int tmp485 = tmp484 ^ tmp457;
            int tmp486 = ((tmp460 ^ tmp485) << 4) + tmp413;
            float tmp487 = mdl_read_rodata_as_float(tmp486);
            float tmp488 = mdl_read_rodata_as_float(tmp486 + 4);
            float tmp489 = mdl_read_rodata_as_float(tmp486 + 8);
            float4 tmp490 = float4(tmp487, tmp488, tmp489, tmp487 * tmp438 - (tmp487 + tmp488) + tmp488 * tmp439 + tmp489 * tmp440 + mdl_read_rodata_as_float(tmp486 + 12) * tmp441);
            int tmp491 = tmp459 ^ tmp463;
            int tmp492 = ((tmp491 ^ tmp460) << 4) + tmp413;
            float tmp493 = mdl_read_rodata_as_float(tmp492);
            float tmp494 = mdl_read_rodata_as_float(tmp492 + 4);
            float tmp495 = mdl_read_rodata_as_float(tmp492 + 8);
            float4 tmp496 = float4(tmp493, tmp494, tmp495, tmp494 * tmp439 + tmp493 * tmp438 - tmp495 + tmp495 * tmp440 + mdl_read_rodata_as_float(tmp492 + 12) * tmp441);
            int tmp497 = tmp459 ^ tmp470;
            int tmp498 = ((tmp497 ^ tmp460) << 4) + tmp413;
            float tmp499 = mdl_read_rodata_as_float(tmp498);
            float tmp500 = mdl_read_rodata_as_float(tmp498 + 4);
            float tmp501 = mdl_read_rodata_as_float(tmp498 + 8);
            float4 tmp502 = float4(tmp499, tmp500, tmp501, tmp499 * tmp438 + tmp500 * tmp439 - (tmp499 + tmp501) + tmp501 * tmp440 + mdl_read_rodata_as_float(tmp498 + 12) * tmp441);
            int tmp503 = tmp459 ^ tmp477;
            int tmp504 = ((tmp503 ^ tmp460) << 4) + tmp413;
            float tmp505 = mdl_read_rodata_as_float(tmp504);
            float tmp506 = mdl_read_rodata_as_float(tmp504 + 4);
            float tmp507 = mdl_read_rodata_as_float(tmp504 + 8);
            float4 tmp508 = float4(tmp505, tmp506, tmp507, tmp505 * tmp438 + tmp506 * tmp439 - (tmp506 + tmp507) + tmp507 * tmp440 + mdl_read_rodata_as_float(tmp504 + 12) * tmp441);
            int tmp509 = tmp459 ^ tmp484;
            int tmp510 = ((tmp509 ^ tmp460) << 4) + tmp413;
            float tmp511 = mdl_read_rodata_as_float(tmp510);
            float tmp512 = mdl_read_rodata_as_float(tmp510 + 4);
            float tmp513 = mdl_read_rodata_as_float(tmp510 + 8);
            float4 tmp514 = float4(tmp511, tmp512, tmp513, tmp511 * tmp438 + tmp512 * tmp439 - (tmp511 + tmp512 + tmp513) + tmp513 * tmp440 + mdl_read_rodata_as_float(tmp510 + 12) * tmp441);
            int tmp515 = ((tmp462 ^ tmp464) << 4) + tmp413;
            float tmp516 = mdl_read_rodata_as_float(tmp515);
            float tmp517 = mdl_read_rodata_as_float(tmp515 + 4);
            float tmp518 = mdl_read_rodata_as_float(tmp515 + 8);
            float tmp519 = mdl_read_rodata_as_float(tmp515 + 12);
            float4 tmp520 = float4(tmp516, tmp517, tmp518, tmp517 * tmp439 + tmp516 * tmp438 + tmp518 * tmp440 - tmp519 + tmp519 * tmp441);
            int tmp521 = ((tmp462 ^ tmp471) << 4) + tmp413;
            float tmp522 = mdl_read_rodata_as_float(tmp521);
            float tmp523 = mdl_read_rodata_as_float(tmp521 + 4);
            float tmp524 = mdl_read_rodata_as_float(tmp521 + 8);
            float tmp525 = mdl_read_rodata_as_float(tmp521 + 12);
            float4 tmp526 = float4(tmp522, tmp523, tmp524, tmp522 * tmp438 - tmp522 + tmp523 * tmp439 + tmp524 * tmp440 - tmp525 + tmp525 * tmp441);
            int tmp527 = ((tmp462 ^ tmp478) << 4) + tmp413;
            float tmp528 = mdl_read_rodata_as_float(tmp527);
            float tmp529 = mdl_read_rodata_as_float(tmp527 + 4);
            float tmp530 = mdl_read_rodata_as_float(tmp527 + 8);
            float tmp531 = mdl_read_rodata_as_float(tmp527 + 12);
            float4 tmp532 = float4(tmp528, tmp529, tmp530, tmp528 * tmp438 - tmp529 + tmp529 * tmp439 + tmp530 * tmp440 - tmp531 + tmp531 * tmp441);
            int tmp533 = ((tmp462 ^ tmp485) << 4) + tmp413;
            float tmp534 = mdl_read_rodata_as_float(tmp533);
            float tmp535 = mdl_read_rodata_as_float(tmp533 + 4);
            float tmp536 = mdl_read_rodata_as_float(tmp533 + 8);
            float tmp537 = mdl_read_rodata_as_float(tmp533 + 12);
            float4 tmp538 = float4(tmp534, tmp535, tmp536, tmp534 * tmp438 - (tmp534 + tmp535) + tmp535 * tmp439 + tmp536 * tmp440 - tmp537 + tmp537 * tmp441);
            float4 tmp539 = tmp476 - tmp469;
            float4 tmp540 = tmp483 - tmp469;
            float4 tmp541 = float4(tmp443, 0.0f, 0.0f, 0.0f);
            float4 tmp542 = float4(tmp445, 0.0f, 0.0f, 0.0f);
            float4 tmp543 = tmp539 * tmp541.xxxx + tmp469 + tmp540 * tmp542.xxxx;
            float4 tmp544 = tmp490 - (tmp539 + tmp483);
            float4 tmp545 = tmp496 - tmp469;
            float4 tmp546 = tmp520 - tmp469;
            float4 tmp547 = tmp508 - (tmp483 + tmp545);
            float4 tmp548 = tmp532 - tmp483;
            float4 tmp549 = tmp548 - tmp546;
            float4 tmp550 = tmp502 - tmp476;
            float4 tmp551 = tmp550 - tmp545;
            float4 tmp552 = tmp526 - (tmp476 + tmp546);
            int tmp553 = ((tmp462 ^ tmp491) << 4) + tmp413;
            float tmp554 = mdl_read_rodata_as_float(tmp553);
            float tmp555 = mdl_read_rodata_as_float(tmp553 + 4);
            float tmp556 = mdl_read_rodata_as_float(tmp553 + 8);
            float tmp557 = mdl_read_rodata_as_float(tmp553 + 12);
            float4 tmp558 = float4(tmp554, tmp555, tmp556, tmp555 * tmp439 + tmp554 * tmp438 + tmp556 * tmp440 - (tmp556 + tmp557) + tmp557 * tmp441);
            float4 tmp559 = tmp558 - tmp520;
            float4 tmp560 = tmp559 - tmp545;
            float4 tmp561 = tmp514 - (tmp547 + (tmp490 + tmp550));
            float4 tmp562 = tmp520 - (tmp544 + tmp526 + tmp532) + tmp538;
            int tmp563 = ((tmp462 ^ tmp503) << 4) + tmp413;
            float tmp564 = mdl_read_rodata_as_float(tmp563);
            float tmp565 = mdl_read_rodata_as_float(tmp563 + 4);
            float tmp566 = mdl_read_rodata_as_float(tmp563 + 8);
            float tmp567 = mdl_read_rodata_as_float(tmp563 + 12);
            float4 tmp568 = float4(tmp564, tmp565, tmp566, tmp564 * tmp438 + tmp565 * tmp439 + tmp566 * tmp440 - (tmp565 + tmp566 + tmp567) + tmp567 * tmp441) - tmp558;
            float4 tmp569 = tmp520 - (tmp547 + tmp532) + tmp568;
            int tmp570 = ((tmp462 ^ tmp497) << 4) + tmp413;
            float tmp571 = mdl_read_rodata_as_float(tmp570);
            float tmp572 = mdl_read_rodata_as_float(tmp570 + 4);
            float tmp573 = mdl_read_rodata_as_float(tmp570 + 8);
            float tmp574 = mdl_read_rodata_as_float(tmp570 + 12);
            float4 tmp575 = float4(tmp571, tmp572, tmp573, tmp571 * tmp438 + tmp572 * tmp439 + tmp573 * tmp440 - (tmp571 + tmp573 + tmp574) + tmp574 * tmp441);
            float4 tmp576 = tmp575 - (tmp559 + (tmp551 + tmp526));
            int tmp577 = ((tmp462 ^ tmp509) << 4) + tmp413;
            float tmp578 = mdl_read_rodata_as_float(tmp577);
            float tmp579 = mdl_read_rodata_as_float(tmp577 + 4);
            float tmp580 = mdl_read_rodata_as_float(tmp577 + 8);
            float tmp581 = mdl_read_rodata_as_float(tmp577 + 12);
            float4 tmp582 = tmp490 + tmp502 - (tmp496 + tmp508 + tmp514) + tmp552 + tmp548 - (tmp538 + tmp568 + tmp575) + float4(tmp578, tmp579, tmp580, tmp578 * tmp438 + tmp579 * tmp439 + tmp580 * tmp440 - (tmp578 + tmp579 + tmp580 + tmp581) + tmp581 * tmp441);
            float tmp583 = tmp445 * tmp443;
            float4 tmp584 = float4(tmp583, 0.0f, 0.0f, 0.0f);
            float tmp585 = tmp447 * tmp445;
            float4 tmp586 = float4(tmp585, 0.0f, 0.0f, 0.0f);
            float4 tmp587 = float4(tmp447, 0.0f, 0.0f, 0.0f);
            float4 tmp588 = float4(tmp448, 0.0f, 0.0f, 0.0f);
            float4 tmp589 = float4(tmp448 * tmp445, 0.0f, 0.0f, 0.0f);
            float4 tmp590 = float4(tmp447 * tmp443, 0.0f, 0.0f, 0.0f);
            float4 tmp591 = float4(tmp448 * tmp443, 0.0f, 0.0f, 0.0f);
            float tmp592 = tmp448 * tmp447;
            float4 tmp593 = float4(tmp592, 0.0f, 0.0f, 0.0f);
            float tmp594 = tmp583 * tmp447;
            float4 tmp595 = float4(tmp594, 0.0f, 0.0f, 0.0f);
            float4 tmp596 = float4(tmp448 * tmp583, 0.0f, 0.0f, 0.0f);
            float4 tmp597 = float4(tmp585 * tmp448, 0.0f, 0.0f, 0.0f);
            float4 tmp598 = float4(tmp592 * tmp443, 0.0f, 0.0f, 0.0f);
            float4 tmp599 = float4(tmp594 * tmp448, 0.0f, 0.0f, 0.0f);
            float4 tmp600 = float4(tmp543.x + tmp539.w * tmp449, tmp543.y + tmp540.w * tmp450, tmp543.z, tmp543.w) + tmp544 * tmp584.xxxx + tmp545 * tmp587.xxxx + tmp551 * tmp590.xxxx + tmp547 * tmp586.xxxx + tmp561 * tmp595.xxxx + tmp546 * tmp588.xxxx + tmp552 * tmp591.xxxx + tmp549 * tmp589.xxxx + tmp562 * tmp596.xxxx + tmp560 * tmp593.xxxx + tmp569 * tmp597.xxxx + tmp576 * tmp598.xxxx + tmp582 * tmp599.xxxx;
            float tmp601 = tmp582.w * tmp443 + tmp569.w;
            float tmp602 = tmp561.w * tmp443 + tmp547.w;
            tmp603 = phi_415 * float4(2.0f, 2.0f, 2.0f, 2.0f);
            tmp604 = float3(((tmp561.w * tmp445 + tmp551.w) * tmp447 + tmp544.w * tmp445 + (tmp562.w * tmp445 + tmp552.w + tmp576.w * tmp447 + tmp582.w * tmp585) * tmp448) * tmp449 + tmp600.x, (tmp602 * tmp447 + tmp544.w * tmp443 + (tmp562.w * tmp443 + tmp549.w + tmp601 * tmp447) * tmp448) * tmp450 + tmp600.y, ((tmp440 * 30.0f + -60.0f) * tmp440 + 30.0f) * tmp446 * (tmp551.w * tmp443 + tmp545.w + tmp602 * tmp445 + (tmp576.w * tmp443 + tmp560.w + tmp601 * tmp445) * tmp448) + tmp600.z) + phi_419;
            tmp605 = tmp600.w * phi_417 + phi_421;
            tmp606 = phi_417 * 0.5f;
            phi_415 = tmp603;
            phi_417 = tmp606;
            phi_419 = tmp604;
            phi_421 = tmp605;
            phi_423 = tmp429;
        }
    } while (true);
    float3 tmp607 = phi_426 * float3(0.5f, 0.5f, 0.0f);
    float tmp608 = phi_428 * 0.5f;
    float tmp609 = tmp608 + 0.5f;
    float3 tmp610 = tmp609 < 0.0f || tmp609 > 1.0f ? float3(0.0f, 0.0f, 0.0f) : tmp607;
    float3 tmp611 = float3(tmp610.x * -0.001800000085f, 0.0f, 0.0f);
    float3 tmp612 = float3(tmp610.y * -0.001800000085f, 0.0f, 0.0f);
    float3 tmp613 = tmp612.xxx * tmp10 + phi400;
    float3 tmp614 = tmp613 + tmp611.xxx * tmp8;
    float3 tmp615 = float3(sqrt(tmp614.x * tmp614.x + tmp614.y * tmp614.y + tmp614.z * tmp614.z), 0.0f, 0.0f);
    float3 tmp616 = tmp614 / tmp615.xxx;
    float3 tmp617 = float3(((tmp40 < 0 ? 2147483648.0f : 0.0f) + float(tmp40 & 2147483647)) * 2.328306437e-10f + -0.5f, 0.0f, 0.0f);
    float3 tmp618 = float3(tmp46 + -0.5f, 0.0f, 0.0f);
    float3 tmp619 = phi400 * float3(1.978999972f, 1.978999972f, 1.978999972f);
    float3 tmp620 = tmp619 + (tmp618.xxx * tmp2 + tmp617.xxx * tmp1) * float3(0.02100000158f, 0.02100000158f, 0.02100000158f);
    float3 tmp621 = float3(sqrt(tmp620.x * tmp620.x + tmp620.y * tmp620.y + tmp620.z * tmp620.z), 0.0f, 0.0f);
    float3 tmp622 = tmp620 / tmp621.xxx;
    float3 tmp623 = float3(tmp1.x, tmp2.x, tmp1.x);
    float3 tmp624 = float3(tmp623.x, tmp623.y, phi400.x);
    float3 tmp625 = float3(tmp1.y, tmp2.y, tmp1.y);
    float3 tmp626 = float3(tmp625.x, tmp625.y, phi400.y);
    float3 tmp627 = float3(tmp1.z, tmp2.z, tmp1.z);
    float3 tmp628 = float3(tmp627.x, tmp627.y, phi400.z);
    float3 tmp629 = phi_402.xxx;
    float3 tmp630 = phi_402.yyy;
    float3 tmp631 = phi_402.zzz;
    float3 tmp632 = tmp622.yyy * tmp626 + float3(0.0f, 0.0f, 1.0f) + tmp622.xxx * tmp624 + tmp622.zzz * tmp628;
    float3 tmp633 = (tmp624 * tmp629 + tmp626 * tmp630 + tmp628 * tmp631) * float3(-1.0f, -1.0f, 1.0f);
    float3 tmp634 = tmp632 * tmp633;
    float3 tmp635 = float3(tmp634.x + tmp634.y + tmp634.z, 0.0f, 0.0f);
    float3 tmp636 = tmp635.xxx * tmp632 / tmp632.zzz - tmp633 + float3(0.0f, 0.0f, 1.0f);
    float3 tmp637 = (tmp616.xxx * tmp624 + tmp616.yyy * tmp626 + tmp616.zzz * tmp628) * float3(-1.0f, -1.0f, 1.0f);
    float3 tmp638 = tmp637 * tmp636;
    float3 tmp639 = float3(tmp638.x + tmp638.y + tmp638.z, 0.0f, 0.0f);
    float3 tmp640 = tmp639.xxx * tmp636 / tmp636.zzz - tmp637;
    float3 tmp641 = tmp640.zzz * phi400;
    float3 tmp642 = tmp640.yyy * tmp2 + tmp640.xxx * tmp1 + tmp641;
    float3 tmp643 = float3(sqrt(tmp642.x * tmp642.x + tmp642.y * tmp642.y + tmp642.z * tmp642.z), 0.0f, 0.0f);
    return constr_structtype0(phi_389, tmp144, 0.200000003f, tmp391 * tmp391, (tmp642 / tmp643.xxx - phi_405) * tmp375 + phi_405, float4(tmp44, tmp45, ((tmp32 < 0 ? 2147483648.0f : 0.0f) + float(tmp32 & 2147483647)) * 2.328306437e-10f, ((tmp36 < 0 ? 2147483648.0f : 0.0f) + float(tmp36 & 2147483647)) * 2.328306437e-10f), constr__ZN4base23texture_coordinate_infoE(float3(tmp48.x, tmp48.y, tmp0.z), tmp8, tmp10, 0));
}

void init(inout Shading_state_material state)
{
    state.normal = mdl_adapt_normal(state, _ZN7Ceramic31Ceramic_Tiles_Glazed_Versailles30Ceramic_Tiles_Glazed_GeneratorEU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2du5coloru5coloru5coloru5colorffiU7uniformffffffffffU7uniformfU7uniformfU7uniformiU7uniformu6float3fffffffU7uniformfU7uniformffU7uniformu6float2U7uniformfU7uniformu6float2U7uniformi(state).m_4);
    structtype0 tmp0 = _ZN7Ceramic31Ceramic_Tiles_Glazed_Versailles30Ceramic_Tiles_Glazed_GeneratorEU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2dU7uniformu10texture_2du5coloru5coloru5coloru5colorffiU7uniformffffffffffU7uniformfU7uniformfU7uniformiU7uniformu6float3fffffffU7uniformfU7uniformffU7uniformu6float2U7uniformfU7uniformu6float2U7uniformi(state);
    float3 newret = tmp0.m_0;
    float3 newret7 = tmp0.m_4;
    float4 newret9 = tmp0.m_5;
    _ZN4base23texture_coordinate_infoE newret11 = tmp0.m_6;
    state.text_results[0].x = newret.x;
    state.text_results[0].y = newret.y;
    state.text_results[0].z = newret.z;
    state.text_results[1].x = tmp0.m_1;
    state.text_results[1].y = tmp0.m_2;
    state.text_results[1].z = tmp0.m_3;
    state.text_results[1].w = newret7.x;
    state.text_results[2].x = newret7.y;
    state.text_results[2].y = newret7.z;
    state.text_results[2].w = newret9.x;
    state.text_results[3].x = newret9.y;
    state.text_results[3].y = newret9.z;
    state.text_results[3].z = newret9.w;
    float3 tmp1 = newret11.m_0;
    state.text_results[3].w = tmp1.x;
    state.text_results[4].x = tmp1.y;
    state.text_results[4].y = tmp1.z;
    float3 tmp2 = newret11.m_1;
    state.text_results[4].w = tmp2.x;
    state.text_results[5].x = tmp2.y;
    state.text_results[5].y = tmp2.z;
    float3 tmp3 = newret11.m_2;
    state.text_results[5].w = tmp3.x;
    state.text_results[6].x = tmp3.y;
    state.text_results[6].y = tmp3.z;
    state.text_results[6].w = asfloat(newret11.m_3);
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

void gen_fresnel_layer_pdf(inout Bsdf_pdf_data p_00, in Shading_state_material p_11, in float3 p_22)
{
    float tmp4;
    float phi;
    float tmp5;
    float phi7;
    bool phi_in9;
    bool phi10;
    bool tmp11;
    float phi13;
    float tmp14;
    float phi16;
    float tmp17;
    float tmp19;
    float3 tmp20;
    float tmp21;
    float tmp22;
    float tmp23;
    float3 tmp24;
    float tmp26;
    float3 tmp27;
    float tmp29;
    float tmp30;
    float tmp31;
    float phi33;
    float tmp39;
    float phi42;
    float tmp44;
    float tmp45;
    float tmp46;
    float tmp47;
    float3 tmp48;
    float3 tmp49;
    float3 tmp50;
    float tmp52;
    float phi54;
    float3 tmp56;
    float3 tmp57;
    float tmp60;
    float tmp61;
    float tmp62;
    float tmp63;
    float3 tmp64;
    float3 tmp70;
    float tmp72;
    float tmp85;
    float tmp86;
    float phi89;
    float3 tmp90;
    float3 tmp91;
    float phi94;
    float tmp98;
    float tmp99;
    float3 tmp3 = mdl_adapt_normal(p_11, p_11.normal);
    tmp4 = p_00.ior1.x;
    phi = tmp4;
    if (tmp4 == -1.0f)
    {
        p_00.ior1.x = 1.0f;
        p_00.ior1.y = 1.0f;
        p_00.ior1.z = 1.0f;
        phi = 1.0f;
    }
    tmp5 = p_00.ior2.x;
    phi7 = tmp5;
    if (tmp5 == -1.0f)
    {
        p_00.ior2.x = 1.0f;
        p_00.ior2.y = 1.0f;
        p_00.ior2.z = 1.0f;
        phi7 = 1.0f;
    }
    bool tmp8 = phi7 == 1.0f;
    phi_in9 = false;
    if (tmp8)
    {
        phi_in9 = false;
        if (p_00.ior2.y == 1.0f)
        {
            tmp11 = p_00.ior2.z == 1.0f;
            phi_in9 = tmp11;
        }
    }
    phi10 = phi_in9;
    phi13 = 1.5f;
    if (phi10)
    {
        tmp14 = (p_00.ior1.y + phi + p_00.ior1.z) * 0.3333333433f;
        phi13 = tmp14;
    }
    phi16 = 1.5f;
    if (!phi10)
    {
        tmp17 = (p_00.ior2.y + phi7 + p_00.ior2.z) * 0.3333333433f;
        phi16 = tmp17;
    }
    float tmp18 = phi16 - phi13;
    tmp19 = (abs(tmp18) < 9.999999747e-05f ? phi13 + asfloat((asint(tmp18) & -2147483648) | 953267991) : phi16) / phi13;
    tmp20 = p_11.geom_normal;
    tmp21 = p_00.k1.x;
    tmp22 = p_00.k1.y;
    tmp23 = p_00.k1.z;
    tmp24 = float3(tmp21, tmp22, tmp23);
    float3 tmp25 = tmp24 * tmp20;
    tmp26 = asfloat((asint(tmp25.x + tmp25.y + tmp25.z) & -2147483648) | 1065353216);
    tmp27 = float3(tmp3.x * tmp26, tmp3.y * tmp26, tmp3.z * tmp26);
    float3 tmp28 = tmp27 * tmp24;
    tmp29 = tmp28.x + tmp28.y + tmp28.z;
    tmp30 = min(max(tmp29, 0.0f), 1.0f);
    tmp31 = 1.0f - (1.0f - tmp30 * tmp30) / (tmp19 * tmp19);
    phi33 = 1.0f;
    if (!(tmp31 < 0.0f))
    {
        float tmp34 = sqrt(tmp31);
        float tmp35 = tmp30 * tmp19;
        float tmp36 = tmp34 * tmp19;
        float tmp37 = (tmp34 - tmp35) / (tmp34 + tmp35);
        float tmp38 = (tmp30 - tmp36) / (tmp36 + tmp30);
        tmp39 = min(max((tmp38 * tmp38 + tmp37 * tmp37) * 0.5f, 0.0f), 1.0f);
        phi33 = tmp39;
    }
    bool tmp40 = phi33 > 0.0f;
    phi42 = 0.0f;
    if (tmp40)
    {
        float3 tmp43 = p_11.tangent_u[0];
        tmp44 = max(max(p_11.text_results[1].z, mdl_read_argblock_as_float(p_11.arg_block_offset)), 1.000000012e-07f);
        tmp45 = tmp20.x * tmp26;
        tmp46 = tmp20.y * tmp26;
        tmp47 = tmp20.z * tmp26;
        tmp48 = tmp27.zxy;
        tmp49 = tmp27.yzx;
        tmp50 = tmp48 * tmp43.yzx - tmp49 * tmp43.zxy;
        float3 tmp51 = tmp50 * tmp50;
        tmp52 = tmp51.x + tmp51.y + tmp51.z;
        phi54 = 0.0f;
        if (!(tmp52 < 9.999999939e-09f))
        {
            float tmp55 = 1.0f / sqrt(tmp52);
            tmp56 = float3(tmp55 * tmp50.x, tmp55 * tmp50.y, tmp55 * tmp50.z);
            tmp57 = tmp56.zxy * tmp49 - tmp56.yzx * tmp48;
            bool tmp58 = phi == -1.0f;
            if (tmp58)
            {
                p_00.ior1.x = 1.0f;
                p_00.ior1.y = 1.0f;
                p_00.ior1.z = 1.0f;
            }
            bool tmp59 = phi7 == -1.0f;
            if (tmp59)
            {
                p_00.ior2.x = 1.0f;
                p_00.ior2.y = 1.0f;
                p_00.ior2.z = 1.0f;
            }
            tmp60 = abs(tmp29);
            tmp61 = p_00.k2.x;
            tmp62 = p_00.k2.y;
            tmp63 = p_00.k2.z;
            tmp64 = float3(tmp61, tmp62, tmp63);
            float3 tmp65 = tmp64 * float3(tmp45, tmp46, tmp47);
            phi54 = 0.0f;
            if (!(tmp65.x + tmp65.y + tmp65.z < 0.0f))
            {
                float tmp66 = tmp61 + tmp21;
                float tmp67 = tmp62 + tmp22;
                float tmp68 = tmp63 + tmp23;
                float3 tmp69 = float3(sqrt(tmp67 * tmp67 + tmp66 * tmp66 + tmp68 * tmp68), 0.0f, 0.0f);
                tmp70 = float3(tmp66, tmp67, tmp68) / tmp69.xxx;
                float3 tmp71 = tmp70 * tmp27;
                tmp72 = tmp71.x + tmp71.y + tmp71.z;
                float3 tmp73 = tmp70 * tmp24;
                float3 tmp74 = tmp70 * tmp64;
                phi54 = 0.0f;
                if (!(tmp74.x + tmp74.y + tmp74.z < 0.0f || (tmp72 < 0.0f || tmp73.x + tmp73.y + tmp73.z < 0.0f)))
                {
                    float3 tmp75 = tmp70 * tmp57;
                    float3 tmp76 = tmp70 * tmp56;
                    float tmp77 = 1.0f / tmp44;
                    float tmp78 = (tmp75.x + tmp75.y + tmp75.z) * tmp77;
                    float tmp79 = (tmp76.x + tmp76.y + tmp76.z) * tmp77;
                    float tmp80 = tmp78 * tmp78 + tmp72 * tmp72 + tmp79 * tmp79;
                    float3 tmp81 = tmp57 * tmp24;
                    float3 tmp82 = tmp56 * tmp24;
                    float tmp83 = (tmp81.x + tmp81.y + tmp81.z) * tmp44;
                    float tmp84 = (tmp82.x + tmp82.y + tmp82.z) * tmp44;
                    tmp85 = tmp77 * tmp77 * 0.1591549367f * tmp72 / (tmp80 * tmp80 * ((sqrt((tmp83 * tmp83 + tmp84 * tmp84) / (tmp29 * tmp29) + 1.0f) + 1.0f) * tmp60 * tmp72));
                    phi54 = tmp85;
                }
            }
        }
        tmp86 = phi54 * phi33;
        phi42 = tmp86;
    }
    bool tmp87 = phi33 < 1.0f;
    phi89 = phi42;
    if (tmp87)
    {
        tmp90 = p_00.k2;
        tmp91 = float3(tmp20.x * tmp26, tmp20.y * tmp26, tmp20.z * tmp26);
        float3 tmp92 = tmp91 * tmp90;
        phi94 = 0.0f;
        if (tmp92.x + tmp92.y + tmp92.z > 0.0f)
        {
            float3 tmp95 = float3(p_22.x * tmp26, p_22.y * tmp26, p_22.z * tmp26);
            float3 tmp96 = tmp95 * tmp91;
            float3 tmp97 = tmp95 * tmp90;
            tmp98 = max(tmp97.x + tmp97.y + tmp97.z, 0.0f) / (max(tmp96.x + tmp96.y + tmp96.z, 0.0f) * 1.570796371f + 1.570796371f);
            phi94 = tmp98;
        }
        tmp99 = phi94 * (1.0f - phi33) + phi42;
        phi89 = tmp99;
    }
    p_00.pdf = phi89;
    return;
}

void surface_scattering_sample(inout Bsdf_sample_data sret_ptr, in Shading_state_material state)
{
    Bsdf_pdf_data pdf_data;
    float3 normal_buf;
    float tmp2;
    float phi;
    float tmp3;
    float phi5;
    bool phi_in7;
    bool phi8;
    bool tmp9;
    float phi11;
    float tmp12;
    float phi14;
    float tmp15;
    float tmp17;
    float3 tmp18;
    float tmp19;
    float tmp20;
    float tmp21;
    float3 tmp22;
    float tmp24;
    float tmp25;
    float tmp26;
    float tmp27;
    float3 tmp28;
    float tmp30;
    float tmp31;
    float tmp32;
    float tmp33;
    bool tmp34;
    float phi36;
    float tmp42;
    float tmp43;
    bool tmp44;
    bool tmp45;
    bool phi_in46;
    bool phi47;
    bool phi_in48;
    bool phi49;
    bool phi_in50;
    bool phi51;
    float phi53;
    float tmp55;
    float tmp56;
    float tmp58;
    float tmp59;
    float tmp60;
    float tmp61;
    float3 tmp62;
    float3 tmp63;
    float3 tmp64;
    float tmp66;
    int index;
    float newPhi;
    float newPhi74;
    float newPhi75;
    float newPhi76;
    float newPhi77;
    float newPhi78;
    float newPhi79;
    float newPhi80;
    float newPhi81;
    float newPhi82;
    float newPhi83;
    float tmp80;
    float tmp81;
    float tmp82;
    float3 tmp83;
    float3 tmp84;
    float phi_87;
    float phi_90;
    float tmp93;
    float tmp94;
    float tmp97;
    float tmp98;
    float3 tmp100;
    float phi102;
    float phi104;
    float phi106;
    float tmp114;
    float tmp115;
    float tmp116;
    float tmp117;
    float phi119;
    float phi121;
    float tmp122;
    float tmp136;
    float tmp137;
    float tmp138;
    float tmp140;
    float tmp142;
    float tmp143;
    float tmp144;
    float3 tmp145;
    float tmp148;
    float tmp153;
    float tmp155;
    float tmp156;
    float tmp157;
    float3 tmp158;
    float3 tmp159;
    float3 tmp160;
    float3 tmp161;
    float tmp163;
    float tmp165;
    float tmp166;
    float tmp167;
    float tmp170;
    float tmp171;
    float tmp172;
    float3 tmp173;
    float tmp175;
    float tmp176;
    float tmp177;
    float tmp178;
    bool tmp179;
    float tmp180;
    float phi182;
    float tmp183;
    float tmp184;
    float3 phi187;
    float tmp190;
    float tmp191;
    float tmp192;
    float tmp193;
    float tmp194;
    float phi196;
    float phi198;
    float phi200;
    float tmp201;
    float tmp202;
    float3 tmp203;
    float tmp204;
    float tmp205;
    float tmp206;
    float phi_208;
    float phi_210;
    float phi_212;
    float phi214;
    float phi216;
    float phi218;
    float phi224;
    float phi226;
    float tmp227;
    float tmp228;
    float tmp229;
    float3 tmp234;
    float tmp237;
    float phi_239;
    float phi_241;
    float tmp242;
    float tmp248;
    float tmp249;
    float phi251;
    float tmp257;
    float tmp258;
    float phi260;
    float tmp266;
    float tmp267;
    float phi269;
    float phi271;
    float tmp272;
    float phi274;
    float tmp280;
    float tmp281;
    float3 tmp0 = state.normal;
    normal_buf.x = tmp0.x;
    normal_buf.y = tmp0.y;
    normal_buf.z = tmp0.z;
    float3 tmp1 = mdl_adapt_normal(state, tmp0);
    tmp2 = sret_ptr.ior1.x;
    phi = tmp2;
    if (tmp2 == -1.0f)
    {
        sret_ptr.ior1.x = 1.0f;
        sret_ptr.ior1.y = 1.0f;
        sret_ptr.ior1.z = 1.0f;
        phi = 1.0f;
    }
    tmp3 = sret_ptr.ior2.x;
    phi5 = tmp3;
    if (tmp3 == -1.0f)
    {
        sret_ptr.ior2.x = 1.0f;
        sret_ptr.ior2.y = 1.0f;
        sret_ptr.ior2.z = 1.0f;
        phi5 = 1.0f;
    }
    bool tmp6 = phi5 == 1.0f;
    phi_in7 = false;
    if (tmp6)
    {
        phi_in7 = false;
        if (sret_ptr.ior2.y == 1.0f)
        {
            tmp9 = sret_ptr.ior2.z == 1.0f;
            phi_in7 = tmp9;
        }
    }
    phi8 = phi_in7;
    phi11 = 1.5f;
    if (phi8)
    {
        tmp12 = (sret_ptr.ior1.y + phi + sret_ptr.ior1.z) * 0.3333333433f;
        phi11 = tmp12;
    }
    phi14 = 1.5f;
    if (!phi8)
    {
        tmp15 = (sret_ptr.ior2.y + phi5 + sret_ptr.ior2.z) * 0.3333333433f;
        phi14 = tmp15;
    }
    float tmp16 = phi14 - phi11;
    tmp17 = (abs(tmp16) < 9.999999747e-05f ? phi11 + asfloat((asint(tmp16) & -2147483648) | 953267991) : phi14) / phi11;
    tmp18 = state.geom_normal;
    tmp19 = sret_ptr.k1.x;
    tmp20 = sret_ptr.k1.y;
    tmp21 = sret_ptr.k1.z;
    tmp22 = float3(tmp19, tmp20, tmp21);
    float3 tmp23 = tmp22 * tmp18;
    tmp24 = asfloat((asint(tmp23.x + tmp23.y + tmp23.z) & -2147483648) | 1065353216);
    tmp25 = tmp1.x * tmp24;
    tmp26 = tmp1.y * tmp24;
    tmp27 = tmp1.z * tmp24;
    tmp28 = float3(tmp25, tmp26, tmp27);
    float3 tmp29 = tmp28 * tmp22;
    tmp30 = tmp29.x + tmp29.y + tmp29.z;
    tmp31 = min(max(tmp30, 0.0f), 1.0f);
    tmp32 = tmp17 * tmp17;
    tmp33 = 1.0f - (1.0f - tmp31 * tmp31) / tmp32;
    tmp34 = tmp33 < 0.0f;
    phi36 = 1.0f;
    if (!tmp34)
    {
        float tmp37 = sqrt(tmp33);
        float tmp38 = tmp31 * tmp17;
        float tmp39 = tmp37 * tmp17;
        float tmp40 = (tmp37 - tmp38) / (tmp37 + tmp38);
        float tmp41 = (tmp31 - tmp39) / (tmp39 + tmp31);
        tmp42 = min(max((tmp41 * tmp41 + tmp40 * tmp40) * 0.5f, 0.0f), 1.0f);
        phi36 = tmp42;
    }
    tmp43 = sret_ptr.xi.z;
    tmp44 = phi36 > 0.0f;
    tmp45 = phi36 < 1.0f;
    phi_in46 = false;
    phi_in48 = true;
    phi_in50 = false;
    phi53 = 0.0f;
    if (tmp44 || tmp45)
    {
        bool tmp54 = tmp43 < phi36;
        if (tmp44 && (tmp54 || tmp45 != true))
        {
            tmp55 = 1.0f / phi36;
            phi_in46 = true;
            phi_in48 = false;
            phi_in50 = true;
            phi53 = 1.0f;
            if (tmp45)
            {
                sret_ptr.xi.z = tmp43 * tmp55;
                phi_in46 = true;
                phi_in48 = false;
                phi_in50 = true;
                phi53 = tmp55;
            }
        }
        else
        {
            phi_in46 = false;
            phi_in48 = true;
            phi_in50 = false;
            phi53 = 0.0f;
            if (tmp45)
            {
                phi_in46 = false;
                phi_in48 = true;
                phi_in50 = true;
                phi53 = 1.0f;
                if (tmp44)
                {
                    tmp56 = 1.0f / (1.0f - phi36);
                    sret_ptr.xi.z = min(max((tmp43 - phi36) * tmp56, 0.0f), 0.9999999404f);
                    phi_in46 = false;
                    phi_in48 = true;
                    phi_in50 = true;
                    phi53 = tmp56;
                }
            }
        }
    }
    phi47 = phi_in46;
    phi49 = phi_in48;
    phi51 = phi_in50;
    if (phi51)
    {
        if (phi47)
        {
            float3 tmp57 = state.tangent_u[0];
            tmp58 = max(max(state.text_results[1].z, mdl_read_argblock_as_float(state.arg_block_offset)), 1.000000012e-07f);
            tmp59 = tmp18.x * tmp24;
            tmp60 = tmp18.y * tmp24;
            tmp61 = tmp18.z * tmp24;
            tmp62 = tmp28.zxy;
            tmp63 = tmp28.yzx;
            tmp64 = tmp57.yzx * tmp62 - tmp57.zxy * tmp63;
            float3 tmp65 = tmp64 * tmp64;
            tmp66 = tmp65.x + tmp65.y + tmp65.z;
            if (tmp66 < 9.999999939e-09f)
            {
                sret_ptr.pdf = 0.0f;
                sret_ptr.event_type = 0;
                index = 1;
                newPhi = 0.0f;
                newPhi74 = 0.0f;
                newPhi75 = 0.0f;
                newPhi76 = 0.0f;
                newPhi77 = 0.0f;
                newPhi78 = 0.0f;
                newPhi79 = 0.0f;
                newPhi80 = 0.0f;
                newPhi81 = 0.0f;
                newPhi82 = phi5;
                newPhi83 = phi;
            }
            else
            {
                float tmp79 = 1.0f / sqrt(tmp66);
                tmp80 = tmp79 * tmp64.x;
                tmp81 = tmp79 * tmp64.y;
                tmp82 = tmp79 * tmp64.z;
                tmp83 = float3(tmp80, tmp81, tmp82);
                tmp84 = tmp83.zxy * tmp63 - tmp83.yzx * tmp62;
                bool tmp85 = phi == -1.0f;
                phi_87 = phi;
                if (tmp85)
                {
                    sret_ptr.ior1.x = 1.0f;
                    sret_ptr.ior1.y = 1.0f;
                    sret_ptr.ior1.z = 1.0f;
                    phi_87 = 1.0f;
                }
                bool tmp88 = phi5 == -1.0f;
                phi_90 = phi5;
                if (tmp88)
                {
                    sret_ptr.ior2.x = 1.0f;
                    sret_ptr.ior2.y = 1.0f;
                    sret_ptr.ior2.z = 1.0f;
                    phi_90 = 1.0f;
                }
                float3 tmp91 = tmp84 * tmp22;
                float3 tmp92 = tmp83 * tmp22;
                tmp93 = sret_ptr.xi.x;
                tmp94 = sret_ptr.xi.y;
                float tmp95 = (tmp91.x + tmp91.y + tmp91.z) * tmp58;
                float tmp96 = (tmp92.x + tmp92.y + tmp92.z) * tmp58;
                tmp97 = tmp30 * tmp30;
                tmp98 = tmp95 * tmp95 + tmp96 * tmp96;
                float3 tmp99 = float3(sqrt(tmp98 + tmp97), 0.0f, 0.0f);
                tmp100 = float3(tmp95, abs(tmp30), tmp96) / tmp99.xxx;
                phi102 = 1.0f;
                phi104 = 0.0f;
                phi106 = 0.0f;
                if (tmp100.y < 0.9999899864f)
                {
                    float3 tmp107 = tmp100 * float3(1.0f, 0.0f, 0.0f);
                    float3 tmp108 = tmp100 * float3(0.0f, 0.0f, 1.0f);
                    float3 tmp109 = tmp107.yzx - tmp108.zxy;
                    float3 tmp110 = float3(sqrt(tmp109.x * tmp109.x + tmp109.y * tmp109.y + tmp109.z * tmp109.z), 0.0f, 0.0f);
                    float3 tmp111 = tmp109 / tmp110.xxx;
                    phi102 = tmp111.x;
                    phi104 = tmp111.y;
                    phi106 = tmp111.z;
                }
                float3 tmp112 = float3(phi102, phi104, phi106);
                float3 tmp113 = tmp112.yzx * tmp100.zxy - tmp112.zxy * tmp100.yzx;
                tmp114 = tmp100.y + 1.0f;
                tmp115 = 1.0f / tmp114;
                tmp116 = sqrt(tmp93);
                if (tmp94 < tmp115)
                {
                    tmp117 = tmp114 * 3.141592741f * tmp94;
                    phi119 = 1.0f;
                    phi121 = tmp117;
                }
                else
                {
                    tmp122 = (tmp94 - tmp115) * 3.141592741f / (1.0f - tmp115) + 3.141592741f;
                    phi119 = tmp100.y;
                    phi121 = tmp122;
                }
                float tmp123 = sin(phi121);
                float tmp124 = cos(phi121);
                float tmp125 = tmp124 * tmp116;
                float tmp126 = phi119 * tmp116;
                float tmp127 = tmp126 * tmp123;
                float tmp128 = tmp125 * phi102;
                float tmp129 = tmp125 * phi104;
                float tmp130 = sqrt(max(1.0f - (tmp127 * tmp127 + tmp125 * tmp125), 0.0f));
                float tmp131 = (tmp127 * tmp113.x + tmp128 + tmp130 * tmp100.x) * tmp58;
                float tmp132 = max(tmp127 * tmp113.y + tmp129 + tmp130 * tmp100.y, 0.0f);
                float tmp133 = (tmp127 * tmp113.z + tmp125 * phi106 + tmp130 * tmp100.z) * tmp58;
                float3 tmp134 = float3(sqrt(tmp131 * tmp131 + tmp132 * tmp132 + tmp133 * tmp133), 0.0f, 0.0f);
                float3 tmp135 = float3(tmp131, tmp132, tmp133) / tmp134.xxx;
                if (tmp135.y == 0.0f)
                {
                    sret_ptr.pdf = 0.0f;
                    sret_ptr.event_type = 0;
                    index = 1;
                    newPhi = 0.0f;
                    newPhi74 = 0.0f;
                    newPhi75 = 0.0f;
                    newPhi76 = 0.0f;
                    newPhi77 = 0.0f;
                    newPhi78 = 0.0f;
                    newPhi79 = 0.0f;
                    newPhi80 = 0.0f;
                    newPhi81 = 0.0f;
                    newPhi82 = phi_90;
                    newPhi83 = phi_87;
                }
                else
                {
                    tmp136 = tmp135.x * tmp84.x + tmp135.y * tmp25 + tmp135.z * tmp80;
                    tmp137 = tmp135.x * tmp84.y + tmp135.y * tmp26 + tmp135.z * tmp81;
                    tmp138 = tmp135.x * tmp84.z + tmp135.y * tmp27 + tmp135.z * tmp82;
                    float3 tmp139 = float3(tmp136, tmp137, tmp138) * tmp22;
                    tmp140 = tmp139.x + tmp139.y + tmp139.z;
                    if (tmp140 > 0.0f)
                    {
                        float tmp141 = tmp140 * 2.0f;
                        tmp142 = tmp141 * tmp136 - tmp19;
                        tmp143 = tmp141 * tmp137 - tmp20;
                        tmp144 = tmp141 * tmp138 - tmp21;
                        sret_ptr.k2.x = tmp142;
                        sret_ptr.k2.y = tmp143;
                        sret_ptr.k2.z = tmp144;
                        sret_ptr.event_type = 10;
                        sret_ptr.bsdf_over_pdf.x = 1.0f;
                        sret_ptr.bsdf_over_pdf.y = 1.0f;
                        sret_ptr.bsdf_over_pdf.z = 1.0f;
                        tmp145 = float3(tmp142, tmp143, tmp144);
                        float3 tmp146 = tmp145 * float3(tmp59, tmp60, tmp61);
                        if (tmp146.x + tmp146.y + tmp146.z > 0.0f)
                        {
                            float3 tmp147 = tmp145 * tmp28;
                            tmp148 = tmp147.x + tmp147.y + tmp147.z;
                            float3 tmp149 = tmp145 * tmp84;
                            float3 tmp150 = tmp145 * tmp83;
                            float tmp151 = (tmp149.x + tmp149.y + tmp149.z) * tmp58;
                            float tmp152 = (tmp150.x + tmp150.y + tmp150.z) * tmp58;
                            tmp153 = 2.0f / (sqrt((tmp152 * tmp152 + tmp151 * tmp151) / (tmp148 * tmp148) + 1.0f) + 1.0f);
                            if (tmp153 * 2.0f / (sqrt(tmp98 / tmp97 + 1.0f) + 1.0f) > 0.0f)
                            {
                                sret_ptr.handle = 0;
                                index = 0;
                                newPhi = tmp148;
                                newPhi74 = phi_90;
                                newPhi75 = phi_87;
                                newPhi76 = tmp153;
                                newPhi77 = tmp153;
                                newPhi78 = tmp153;
                                newPhi79 = tmp144;
                                newPhi80 = tmp143;
                                newPhi81 = tmp142;
                                newPhi82 = 0.0f;
                                newPhi83 = 0.0f;
                            }
                            else
                            {
                                sret_ptr.pdf = 0.0f;
                                sret_ptr.event_type = 0;
                                index = 1;
                                newPhi = 0.0f;
                                newPhi74 = 0.0f;
                                newPhi75 = 0.0f;
                                newPhi76 = 0.0f;
                                newPhi77 = 0.0f;
                                newPhi78 = 0.0f;
                                newPhi79 = 0.0f;
                                newPhi80 = 0.0f;
                                newPhi81 = 0.0f;
                                newPhi82 = phi_90;
                                newPhi83 = phi_87;
                            }
                        }
                        else
                        {
                            sret_ptr.pdf = 0.0f;
                            sret_ptr.event_type = 0;
                            index = 1;
                            newPhi = 0.0f;
                            newPhi74 = 0.0f;
                            newPhi75 = 0.0f;
                            newPhi76 = 0.0f;
                            newPhi77 = 0.0f;
                            newPhi78 = 0.0f;
                            newPhi79 = 0.0f;
                            newPhi80 = 0.0f;
                            newPhi81 = 0.0f;
                            newPhi82 = phi_90;
                            newPhi83 = phi_87;
                        }
                    }
                    else
                    {
                        sret_ptr.pdf = 0.0f;
                        sret_ptr.event_type = 0;
                        index = 1;
                        newPhi = 0.0f;
                        newPhi74 = 0.0f;
                        newPhi75 = 0.0f;
                        newPhi76 = 0.0f;
                        newPhi77 = 0.0f;
                        newPhi78 = 0.0f;
                        newPhi79 = 0.0f;
                        newPhi80 = 0.0f;
                        newPhi81 = 0.0f;
                        newPhi82 = phi_90;
                        newPhi83 = phi_87;
                    }
                }
            }
        }
        else
        {
            float3 tmp154 = state.tangent_u[0];
            tmp155 = tmp0.x * tmp24;
            tmp156 = tmp0.y * tmp24;
            tmp157 = tmp0.z * tmp24;
            tmp158 = float3(tmp155, tmp156, tmp157);
            tmp159 = tmp158.zxy;
            tmp160 = tmp158.yzx;
            tmp161 = tmp154.yzx * tmp159 - tmp154.zxy * tmp160;
            float3 tmp162 = tmp161 * tmp161;
            tmp163 = tmp162.x + tmp162.y + tmp162.z;
            if (tmp163 < 9.999999939e-09f)
            {
                sret_ptr.pdf = 0.0f;
                sret_ptr.event_type = 0;
                index = 1;
                newPhi = 0.0f;
                newPhi74 = 0.0f;
                newPhi75 = 0.0f;
                newPhi76 = 0.0f;
                newPhi77 = 0.0f;
                newPhi78 = 0.0f;
                newPhi79 = 0.0f;
                newPhi80 = 0.0f;
                newPhi81 = 0.0f;
                newPhi82 = phi5;
                newPhi83 = phi;
            }
            else
            {
                float tmp164 = 1.0f / sqrt(tmp163);
                tmp165 = tmp164 * tmp161.x;
                tmp166 = tmp164 * tmp161.y;
                tmp167 = tmp164 * tmp161.z;
                float3 tmp168 = float3(tmp165, tmp166, tmp167);
                float3 tmp169 = tmp168.zxy * tmp160 - tmp168.yzx * tmp159;
                tmp170 = min(max(state.text_results[0].x, 0.0f), 1.0f);
                tmp171 = min(max(state.text_results[0].y, 0.0f), 1.0f);
                tmp172 = min(max(state.text_results[0].z, 0.0f), 1.0f);
                tmp173 = float3(tmp18.x * tmp24, tmp18.y * tmp24, tmp18.z * tmp24);
                float3 tmp174 = tmp173 * tmp158;
                tmp175 = max(tmp174.x + tmp174.y + tmp174.z, 0.0f);
                tmp176 = 3.141592741f / (tmp175 * 1.570796371f + 1.570796371f);
                tmp177 = tmp176 + -1.0f;
                tmp178 = sret_ptr.xi.x;
                tmp179 = tmp178 < tmp177;
                if (tmp179)
                {
                    tmp180 = tmp178 / tmp177;
                    phi182 = tmp180;
                }
                else
                {
                    tmp183 = min(max((tmp178 - tmp177) / (2.0f - tmp176), 0.0f), 0.9999999404f);
                    phi182 = tmp183;
                }
                sret_ptr.xi.x = phi182;
                tmp184 = sret_ptr.xi.y;
                bool tmp185 = phi182 == 0.0f;
                phi187 = float3(0.0f, 1.0f, 0.0f);
                if (!(tmp185 && tmp184 == 0.0f))
                {
                    float tmp188 = phi182 * 2.0f;
                    float tmp189 = tmp184 * 2.0f;
                    tmp190 = tmp188 < 1.0f ? tmp188 : tmp188 + -2.0f;
                    tmp191 = tmp189 < 1.0f ? tmp189 : tmp189 + -2.0f;
                    tmp192 = tmp190 * tmp190;
                    tmp193 = tmp191 * tmp191;
                    if (tmp192 > tmp193)
                    {
                        tmp194 = tmp191 * -0.7853981853f / tmp190;
                        phi196 = tmp190;
                        phi198 = tmp194;
                        phi200 = tmp192;
                    }
                    else
                    {
                        tmp201 = tmp190 * 0.7853981853f / tmp191 + -1.570796371f;
                        phi196 = tmp191;
                        phi198 = tmp201;
                        phi200 = tmp193;
                    }
                    tmp202 = 1.0f - phi200;
                    phi187 = float3(0.0f, 1.0f, 0.0f);
                    if (tmp202 > 0.0f)
                    {
                        tmp203 = float3(sin(phi198) * phi196, sqrt(tmp202), cos(phi198) * phi196);
                        phi187 = tmp203;
                    }
                }
                tmp204 = phi187.x;
                tmp205 = phi187.y;
                tmp206 = phi187.z;
                phi_208 = tmp169.x;
                phi_210 = tmp169.y;
                phi_212 = tmp169.z;
                phi214 = tmp165;
                phi216 = tmp166;
                phi218 = tmp167;
                if (tmp175 < 0.9990000129f)
                {
                    float3 tmp219 = tmp159 * tmp173.yzx - tmp160 * tmp173.zxy;
                    float3 tmp220 = float3(sqrt(tmp219.x * tmp219.x + tmp219.y * tmp219.y + tmp219.z * tmp219.z), 0.0f, 0.0f);
                    float3 tmp221 = tmp219 / tmp220.xxx;
                    float3 tmp222 = tmp221.yzx * tmp159 - tmp221.zxy * tmp160;
                    phi_208 = tmp221.x;
                    phi_210 = tmp221.y;
                    phi_212 = tmp221.z;
                    phi214 = tmp222.x;
                    phi216 = tmp222.y;
                    phi218 = tmp222.z;
                }
                phi224 = tmp205;
                phi226 = tmp206;
                if (tmp206 > 0.0f)
                {
                    if (tmp179)
                    {
                        tmp227 = -tmp206;
                        phi224 = tmp205;
                        phi226 = tmp227;
                    }
                    else
                    {
                        tmp228 = tmp206 * tmp175;
                        tmp229 = sqrt(max(1.0f - (tmp228 * tmp228 + tmp204 * tmp204), 0.0f));
                        phi224 = tmp229;
                        phi226 = tmp228;
                    }
                }
                float tmp230 = phi224 * tmp155 + phi_208 * tmp204 + phi226 * phi214;
                float tmp231 = phi224 * tmp156 + phi_210 * tmp204 + phi226 * phi216;
                float tmp232 = phi224 * tmp157 + phi_212 * tmp204 + phi226 * phi218;
                float3 tmp233 = float3(sqrt(tmp230 * tmp230 + tmp231 * tmp231 + tmp232 * tmp232), 0.0f, 0.0f);
                tmp234 = float3(tmp230, tmp231, tmp232) / tmp233.xxx;
                sret_ptr.k2.x = tmp234.x;
                sret_ptr.k2.y = tmp234.y;
                sret_ptr.k2.z = tmp234.z;
                float3 tmp235 = tmp234 * tmp173;
                if (tmp235.x + tmp235.y + tmp235.z > 0.0f)
                {
                    sret_ptr.event_type = 9;
                    sret_ptr.handle = 1;
                    float3 tmp236 = tmp234 * tmp28;
                    tmp237 = tmp236.x + tmp236.y + tmp236.z;
                    index = 0;
                    newPhi = tmp237;
                    newPhi74 = phi5;
                    newPhi75 = phi;
                    newPhi76 = tmp172;
                    newPhi77 = tmp171;
                    newPhi78 = tmp170;
                    newPhi79 = tmp234.z;
                    newPhi80 = tmp234.y;
                    newPhi81 = tmp234.x;
                    newPhi82 = 0.0f;
                    newPhi83 = 0.0f;
                }
                else
                {
                    sret_ptr.pdf = 0.0f;
                    sret_ptr.event_type = 0;
                    index = 1;
                    newPhi = 0.0f;
                    newPhi74 = 0.0f;
                    newPhi75 = 0.0f;
                    newPhi76 = 0.0f;
                    newPhi77 = 0.0f;
                    newPhi78 = 0.0f;
                    newPhi79 = 0.0f;
                    newPhi80 = 0.0f;
                    newPhi81 = 0.0f;
                    newPhi82 = phi5;
                    newPhi83 = phi;
                }
            }
        }
        bool indexCmp = index == 0;
        phi_239 = newPhi82;
        phi_241 = newPhi83;
        if (indexCmp)
        {
            tmp242 = abs(newPhi);
            float tmp243 = newPhi81 + tmp19;
            float tmp244 = newPhi80 + tmp20;
            float tmp245 = newPhi79 + tmp21;
            float3 tmp246 = float3(sqrt(tmp244 * tmp244 + tmp243 * tmp243 + tmp245 * tmp245), 0.0f, 0.0f);
            float3 tmp247 = float3(tmp243, tmp244, tmp245) * tmp22 / tmp246.xxx;
            tmp248 = tmp247.x + tmp247.y + tmp247.z;
            tmp249 = abs(tmp248);
            if (phi49)
            {
                phi251 = 1.0f;
                if (!tmp34)
                {
                    float tmp252 = sqrt(tmp33);
                    float tmp253 = tmp31 * tmp17;
                    float tmp254 = tmp252 * tmp17;
                    float tmp255 = (tmp252 - tmp253) / (tmp252 + tmp253);
                    float tmp256 = (tmp31 - tmp254) / (tmp254 + tmp31);
                    tmp257 = min(max((tmp256 * tmp256 + tmp255 * tmp255) * 0.5f, 0.0f), 1.0f);
                    phi251 = tmp257;
                }
                tmp258 = 1.0f - (1.0f - newPhi * newPhi) / tmp32;
                phi260 = 1.0f;
                if (!(tmp258 < 0.0f))
                {
                    float tmp261 = sqrt(tmp258);
                    float tmp262 = tmp242 * tmp17;
                    float tmp263 = tmp261 * tmp17;
                    float tmp264 = (tmp261 - tmp262) / (tmp261 + tmp262);
                    float tmp265 = (tmp242 - tmp263) / (tmp263 + tmp242);
                    tmp266 = min(max((tmp265 * tmp265 + tmp264 * tmp264) * 0.5f, 0.0f), 1.0f);
                    phi260 = tmp266;
                }
                tmp267 = (1.0f - max(phi251, phi260)) * phi53;
                sret_ptr.bsdf_over_pdf.x = tmp267 * newPhi78;
                sret_ptr.bsdf_over_pdf.y = tmp267 * newPhi77;
                phi269 = newPhi76;
                phi271 = tmp267;
            }
            else
            {
                tmp272 = 1.0f - (1.0f - tmp248 * tmp248) / tmp32;
                phi274 = 1.0f;
                if (!(tmp272 < 0.0f))
                {
                    float tmp275 = sqrt(tmp272);
                    float tmp276 = tmp249 * tmp17;
                    float tmp277 = tmp275 * tmp17;
                    float tmp278 = (tmp275 - tmp276) / (tmp275 + tmp276);
                    float tmp279 = (tmp249 - tmp277) / (tmp277 + tmp249);
                    tmp280 = min(max((tmp279 * tmp279 + tmp278 * tmp278) * 0.5f, 0.0f), 1.0f);
                    phi274 = tmp280;
                }
                tmp281 = phi274 * phi53;
                sret_ptr.bsdf_over_pdf.x = tmp281 * newPhi78;
                sret_ptr.bsdf_over_pdf.y = newPhi77 * tmp281;
                phi269 = tmp281;
                phi271 = newPhi76;
            }
            sret_ptr.bsdf_over_pdf.z = phi271 * phi269;
            phi_239 = newPhi74;
            phi_241 = newPhi75;
        }
    }
    else
    {
        sret_ptr.pdf = 0.0f;
        sret_ptr.event_type = 0;
        phi_239 = phi5;
        phi_241 = phi;
    }
    pdf_data.ior1.x = phi_241;
    pdf_data.ior1.y = sret_ptr.ior1.y;
    pdf_data.ior1.z = sret_ptr.ior1.z;
    pdf_data.ior2.x = phi_239;
    pdf_data.ior2.y = sret_ptr.ior2.y;
    pdf_data.ior2.z = sret_ptr.ior2.z;
    pdf_data.k1.x = tmp19;
    pdf_data.k1.y = tmp20;
    pdf_data.k1.z = tmp21;
    pdf_data.k2.x = sret_ptr.k2.x;
    pdf_data.k2.y = sret_ptr.k2.y;
    pdf_data.k2.z = sret_ptr.k2.z;
    gen_fresnel_layer_pdf(pdf_data, state, normal_buf);
    float tmp282 = pdf_data.pdf;
    sret_ptr.pdf = tmp282;
    return;
}

void surface_scattering_evaluate(inout Bsdf_evaluate_data sret_ptr, in Shading_state_material state)
{
    float tmp2;
    float phi;
    float tmp3;
    float phi5;
    bool phi_in7;
    bool phi8;
    bool tmp9;
    float phi11;
    float tmp12;
    float phi14;
    float tmp15;
    float tmp17;
    float tmp18;
    float tmp20;
    float tmp21;
    float tmp22;
    float3 tmp23;
    float tmp25;
    float tmp26;
    float tmp27;
    float tmp28;
    float tmp29;
    float tmp30;
    float tmp31;
    float3 tmp32;
    float tmp34;
    float tmp35;
    float tmp36;
    float tmp37;
    bool tmp38;
    float phi40;
    float tmp46;
    float tmp47;
    float tmp48;
    float tmp49;
    float3 tmp50;
    float3 tmp51;
    float tmp53;
    bool tmp54;
    bool tmp55;
    float tmp57;
    float tmp58;
    float tmp59;
    float tmp60;
    float tmp61;
    float phi_64;
    float phi_66;
    float phi_68;
    float tmp69;
    float tmp70;
    float tmp71;
    float tmp73;
    float tmp74;
    float tmp75;
    float tmp76;
    float tmp77;
    float tmp78;
    float3 tmp80;
    float tmp83;
    float tmp84;
    float phi86;
    float tmp92;
    float tmp94;
    float3 tmp95;
    float3 tmp96;
    float3 tmp97;
    float tmp99;
    float phi101;
    float3 phi103;
    float3 tmp105;
    float3 tmp106;
    float tmp109;
    float3 tmp114;
    float tmp116;
    float tmp133;
    float3 tmp135;
    int tmp136;
    int tmp137;
    float phi140;
    float tmp146;
    float phi148;
    float tmp150;
    float tmp151;
    float phi153;
    float tmp159;
    float tmp160;
    float tmp161;
    float tmp162;
    float tmp163;
    float phi165;
    float tmp170;
    bool tmp171;
    int tmp172;
    float3 tmp0 = state.normal;
    sret_ptr.bsdf_diffuse[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_diffuse[3] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[0] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[1] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[2] = float3(0.0f, 0.0f, 0.0f);
    sret_ptr.bsdf_glossy[3] = float3(0.0f, 0.0f, 0.0f);
    float3 tmp1 = mdl_adapt_normal(state, tmp0);
    tmp2 = sret_ptr.ior1.x;
    phi = tmp2;
    if (tmp2 == -1.0f)
    {
        sret_ptr.ior1.x = 1.0f;
        sret_ptr.ior1.y = 1.0f;
        sret_ptr.ior1.z = 1.0f;
        phi = 1.0f;
    }
    tmp3 = sret_ptr.ior2.x;
    phi5 = tmp3;
    if (tmp3 == -1.0f)
    {
        sret_ptr.ior2.x = 1.0f;
        sret_ptr.ior2.y = 1.0f;
        sret_ptr.ior2.z = 1.0f;
        phi5 = 1.0f;
    }
    bool tmp6 = phi5 == 1.0f;
    phi_in7 = false;
    if (tmp6)
    {
        phi_in7 = false;
        if (sret_ptr.ior2.y == 1.0f)
        {
            tmp9 = sret_ptr.ior2.z == 1.0f;
            phi_in7 = tmp9;
        }
    }
    phi8 = phi_in7;
    phi11 = 1.5f;
    if (phi8)
    {
        tmp12 = (sret_ptr.ior1.y + phi + sret_ptr.ior1.z) * 0.3333333433f;
        phi11 = tmp12;
    }
    phi14 = 1.5f;
    if (!phi8)
    {
        tmp15 = (sret_ptr.ior2.y + phi5 + sret_ptr.ior2.z) * 0.3333333433f;
        phi14 = tmp15;
    }
    float tmp16 = phi14 - phi11;
    tmp17 = abs(tmp16) < 9.999999747e-05f ? phi11 + asfloat((asint(tmp16) & -2147483648) | 953267991) : phi14;
    tmp18 = tmp17 / phi11;
    float3 tmp19 = state.geom_normal;
    tmp20 = sret_ptr.k1.x;
    tmp21 = sret_ptr.k1.y;
    tmp22 = sret_ptr.k1.z;
    tmp23 = float3(tmp20, tmp21, tmp22);
    float3 tmp24 = tmp23 * tmp19;
    tmp25 = asfloat((asint(tmp24.x + tmp24.y + tmp24.z) & -2147483648) | 1065353216);
    tmp26 = tmp19.x * tmp25;
    tmp27 = tmp19.y * tmp25;
    tmp28 = tmp19.z * tmp25;
    tmp29 = tmp1.x * tmp25;
    tmp30 = tmp1.y * tmp25;
    tmp31 = tmp1.z * tmp25;
    tmp32 = float3(tmp29, tmp30, tmp31);
    float3 tmp33 = tmp32 * tmp23;
    tmp34 = tmp33.x + tmp33.y + tmp33.z;
    tmp35 = min(max(tmp34, 0.0f), 1.0f);
    tmp36 = tmp18 * tmp18;
    tmp37 = 1.0f - (1.0f - tmp35 * tmp35) / tmp36;
    tmp38 = tmp37 < 0.0f;
    phi40 = 1.0f;
    if (!tmp38)
    {
        float tmp41 = sqrt(tmp37);
        float tmp42 = tmp35 * tmp18;
        float tmp43 = tmp41 * tmp18;
        float tmp44 = (tmp41 - tmp42) / (tmp41 + tmp42);
        float tmp45 = (tmp35 - tmp43) / (tmp43 + tmp35);
        tmp46 = min(max((tmp45 * tmp45 + tmp44 * tmp44) * 0.5f, 0.0f), 1.0f);
        phi40 = tmp46;
    }
    tmp47 = sret_ptr.k2.x;
    tmp48 = sret_ptr.k2.y;
    tmp49 = sret_ptr.k2.z;
    tmp50 = float3(tmp47, tmp48, tmp49);
    tmp51 = float3(tmp26, tmp27, tmp28);
    float3 tmp52 = tmp50 * tmp51;
    tmp53 = tmp52.x + tmp52.y + tmp52.z;
    tmp54 = tmp53 < 0.0f;
    tmp55 = phi11 >= 0.0f && tmp54;
    float3 tmp56 = tmp50 * tmp32;
    tmp57 = tmp56.x + tmp56.y + tmp56.z;
    tmp58 = abs(tmp57);
    if (tmp54)
    {
        if (tmp55)
        {
            tmp59 = tmp47 * tmp17 + tmp20 * phi11;
            tmp60 = tmp48 * tmp17 + tmp21 * phi11;
            tmp61 = tmp49 * tmp17 + tmp22 * phi11;
            bool tmp62 = tmp17 > phi11;
            phi_64 = tmp59;
            phi_66 = tmp60;
            phi_68 = tmp61;
            if (tmp62)
            {
                tmp69 = -tmp61;
                tmp70 = -tmp60;
                tmp71 = -tmp59;
                phi_64 = tmp71;
                phi_66 = tmp70;
                phi_68 = tmp69;
            }
        }
        else
        {
            float tmp72 = tmp58 * 2.0f;
            tmp73 = tmp47 + tmp20 + tmp72 * tmp29;
            tmp74 = tmp48 + tmp21 + tmp72 * tmp30;
            tmp75 = tmp49 + tmp22 + tmp72 * tmp31;
            phi_64 = tmp73;
            phi_66 = tmp74;
            phi_68 = tmp75;
        }
    }
    else
    {
        tmp76 = tmp47 + tmp20;
        tmp77 = tmp48 + tmp21;
        tmp78 = tmp49 + tmp22;
        phi_64 = tmp76;
        phi_66 = tmp77;
        phi_68 = tmp78;
    }
    float3 tmp79 = float3(sqrt(phi_66 * phi_66 + phi_64 * phi_64 + phi_68 * phi_68), 0.0f, 0.0f);
    tmp80 = float3(phi_64, phi_66, phi_68) / tmp79.xxx;
    float3 tmp81 = tmp80 * tmp23;
    float tmp82 = tmp81.x + tmp81.y + tmp81.z;
    tmp83 = abs(tmp82);
    tmp84 = 1.0f - (1.0f - tmp82 * tmp82) / tmp36;
    phi86 = 1.0f;
    if (!(tmp84 < 0.0f))
    {
        float tmp87 = sqrt(tmp84);
        float tmp88 = tmp83 * tmp18;
        float tmp89 = tmp87 * tmp18;
        float tmp90 = (tmp87 - tmp88) / (tmp87 + tmp88);
        float tmp91 = (tmp83 - tmp89) / (tmp89 + tmp83);
        tmp92 = min(max((tmp91 * tmp91 + tmp90 * tmp90) * 0.5f, 0.0f), 1.0f);
        phi86 = tmp92;
    }
    float3 tmp93 = state.tangent_u[0];
    tmp94 = max(max(state.text_results[1].z, mdl_read_argblock_as_float(state.arg_block_offset)), 1.000000012e-07f);
    tmp95 = tmp32.zxy;
    tmp96 = tmp32.yzx;
    tmp97 = tmp93.yzx * tmp95 - tmp93.zxy * tmp96;
    float3 tmp98 = tmp97 * tmp97;
    tmp99 = tmp98.x + tmp98.y + tmp98.z;
    phi101 = 0.0f;
    phi103 = float3(0.0f, 0.0f, 0.0f);
    if (!(tmp99 < 9.999999939e-09f))
    {
        float tmp104 = 1.0f / sqrt(tmp99);
        tmp105 = float3(tmp104 * tmp97.x, tmp104 * tmp97.y, tmp104 * tmp97.z);
        tmp106 = tmp105.zxy * tmp96 - tmp105.yzx * tmp95;
        bool tmp107 = phi == -1.0f;
        if (tmp107)
        {
            sret_ptr.ior1.x = 1.0f;
            sret_ptr.ior1.y = 1.0f;
            sret_ptr.ior1.z = 1.0f;
        }
        bool tmp108 = phi5 == -1.0f;
        if (tmp108)
        {
            sret_ptr.ior2.x = 1.0f;
            sret_ptr.ior2.y = 1.0f;
            sret_ptr.ior2.z = 1.0f;
        }
        tmp109 = abs(tmp34);
        phi101 = 0.0f;
        phi103 = float3(0.0f, 0.0f, 0.0f);
        if (!tmp54)
        {
            float tmp110 = tmp47 + tmp20;
            float tmp111 = tmp48 + tmp21;
            float tmp112 = tmp49 + tmp22;
            float3 tmp113 = float3(sqrt(tmp111 * tmp111 + tmp110 * tmp110 + tmp112 * tmp112), 0.0f, 0.0f);
            tmp114 = float3(tmp110, tmp111, tmp112) / tmp113.xxx;
            float3 tmp115 = tmp114 * tmp32;
            tmp116 = tmp115.x + tmp115.y + tmp115.z;
            float3 tmp117 = tmp114 * tmp23;
            float3 tmp118 = tmp114 * tmp50;
            phi101 = 0.0f;
            phi103 = float3(0.0f, 0.0f, 0.0f);
            if (!(tmp118.x + tmp118.y + tmp118.z < 0.0f || (tmp116 < 0.0f || tmp117.x + tmp117.y + tmp117.z < 0.0f)))
            {
                float3 tmp119 = tmp106 * tmp114;
                float3 tmp120 = tmp105 * tmp114;
                float tmp121 = 1.0f / tmp94;
                float tmp122 = (tmp119.x + tmp119.y + tmp119.z) * tmp121;
                float tmp123 = (tmp120.x + tmp120.y + tmp120.z) * tmp121;
                float tmp124 = tmp123 * tmp123 + tmp116 * tmp116 + tmp122 * tmp122;
                float3 tmp125 = tmp106 * tmp23;
                float3 tmp126 = tmp105 * tmp23;
                float3 tmp127 = tmp106 * tmp50;
                float3 tmp128 = tmp105 * tmp50;
                float tmp129 = (tmp125.x + tmp125.y + tmp125.z) * tmp94;
                float tmp130 = (tmp126.x + tmp126.y + tmp126.z) * tmp94;
                float tmp131 = (tmp127.x + tmp127.y + tmp127.z) * tmp94;
                float tmp132 = (tmp128.x + tmp128.y + tmp128.z) * tmp94;
                tmp133 = tmp121 * tmp121 * (tmp116 * 0.1591549367f) / (tmp124 * tmp124 * (tmp116 * tmp109) * (sqrt((tmp129 * tmp129 + tmp130 * tmp130) / (tmp34 * tmp34) + 1.0f) + 1.0f));
                float tmp134 = tmp133 * 2.0f / (sqrt((tmp131 * tmp131 + tmp132 * tmp132) / (tmp57 * tmp57) + 1.0f) + 1.0f);
                tmp135 = float3(tmp134, tmp134, tmp134);
                phi101 = tmp133;
                phi103 = tmp135;
            }
        }
    }
    tmp136 = sret_ptr.handle_offset;
    tmp137 = -tmp136;
    if (uint(tmp137) < 4u)
    {
        int tmp138 = tmp137;
        sret_ptr.bsdf_glossy[tmp138].x = sret_ptr.bsdf_glossy[tmp138].x + phi103.x * phi86;
        sret_ptr.bsdf_glossy[tmp138].y = sret_ptr.bsdf_glossy[tmp138].y + phi103.y * phi86;
        sret_ptr.bsdf_glossy[tmp138].z = sret_ptr.bsdf_glossy[tmp138].z + phi103.z * phi86;
    }
    phi140 = 1.0f;
    if (!tmp38)
    {
        float tmp141 = sqrt(tmp37);
        float tmp142 = tmp35 * tmp18;
        float tmp143 = tmp141 * tmp18;
        float tmp144 = (tmp141 - tmp142) / (tmp141 + tmp142);
        float tmp145 = (tmp35 - tmp143) / (tmp143 + tmp35);
        tmp146 = min(max((tmp145 * tmp145 + tmp144 * tmp144) * 0.5f, 0.0f), 1.0f);
        phi140 = tmp146;
    }
    phi148 = tmp58;
    if (tmp55)
    {
        float3 tmp149 = tmp80 * tmp32;
        tmp150 = (tmp149.x + tmp149.y + tmp149.z) * 2.0f * tmp83 - tmp35;
        phi148 = tmp150;
    }
    tmp151 = 1.0f - (1.0f - phi148 * phi148) / tmp36;
    phi153 = 1.0f;
    if (!(tmp151 < 0.0f))
    {
        float tmp154 = sqrt(tmp151);
        float tmp155 = phi148 * tmp18;
        float tmp156 = tmp154 * tmp18;
        float tmp157 = (tmp154 - tmp155) / (tmp154 + tmp155);
        float tmp158 = (phi148 - tmp156) / (tmp156 + phi148);
        tmp159 = min(max((tmp158 * tmp158 + tmp157 * tmp157) * 0.5f, 0.0f), 1.0f);
        phi153 = tmp159;
    }
    tmp160 = 1.0f - max(phi140, phi153);
    tmp161 = min(max(state.text_results[0].x, 0.0f), 1.0f);
    tmp162 = min(max(state.text_results[0].y, 0.0f), 1.0f);
    tmp163 = min(max(state.text_results[0].z, 0.0f), 1.0f);
    phi165 = 0.0f;
    if (tmp53 > 0.0f)
    {
        float3 tmp166 = float3(tmp0.x * tmp25, tmp0.y * tmp25, tmp0.z * tmp25);
        float3 tmp167 = tmp166 * tmp51;
        float3 tmp168 = tmp50 * tmp166;
        float tmp169 = max(tmp168.x + tmp168.y + tmp168.z, 0.0f);
        tmp170 = tmp169 / (max(tmp167.x + tmp167.y + tmp167.z, 0.0f) * 1.570796371f + 1.570796371f);
        tmp171 = tmp169 > 0.0f;
        tmp172 = 1 - tmp136;
        phi165 = tmp170;
        if (uint(tmp172) < 4u)
        {
            int tmp173 = tmp172;
            sret_ptr.bsdf_diffuse[tmp173].x = sret_ptr.bsdf_diffuse[tmp173].x + (tmp171 ? tmp161 * tmp170 : 0.0f) * tmp160;
            sret_ptr.bsdf_diffuse[tmp173].y = sret_ptr.bsdf_diffuse[tmp173].y + (tmp171 ? tmp162 * tmp170 : 0.0f) * tmp160;
            sret_ptr.bsdf_diffuse[tmp173].z = sret_ptr.bsdf_diffuse[tmp173].z + (tmp171 ? tmp163 * tmp170 : 0.0f) * tmp160;
            phi165 = tmp170;
        }
    }
    sret_ptr.pdf = (phi101 - phi165) * phi40 + phi165;
    return;
}

void surface_scattering_pdf(inout Bsdf_pdf_data sret_ptr, in Shading_state_material state)
{
    float3 normal_buf;
    float3 tmp0 = state.normal;
    normal_buf.x = tmp0.x;
    normal_buf.y = tmp0.y;
    normal_buf.z = tmp0.z;
    gen_fresnel_layer_pdf(sret_ptr, state, normal_buf);
    return;
}

void surface_scattering_auxiliary(inout Bsdf_auxiliary_data sret_ptr, in Shading_state_material state)
{
    float tmp2;
    float phi;
    float tmp3;
    float phi5;
    bool phi_in7;
    bool phi8;
    bool tmp9;
    float phi11;
    float tmp12;
    float phi14;
    float tmp15;
    float tmp17;
    float tmp20;
    float tmp21;
    float tmp22;
    float tmp23;
    float3 tmp24;
    float tmp26;
    float tmp27;
    float phi29;
    float tmp35;
    float tmp36;
    float3 tmp38;
    float3 tmp39;
    int tmp42;
    float tmp45;
    float tmp46;
    float tmp47;
    float tmp48;
    int tmp52;
    int post_loop_index;
    int tmp55;
    float tmp56;
    float tmp57;
    float tmp58;
    float tmp60;
    int tmp61;
    float3 tmp0 = state.normal;
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
    float3 tmp1 = mdl_adapt_normal(state, tmp0);
    tmp2 = sret_ptr.ior1.x;
    phi = tmp2;
    if (tmp2 == -1.0f)
    {
        sret_ptr.ior1.x = 1.0f;
        sret_ptr.ior1.y = 1.0f;
        sret_ptr.ior1.z = 1.0f;
        phi = 1.0f;
    }
    tmp3 = sret_ptr.ior2.x;
    phi5 = tmp3;
    if (tmp3 == -1.0f)
    {
        sret_ptr.ior2.x = 1.0f;
        sret_ptr.ior2.y = 1.0f;
        sret_ptr.ior2.z = 1.0f;
        phi5 = 1.0f;
    }
    bool tmp6 = phi5 == 1.0f;
    phi_in7 = false;
    if (tmp6)
    {
        phi_in7 = false;
        if (sret_ptr.ior2.y == 1.0f)
        {
            tmp9 = sret_ptr.ior2.z == 1.0f;
            phi_in7 = tmp9;
        }
    }
    phi8 = phi_in7;
    phi11 = 1.5f;
    if (phi8)
    {
        tmp12 = (sret_ptr.ior1.y + phi + sret_ptr.ior1.z) * 0.3333333433f;
        phi11 = tmp12;
    }
    phi14 = 1.5f;
    if (!phi8)
    {
        tmp15 = (sret_ptr.ior2.y + phi5 + sret_ptr.ior2.z) * 0.3333333433f;
        phi14 = tmp15;
    }
    float tmp16 = phi14 - phi11;
    tmp17 = (abs(tmp16) < 9.999999747e-05f ? phi11 + asfloat((asint(tmp16) & -2147483648) | 953267991) : phi14) / phi11;
    float3 tmp18 = sret_ptr.k1;
    float3 tmp19 = tmp18 * state.geom_normal;
    tmp20 = asfloat((asint(tmp19.x + tmp19.y + tmp19.z) & -2147483648) | 1065353216);
    tmp21 = tmp1.x * tmp20;
    tmp22 = tmp1.y * tmp20;
    tmp23 = tmp1.z * tmp20;
    tmp24 = float3(tmp21, tmp22, tmp23);
    float3 tmp25 = tmp24 * tmp18;
    tmp26 = min(max(tmp25.x + tmp25.y + tmp25.z, 0.0f), 1.0f);
    tmp27 = 1.0f - (1.0f - tmp26 * tmp26) / (tmp17 * tmp17);
    phi29 = 1.0f;
    if (!(tmp27 < 0.0f))
    {
        float tmp30 = sqrt(tmp27);
        float tmp31 = tmp26 * tmp17;
        float tmp32 = tmp30 * tmp17;
        float tmp33 = (tmp30 - tmp31) / (tmp30 + tmp31);
        float tmp34 = (tmp26 - tmp32) / (tmp32 + tmp26);
        tmp35 = min(max((tmp34 * tmp34 + tmp33 * tmp33) * 0.5f, 0.0f), 1.0f);
        phi29 = tmp35;
    }
    tmp36 = max(state.text_results[1].z, mdl_read_argblock_as_float(state.arg_block_offset));
    float3 tmp37 = state.tangent_u[0];
    tmp38 = tmp37.yzx;
    tmp39 = tmp37.zxy;
    float3 tmp40 = tmp38 * tmp24.zxy - tmp39 * tmp24.yzx;
    float3 tmp41 = tmp40 * tmp40;
    if (!(tmp41.x + tmp41.y + tmp41.z < 9.999999939e-09f))
    {
        tmp42 = -sret_ptr.handle_offset;
        if (uint(tmp42) < 4u)
        {
            float tmp43 = tmp36 * phi29;
            int tmp44 = tmp42;
            sret_ptr.albedo_glossy[tmp44].x = sret_ptr.albedo_glossy[tmp44].x + phi29;
            sret_ptr.albedo_glossy[tmp44].y = sret_ptr.albedo_glossy[tmp44].y + phi29;
            sret_ptr.albedo_glossy[tmp44].z = sret_ptr.albedo_glossy[tmp44].z + phi29;
            sret_ptr.normal[tmp44].x = sret_ptr.normal[tmp44].x + phi29 * tmp21;
            sret_ptr.normal[tmp44].y = sret_ptr.normal[tmp44].y + phi29 * tmp22;
            sret_ptr.normal[tmp44].z = sret_ptr.normal[tmp44].z + phi29 * tmp23;
            sret_ptr.roughness[tmp44].x = sret_ptr.roughness[tmp44].x + tmp43;
            sret_ptr.roughness[tmp44].y = sret_ptr.roughness[tmp44].y + tmp43;
            sret_ptr.roughness[tmp44].z = sret_ptr.roughness[tmp44].z + phi29;
        }
    }
    tmp45 = 1.0f - phi29;
    tmp46 = tmp0.x * tmp20;
    tmp47 = tmp0.y * tmp20;
    tmp48 = tmp0.z * tmp20;
    float3 tmp49 = float3(tmp46, tmp47, tmp48);
    float3 tmp50 = tmp38 * tmp49.zxy - tmp39 * tmp49.yzx;
    float3 tmp51 = tmp50 * tmp50;
    if (!(tmp51.x + tmp51.y + tmp51.z < 9.999999939e-09f))
    {
        tmp52 = 1 - sret_ptr.handle_offset;
        if (uint(tmp52) < 4u)
        {
            int tmp53 = tmp52;
            sret_ptr.albedo_diffuse[tmp53].x = min(max(state.text_results[0].x, 0.0f), 1.0f) * tmp45 + sret_ptr.albedo_diffuse[tmp53].x;
            sret_ptr.albedo_diffuse[tmp53].y = sret_ptr.albedo_diffuse[tmp53].y + min(max(state.text_results[0].y, 0.0f), 1.0f) * tmp45;
            sret_ptr.albedo_diffuse[tmp53].z = sret_ptr.albedo_diffuse[tmp53].z + min(max(state.text_results[0].z, 0.0f), 1.0f) * tmp45;
            sret_ptr.normal[tmp53].x = sret_ptr.normal[tmp53].x + tmp45 * tmp46;
            sret_ptr.normal[tmp53].y = sret_ptr.normal[tmp53].y + tmp45 * tmp47;
            sret_ptr.normal[tmp53].z = sret_ptr.normal[tmp53].z + tmp45 * tmp48;
            sret_ptr.roughness[tmp53].z = sret_ptr.roughness[tmp53].z + tmp45;
        }
    }
    post_loop_index = 0;
    do
    {
        tmp55 = post_loop_index;
        tmp56 = sret_ptr.normal[tmp55].x;
        tmp57 = sret_ptr.normal[tmp55].y;
        tmp58 = sret_ptr.normal[tmp55].z;
        if (tmp56 != 0.0f || (tmp57 != 0.0f || tmp58 != 0.0f))
        {
            float3 tmp59 = float3(sqrt(tmp57 * tmp57 + tmp56 * tmp56 + tmp58 * tmp58), 0.0f, 0.0f);
            sret_ptr.normal[tmp55] = float3(tmp56, tmp57, tmp58) / tmp59.xxx;
        }
        tmp60 = sret_ptr.roughness[tmp55].z;
        if (!(tmp60 == 0.0f))
        {
            sret_ptr.roughness[tmp55].x = sret_ptr.roughness[tmp55].x / tmp60;
            sret_ptr.roughness[tmp55].y = sret_ptr.roughness[tmp55].y / tmp60;
        }
        tmp61 = post_loop_index + 1;
        bool tmp62 = uint(post_loop_index) < 3u;
        post_loop_index = tmp61;
        if (!tmp62)
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

float surface_scattering_layer_roughness_u(in Shading_state_material state)
{
    return max(state.text_results[1].z, mdl_read_argblock_as_float(state.arg_block_offset));
}

float surface_scattering_layer_roughness_v(in Shading_state_material state)
{
    return max(state.text_results[1].z, mdl_read_argblock_as_float(state.arg_block_offset));
}

float3 surface_scattering_layer_tangent_u(in Shading_state_material state)
{
    return state.tangent_u[0];
}

float3 surface_scattering_layer_tint(in Shading_state_material state)
{
    return float3(1.0f, 1.0f, 1.0f);
}

float surface_scattering_base_roughness(in Shading_state_material state)
{
    return 0.0f;
}

float3 surface_scattering_base_tint(in Shading_state_material state)
{
    return state.text_results[0].xyz;
}
float mdl_lambda_roughness_u(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 0:
        return surface_scattering_layer_roughness_u(state);
    case 1:
        return surface_scattering_base_roughness(state);
    default:
        break;
    }
    return 0.0f;
}

float mdl_lambda_roughness_v(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 0:
        return surface_scattering_layer_roughness_v(state);
    default:
        break;
    }
    return 0.0f;
}

float3 mdl_lambda_tangent(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 0:
        return surface_scattering_layer_tangent_u(state);
    default:
        break;
    }
    return float3(0.0f, 0.0f, 0.0f);
}

float3 mdl_lambda_tint(in uint bsdf_index, in Shading_state_material state)
{
    switch (bsdf_index)
    {
    case 0:
        return surface_scattering_layer_tint(state);
    case 1:
        return surface_scattering_base_tint(state);
    default:
        break;
    }
    return float3(0.0f, 0.0f, 0.0f);
}

} // mdl_ceramic_material_ns

public struct MDLCeramicMaterialInstance : IMaterialInstance
{
    mdl_ceramic_material_ns::Shading_state_material state;
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

        mdl_ceramic_material_ns::init(state);

        const float3 exteriorIoR = sd_ws.ior;
        const float3 interiorIoR = mdl_ceramic_material_ns::ior(state);

        this.ior1 = select(sd_ws.front_facing, exteriorIoR, interiorIoR);
        this.ior2 = select(sd_ws.front_facing, interiorIoR, exteriorIoR);
    }

    __init(const mdl_ceramic_material_ns::Shading_state_material state, const float3 ior1, const float3 ior2)
    {
        this.state = state;
        this.ior1 = ior1;
        this.ior2 = ior2;
    }

    float3 eval(const ShadingData sd_ws, const float3 wo, inout UniformSampleGenerator sg)
    {
        mdl_ceramic_material_ns::Bsdf_evaluate_data eval_data = {};
        eval_data.ior1 = ior1;     // IOR current medium
        eval_data.ior2 = ior2;     // IOR other side
        eval_data.k1 = sd_ws.view; // outgoing direction
        eval_data.k2 = wo;         // incoming direction

        float3 result = float3(0.f);
        uint surface_scatter_bsdf_count = mdl_ceramic_material_ns::MATERIAL_DATA_NAME.surface_scatter_bsdf_count;
        uint offset = 0;
        for (; offset < surface_scatter_bsdf_count; offset += MDL_DF_HANDLE_SLOT_MODE)
        {
            eval_data.handle_offset = offset;
            mdl_ceramic_material_ns::surface_scattering_evaluate(eval_data, state);
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
        mdl_ceramic_material_ns::Bsdf_sample_data sample_data = {};
        sample_data.ior1 = ior1;          // IOR current medium
        sample_data.ior2 = ior2;          // IOR other side
        sample_data.k1 = sd_ws.view;      // outgoing direction
        sample_data.xi = next_float4(sg); // pseudo-random sample numbers

        mdl_ceramic_material_ns::surface_scattering_sample(sample_data, state);

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
        mdl_ceramic_material_ns::Bsdf_pdf_data pdf_data = {};
        pdf_data.ior1 = ior1;     // IOR current medium
        pdf_data.ior2 = ior2;     // IOR other side
        pdf_data.k1 = sd_ws.view; // outgoing direction
        pdf_data.k2 = wo_ws;      // incoming direction

        mdl_ceramic_material_ns::surface_scattering_pdf(pdf_data, state);

        return pdf_data.pdf;
    }

    MaterialProperties collect_properties(const ShadingData sd_ws)
    {
        MaterialProperties result = {};

        mdl_ceramic_material_ns::Bsdf_auxiliary_data aux = {};
        mdl_ceramic_material_ns::surface_scattering_auxiliary(aux, state);

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

        mdl_ceramic_material_ns::Bsdf_auxiliary_data aux = {};

        aux.ior1 = ior1;     // IOR current medium
        aux.ior2 = ior2;     // IOR other side
        aux.k1 = sd_ws.view; // outgoing direction

        uint surface_scatter_bsdf_count =
            mdl_ceramic_material_ns::MATERIAL_DATA_NAME.surface_scatter_bsdf_count;
        result.bsdf_count =
            surface_scatter_bsdf_count;
        uint offset = 0;
        for (; offset < result.bsdf_count; offset +=
                                           MDL_DF_HANDLE_SLOT_MODE)
        {
            aux.handle_offset = offset;
            mdl_ceramic_material_ns::surface_scattering_auxiliary(aux, state);
            for (uint lobe = 0; (lobe < MDL_DF_HANDLE_SLOT_MODE) && ((offset + lobe) < result.bsdf_count); ++lobe)
            {
                float3 N = aux.normal[lobe];
                if (any(isnan(N)) || any(isinf(N)))
                    N = sd_ws.geometric_normal;
                float3 T = mdl_ceramic_material_ns::mdl_lambda_tangent(lobe + offset, state);
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
                result.bsdf_weight[lobe + offset] = mdl_ceramic_material_ns::mdl_lambda_tint(lobe + offset, state);
                result.bsdf_roughness[lobe + offset].x = mdl_ceramic_material_ns::mdl_lambda_roughness_u(lobe + offset, state);
                result.bsdf_roughness[lobe + offset].y = mdl_ceramic_material_ns::mdl_lambda_roughness_v(lobe + offset, state);
            }
        }

        return result;
    }
};
