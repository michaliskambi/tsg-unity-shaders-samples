Shader "Tsg Samples/Simplest (Surface)" {
	SubShader {
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert
		struct Input {
			// we have to declare *something* as Input			
			float4 color : COLOR;
		};
		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = 1;
		}
		ENDCG
	}
	Fallback "Diffuse"
}