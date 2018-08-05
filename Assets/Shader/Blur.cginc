
	#include "UnityCG.cginc"
	uniform half4 _MainTex_TexelSize;
	float _BlurSize;	
	sampler2D _MainTex;
	//高斯模糊权重
	static const half4 GaussWeight[7] =
	{
		half4(0.0205,0.0205,0.0205,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.232,0.232,0.232,0),
		half4(0.324,0.324,0.324,1),
		half4(0.232,0.232,0.232,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.0205,0.0205,0.0205,0)
	};
	struct v2f_Blur
	{
		float4 pos:SV_POSITION;
		half2 uv:TEXCOORD0;
		half2 offset:TEXCOORD1;
	};
	v2f_Blur vert_blur_Horizonal(appdata_img v)
	{
		v2f_Blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		o.offset = _MainTex_TexelSize.xy * half2(1,0)*_BlurSize;
		return o;
	}
	v2f_Blur vert_blur_Vertical(appdata_img v)
	{
		v2f_Blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		o.offset = _MainTex_TexelSize.xy * half2(0,1)*_BlurSize;
		return o;
	}
	half4 frag_blur(v2f_Blur i):COLOR
	{
		half2 uv_withOffset = i.uv - i.offset * 3;
		half4 color = 0;
		for (int j = 0; j < 7; ++j)
		{
			half4 texcol = tex2D(_MainTex,uv_withOffset);
			color += texcol * GaussWeight[j];
			uv_withOffset += i.offset;
		}
		return color;
	}
