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

Varyings vert(Attributes v) {
  Varyings o;
  o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
  o.uv = v.texcoord;
#ifdef REQUIRES_NORMAL
  o.normalWS = v.normalOS;
#endif
  return o;
}
#ifdef REQUIRES_NORMAL
float4 frag(Varyings i) : SV_TARGET {
  float alpha = tex2D(_MainTex, i.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return float4(normalize(i.normalWS), 0.0f);
}
#else
void frag(Varyings i) {
  float alpha = tex2D(_MainTex, i.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return;
}
#endif
