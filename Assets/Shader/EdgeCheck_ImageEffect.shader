Shader "Custom/EdgeCheck_ImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeOnly("Edge Only",float) = 1.0
		_EdgeColor("Edge Color",Color) = (1,1,1,1)
		_backGroundColor("background color",Color) = (0.1,0.1,0.1,0.1)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
				
				float4 vertex : SV_POSITION;
				half2 uv[9]: TEXCOORD0;
			};
			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
					
			fixed4 _EdgeColor;
			half _EdgeOnly;
			fixed4 _backGroundColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half2 uv =  v.uv;
				o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
				o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
				o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
				o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
				o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
				o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);
				return o;
			}
			

			fixed luminance(fixed4 color)
			{
				return color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;
			}
			half Sobel(v2f i)
			{
				const half gx[9] = {-1,-2,-1,
									0,0,0,
									1,2,1};
				const half gy[9] = {-1,0,1,
									-2,0,2,
									-1,0,1};
				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for (int it = 0; it < 9; ++it)
				{
					texColor = luminance(tex2D(_MainTex,i.uv[it]));
					edgeX += gx[it] * texColor;
					edgeY += gy[it] * texColor;

				}
				half edge = 1 - abs(edgeX) - abs(edgeY);
				return edge;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				half edge = Sobel(i);
				fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor,_backGroundColor,edge);

				return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
			}
			ENDCG
		}
	}
}
