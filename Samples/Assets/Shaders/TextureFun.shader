Shader "Tsg Samples/Texture Fun" {
    Properties {
	  // _MainTex unused, only to force Unity to generate some tex coords.
	  // In normal app, 3d artist just prepares model with tex coords.
      _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert
      struct Input {
          float2 uv_MainTex;
      };
      sampler2D _MainTex;
      void surf (Input IN, inout SurfaceOutput o) {
          //o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		  //o.Albedo = fixed3(IN.uv_MainTex.x, IN.uv_MainTex.y, 0.0);
		  float x = (IN.uv_MainTex.x - 0.5);
		  float y = (IN.uv_MainTex.y - 0.5);
		  float d = sqrt(x * x + y * y); // probably could do without sqrt
		  //o.Albedo = fixed3(d, d, 0.0);
		  if (d < 0.5) {
		  	discard;
		  }
		  d = 1.0 - d;
		  o.Albedo = fixed3(d, d, 0.0);
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }