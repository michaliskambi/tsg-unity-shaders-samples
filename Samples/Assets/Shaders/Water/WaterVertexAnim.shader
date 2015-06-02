Shader "Tsg Samples/Cube Reflection + Vertex Anim" {
    Properties {
      // _MainTex only to get tex coords.
      _MainTex ("Texture", 2D) = "white" {}
      _Cube ("Cubemap", CUBE) = "" {}
      _WavesFreq ("Waves Freq", Vector) = (4.0, 4.0, 0.0, 0.0)
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert vertex:myvert
      struct Input {
          float2 uv_MainTex;
          float3 worldRefl;
          INTERNAL_DATA
      };
      sampler2D _MainTex;
      samplerCUBE _Cube;
      float4 _WavesFreq;

      float height(float2 v)
      {
	  return sin(v.x *  _WavesFreq.x) * sin(v.y *  _WavesFreq.y);
      }

      void myvert (inout appdata_full vData, out Input data) {
      	  UNITY_INITIALIZE_OUTPUT(Input, data);

	  // note data.uv_MainTex is useless now
          float2 v = vData.texcoord.xy;
          v.x += _Time.y;
          float h = height(v);
	  vData.vertex.y += h;
      }

      void surf (Input IN, inout SurfaceOutput o)
      {
      	  float SHIFT = 0.01;

          //float3 worldRefl = float3(0.0, 1.0, 0.0);
          float2 v = IN.uv_MainTex.xy;
          v.x += _Time.y;
          float h = height(v);
          float hX = height(v + float2(SHIFT, 0.0));
          float hY = height(v + float2(0.0, SHIFT));

	  // TODO: write this cleaner, don't use SHIFT 4 times.
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
