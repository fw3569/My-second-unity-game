
Shader "Custom/A2" {
  Properties {
    _Color ("Color", Color) = (1, 1, 1, 1)
  }
  SubShader {
    Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" "DisableBatching"="False" "QUEUE"="Geometry" "UniversalMaterialType"="Lit"}
    Blend SrcAlpha One
    BlendOp Add
    ZWrite On
    Cull Front 
    LOD 200
    Pass {
      Tags { "LIGHTMODE"="UniversalForward"}
      HLSLPROGRAM
      #pragma multi_compile_instancing
      #pragma vertex vert
      #pragma fragment frag
      #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
      CBUFFER_START(UnityPerMaterial)
      float4 _Color;
      CBUFFER_END
      struct appdata {
        float4 vertex : POSITION;
      };
      struct v2f {
        float4 pos : SV_POSITION;
      };
      v2f vert(appdata v) {
        v2f o;
        o.pos = TransformObjectToHClip(v.vertex.xyz);
        return o;
      }
      float4 frag(v2f i) : SV_Target {
        #ifdef UNITY_RENDER_PIPELINE_URP
        return float4(1, 0, 0, 1);
        #endif
        return _Color;
      }
      ENDHLSL
    }
  }
}
