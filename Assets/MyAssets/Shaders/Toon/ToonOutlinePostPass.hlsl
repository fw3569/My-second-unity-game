sampler2D _MainTex;
sampler2D _DepthTex;
struct Varyings {
  float4 positionCS : SV_POSITION;
  float2 uv         : TEXCOORD0;
};

Varyings Vert (uint vertexID : SV_VertexID) {
  Varyings output;
  output.positionCS = GetFullScreenTriangleVertexPosition(vertexID);
  output.uv = GetFullScreenTriangleTexCoord(vertexID);
  return output;
}
half ColorToGray(half4 color) {
  return color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
}
half EdgeValue(sampler2D tex, float2 texelSize, float2 uv) {
  static const half sobleX[2][2] = {{ 1,-1}, {1,-1}};
  static const half sobleY[2][2] = {{-1,-1}, {1, 1}};
  half edgeX = 0.0;
  half edgeY = 0.0;
  for(int i = 0; i < 2; ++i){
    for(int j = 0; j < 2; ++j){
      half gray = ColorToGray(tex2D(tex, uv + float2((i - 1) * texelSize.x, (j - 1) * texelSize.y)));
      edgeX += sobleX[i][j] * gray;
      edgeY += sobleY[i][j] * gray;
    }
  }
  return abs(edgeX) + abs(edgeY);
}
half4 Frag (Varyings input) : SV_Target0 {
  half colorEdgeValue = EdgeValue(_MainTex, _MainTex_TexelSize.xy, input.uv);
  half depthEdgeValue = EdgeValue(_DepthTex, _DepthTex_TexelSize.xy, input.uv);
  half isEdge = (colorEdgeValue > _EdgeThresholdColor) || (depthEdgeValue > _EdgeThresholdDepth);
  return half4((1 - isEdge) * tex2D(_MainTex, input.uv).xyz, 1.0);
}
