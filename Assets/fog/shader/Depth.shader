Shader "Unlit/Depth"
{

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 depth :TEXCOORD0;
			};


			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_DEPTH(o.depth);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_OUTPUT_DEPTH(i.depth);

			
			}
			ENDCG
		}
	}
}
