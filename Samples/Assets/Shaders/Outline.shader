Shader "Tsg Samples/Outline" {
	SubShader {
		Pass {
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct vertexInput {
			    float4 vertex : POSITION;
			    float3 normal : NORMAL;
			};

			float4 vert(vertexInput i) : SV_POSITION {
				return mul(UNITY_MATRIX_MVP, i.vertex + float4(i.normal * 0.001, 0.0));
		  	}

	    	fixed4 frag() : SV_Target {
	        	return fixed4(1.0, 1.0, 0.0, 1.0);
	    	}
			ENDCG
		}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct vertexInput {
			    float4 vertex : POSITION;
			    float3 normal : NORMAL;
			};

			float4 vert(vertexInput i) : SV_POSITION {
				return mul(UNITY_MATRIX_MVP, i.vertex);
		  	}

	    	fixed4 frag() : SV_Target {
	        	return fixed4(1.0, 0.0, 0.0, 1.0);
	    	}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
