sampler2D _MainTex;
struct Attributes {
  float4 positionOS        : POSITION;
  float3 normalOS          : NORMAL;
  float2 texcoord          : TEXCOORD0;
  float2 staticLightmapUV  : TEXCOORD1;
  float2 dynamicLightmapUV : TEXCOORD2;
};
struct Varyings {
  float4 positionCS        : SV_POSITION;
  float2 uv                : TEXCOORD0;
  float3 positionWS        : TEXCOORD1;
  float3 normalWS          : TEXCOORD2;
#ifdef LIGHTMAP_ON
  float2 staticLightmapUV  : TEXCOORD3;
#else
  half3 vertexSH           : TEXCOORD3;
#endif
#ifdef DYNAMICLIGHTMAP_ON
  float2 dynamicLightmapUV : TEXCOORD4;
#endif
#ifdef USE_APV_PROBE_OCCLUSION
  float4 probeOcclusion    : TEXCOORD5;
#endif
};

// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
// #pragma instancing_options assumeuniformscaling
UNITY_INSTANCING_BUFFER_START(Props)
  // put more per-instance properties here
UNITY_INSTANCING_BUFFER_END(Props)
// Following function is copied from LitForwardPass.hlsl
void InitializeBakedGIData(Varyings input, inout InputData inputData) {
#if defined(DYNAMICLIGHTMAP_ON)
  inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
  inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
  inputData.bakedGI = SAMPLE_GI(input.vertexSH,
    GetAbsolutePositionWS(inputData.positionWS),
    inputData.normalWS,
    inputData.viewDirectionWS,
    input.positionCS.xy,
    input.probeOcclusion,
    inputData.shadowMask);
#else
  inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
  inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#endif
}
// --------------------------------------------------------------------------
Varyings Vert (Attributes input) {
  Varyings output;
  output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
  output.uv = input.texcoord.xy;
  output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
  output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS));
  // Following part is copied from LitForwardPass.hlsl
  VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
  OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
  output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
  OUTPUT_SH4(vertexInput.positionWS, output.normalWS.xyz, GetWorldSpaceNormalizeViewDir(vertexInput.positionWS), output.vertexSH, output.probeOcclusion);
  // ------------------------------------------------------------------------
  return output;
}
half4 Frag (Varyings input) : SV_Target0 {
  half4 color = tex2D(_MainTex, input.uv) * _BaseColor;
  clip(color.a - _AlphaClip * _Cutoff);
  float3 lightDir = normalize(_MainLightPosition.xyz);
  float3 normal = normalize(input.normalWS);
  float light = dot(normal, lightDir);
#ifdef _CULL_OFF
  light = max(0.0f, light);
#else
  light = abs(light);
#endif
#ifdef _Toon
  light = light > _LightThreshold ? 1.0f : 0.3f;
  color = int4(color * 32);
  color = (color) / 32.0f;
#endif
  // Following part is copied from LitForwardPass.hlsl
  InputData inputData = (InputData)0;
  inputData.positionWS = input.positionWS;
  inputData.normalWS = input.normalWS;
  inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
  half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
  inputData.viewDirectionWS = viewDirWS;
  inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
  inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
  InitializeBakedGIData(input, inputData);
  SurfaceData surfaceData;
  surfaceData.albedo = color.rgb;
  surfaceData.specular = _Specular;
  surfaceData.metallic = _Metallic;
  surfaceData.smoothness = _Smoothness;
  surfaceData.normalTS = half3(0, 0, 1);
  surfaceData.emission = half3(0, 0, 0);
  surfaceData.occlusion = half(1.0);
  surfaceData.alpha = color.a;
  surfaceData.clearCoatMask = 0;
  surfaceData.clearCoatSmoothness = 1;
  color = UniversalFragmentPBR(inputData, surfaceData);
  // ------------------------------------------------------------------------
  return color;
}
