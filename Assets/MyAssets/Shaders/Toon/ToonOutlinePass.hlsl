sampler2D _MainTex;
struct Attributes {
  float4 positionOS : POSITION;
  float4 normalOS   : NORMAL;
  float4 tangentOS  : TANGENT;
  float2 texcoord   : TEXCOORD0;
};
struct Varyings {
  float4 positionCS : SV_POSITION;
  float2 uv         : TEXCOORD0;
};
Varyings vert (Attributes input) {
  Varyings output;
  float3 position = input.positionOS.xyz;
  float3 bitangent = cross(input.normalOS, input.tangentOS.xyz) * input.tangentOS.w;
  // position -= bitangent;
  float4 positionCS = TransformObjectToHClip(position.xyz);
  // need to consider w > eps
  // positionCS /= positionCS.w;
  // positionCS.z -= 0.00001;
  output.positionCS = positionCS;
  output.uv = input.texcoord;
  return output;
}
half4 frag (Varyings input) : SV_Target0 {
  float alpha = tex2D(_MainTex, input.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return half4(1.0, 0.0, 0.0, 1.0);
}
