Shader "Tsg Samples/Texture" {
	Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct vertexInput {
                float4 vertex : POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            struct fragmentInput{
                float4 position : SV_POSITION;
                float4 texcoord0 : TEXCOORD0;
            };
            
            uniform sampler2D _MainTex;

            fragmentInput vert(vertexInput i){
                fragmentInput o;
                o.position = mul (UNITY_MATRIX_MVP, i.vertex);
                o.texcoord0 = i.texcoord0;
                return o;
            }
            fixed4 frag(fragmentInput i) : SV_Target {
            	return tex2D(_MainTex, i.texcoord0);
            }
            ENDCG
        }
    }
}