Shader "xjm/outline_pre"
{
		Properties
	{
		_OutlineColor("OutLine Color",Color) = (1,1,1,1)
	}
	SubShader
	{

		Pass
		{

		
			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag

			float4 _OutlineColor;
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}
		
	}
}
