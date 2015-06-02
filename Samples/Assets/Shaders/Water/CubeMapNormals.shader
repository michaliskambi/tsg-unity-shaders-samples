Shader "Tsg Samples/Cube Reflection + Varied Normals" {
    Properties {
      // MainTex only to get tex coords.
      _MainTex ("Texture", 2D) = "white" {}
      _Cube ("Cubemap", CUBE) = "" {}
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert
      struct Input {
          float2 uv_MainTex;
          float3 worldRefl;
          INTERNAL_DATA
      };
      sampler2D _MainTex;
      samplerCUBE _Cube;
      
      float height(float2 v)
      {
	      return sin(v.x * 4.0) * sin(v.y * 4.0);
      }
      
      void surf (Input IN, inout SurfaceOutput o) 
      {
      	  float SHIFT = 0.001;
      	
          //float3 worldRefl = float3(0.0, 1.0, 0.0);
          float2 v = IN.uv_MainTex.xy;
          v.x += _Time.y;
          float h = height(v);
          float hX = height(v + float2(SHIFT, 0.0));
          float hY = height(v + float2(0.0, SHIFT));
          
          float3 vHere = float3(v.x, h, v.y);
          float3 vX = float3(v.x + SHIFT, hX, v.y); 
          float3 vY = float3(v.x        , hY, v.y + SHIFT);
          float3 n = cross(vX, vY);
          
          o.Normal = normalize(n);
          
          float3 refl = WorldReflectionVector (IN, n);
	  //reflect(IN.viewDir, n);
          
          o.Albedo = texCUBE(_Cube, refl).rgb;
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }