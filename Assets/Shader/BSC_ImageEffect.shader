Shader "Post/BSC_ImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Brightness("_Brightness",float) = 1.0
		_Saturation("_Saturation",float) = 1.0
		Contrast("_Contrast", float) = 1.0
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
			half _Brightness;
			half _Saturation;
			half _Contrast;
			
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
				fixed4 tex = tex2D(_MainTex, i.uv);

				fixed3 finalCol = tex.rgb * _Brightness;
				fixed luminance = 0.2125f * tex.r + 0.7154f * tex.g + 0.0721f * tex.b;
				fixed3 lumCol = fixed3(luminance, luminance, luminance);//这是一个饱和度为0的颜色值
				finalCol = lerp(lumCol, finalCol, _Saturation);
				fixed3 avgCol = fixed3(0.5f, 0.5f, 0.5f);;//这是一个对比度为0的颜色值
				finalCol = lerp(avgCol, finalCol, _Contrast);
	
				return fixed4(finalCol,tex.a);
			}
			ENDCG
		}
	}
}
