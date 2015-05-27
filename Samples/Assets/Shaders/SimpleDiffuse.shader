// based on http://en.wikibooks.org/wiki/Cg_Programming/Unity/Diffuse_Reflection

Shader "Tsg Samples/Diffuse Lighting (Gouraud Shading)" {
   Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
   }
   SubShader {
      Pass {	
         Tags { "LightMode" = "ForwardBase" } 
            // make sure that all uniforms are correctly set
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
 
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         uniform float4 _Color; // define shader property for shaders
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors

            // note: homogeneus coords, so direction has 4th component 0
            //
            // this makes both normalDirection and lightDirection in world space,
            // it's important to be *the same* space            
            float3 normalDirection = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 
  			// vector dot is cos between vectors, for normalized vectors
            float3 diffuseReflection = (_LightColor0.rgb * _Color.rgb)
               * max(0.0, dot(normalDirection, lightDirection));

            output.col = float4(diffuseReflection, 1.0);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            return input.col;
         }
 
         ENDCG
      }
   }
   Fallback "Diffuse"
}