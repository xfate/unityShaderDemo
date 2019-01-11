Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	//CGINCLUDE
	CGINCLUDE
			float _FurLength;
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert_fur (appdata v)
			{
				v2f o;
				float3 newPos = v.vertex + v.normal * _FurLength;
				o.vertex = UnityObjectToClipPos(float4(newPos,1.0f));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag_fur (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
ENDCG

	//ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass //0
		{
			CGPROGRAM
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			ENDCG
		}
	}
}
