sampler2D _MainTex;
struct Attributes {
  float4 positionOS : POSITION;
  float2 texcoord   : TEXCOORD0;
#ifdef REQUIRES_NORMAL
  float3 normalOS   : NORMAL;
#endif
};
struct Varyings {
  float4 positionCS : SV_POSITION;
  float2 uv         : TEXCOORD0;
#ifdef REQUIRES_NORMAL
  float3 normalWS   : TEXCOORD1;
#endif
};

Varyings vert(Attributes input) {
  Varyings output;
  output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
  output.uv = input.texcoord;
#ifdef REQUIRES_NORMAL
  output.normalWS = input.normalOS;
#endif
  return output;
}
#ifdef REQUIRES_NORMAL
float4 frag(Varyings input) : SV_TARGET {
  float alpha = tex2D(_MainTex, input.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return float4(normalize(input.normalWS), 0.0f);
}
#else
void frag(Varyings input) {
  float alpha = tex2D(_MainTex, input.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return;
}
#endif
