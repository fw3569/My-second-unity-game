sampler2D _MainTex;
struct Attributes {
  float4 positionOS : POSITION;
  float2 texcoord   : TEXCOORD0;
};
struct Vertex {
  float2 texcoord   : TEXCOORD0;
  float3 positionOS : TEXCOORD1;
};
struct Varyings {
  float4 positionCS : SV_POSITION;
  float2 uv         : TEXCOORD0;
};

Vertex vert (Attributes input) {
  Vertex output;
  output.positionOS = input.positionOS;
  output.texcoord = input.texcoord;
  return output;
}
[maxvertexcount(6)]
void geo(triangle Vertex input[3], inout TriangleStream<Varyings> output) {
  if(all(input[0].positionOS == input[1].positionOS) || all(input[1].positionOS == input[2].positionOS)) {
    return;
  }
  float4 positionCS[3];
  float3 centerCS = float3(0.0f, 0.0f, 0.0f);
  float zVS[3];
  for(int i = 0; i < 3; ++i) {
    positionCS[i] = TransformObjectToHClip(input[i].positionOS);
    zVS[i] = positionCS[i].w;
    positionCS[i] /= positionCS[i].w;
    centerCS += positionCS[i].xyz;
  }
  centerCS /= 3.0f;
  float3 normal = normalize(cross(positionCS[2] - positionCS[1], positionCS[0] - positionCS[1]));
  float aspect = _ScreenParams.y / _ScreenParams.x;
  float outlineWidth = _OutlineWidth * _OutlineCameraBais;
#ifdef _CULL_OFF
  Varyings vertex[6];
  [unroll]
  for(int i = 0; i < 3; ++i) {
    vertex[2 * i].uv = input[i].texcoord;
    vertex[2 * i + 1].uv = input[i].texcoord;
    float3 outlineVec = cross(normal, positionCS[(i + 2) % 3] - positionCS[i]);
    float3 outlineStep = outlineWidth / length(outlineVec.xy) * length(outlineVec) * normalize(outlineVec) / (zVS[i] + _OutlineCameraBais);
    outlineStep.x *= aspect;
    outlineStep.z = -dot(outlineStep.xy, normal.xy) / normal.z;
    float3 outlinePositionCS = positionCS[i] + outlineStep;
    outlinePositionCS.z -= (1 - outlinePositionCS.z) * 0.0001;
    vertex[2 * i].positionCS = float4(outlinePositionCS, 1.0f) * zVS[i];
    outlineVec = cross(positionCS[(i + 1) % 3] - positionCS[i], normal);
    outlineStep = outlineWidth / length(outlineVec.xy) * length(outlineVec) * normalize(outlineVec) / (zVS[i] + _OutlineCameraBais);
    outlineStep.x *= aspect;
    outlineStep.z = -dot(outlineStep.xy, normal.xy) / normal.z;
    outlinePositionCS = positionCS[i] + outlineStep;
    outlinePositionCS.z -= (1 - outlinePositionCS.z) * 0.0001;
    vertex[2 * i + 1].positionCS = float4(outlinePositionCS, 1.0f) * zVS[i];
  }
  output.Append(vertex[0]);
  output.Append(vertex[1]);
  output.Append(vertex[5]);
  output.Append(vertex[2]);
  output.Append(vertex[4]);
  output.Append(vertex[3]);
#else
  [unroll]
  for(int i = 2; i >= 0; --i) {
    Varyings vertex;
    vertex.uv = input[i].texcoord;
    float3 outlineVec = normal;
    float3 outlineStep = outlineWidth / length(outlineVec.xy) * length(outlineVec) * normalize(outlineVec) / zVS[i];
    outlineStep.x *= aspect;
    outlineStep.z = 0;
    float3 outlinePositionCS = positionCS[i] + outlineStep;
    vertex.positionCS = float4(outlinePositionCS, 1.0f) * zVS[i];
    output.Append(vertex);
  }
#endif
}
half4 frag (Varyings input) : SV_Target0 {
  float alpha = tex2D(_MainTex, input.uv).a;
  clip(alpha - _AlphaClip * _Cutoff);
  return half4(0.0, 0.0, 0.0, 1.0);
}
