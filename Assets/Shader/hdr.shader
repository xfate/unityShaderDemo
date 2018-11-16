Shader "Post/HDR_ImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Exposure("Exposure",float) = 1// 曝光
		_Luminance("Luminance",float) = 1//
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		ZTest Always
		Cull Off
		ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			half _Exposure;
			half _Luminance;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 color = tex2D(_MainTex, i.uv);
			
    			
    			const float A = 2.51f;
	const float B = 0.03f;
	const float C = 2.43f;
	const float D = 0.59f;
	const float E = 0.14f;

			color *= _Exposure;
	return (color * (A * color + B)) / (color * (C * color + D) + E);

			//	float tone = _Exposure * (_Exposure / _Luminance+1)/(_Exposure+1);
			//	return tex*tone;
			}
			ENDCG
		}
	}
}
