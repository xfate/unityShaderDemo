// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "xjm/outline_postEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size",float) = 1
		_BlurTex("Blur Tex",2D) = ""{}
		_OriTex("Ori", 2D) = "white"{}
		_OutlineColor("OutLine Color",Color) = (1,1,1,1)
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	uniform half4 _MainTex_TexelSize;
	
	float _BlurSize;	
	sampler2D _MainTex;
	sampler2D _BlurTex;
	sampler2D _OriTex;
	float4 _OutlineColor;
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

	//add
	struct v2f_add
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
	};
	v2f_add vert_add(appdata_img v)
	{
		v2f_add o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		o.uv1 = o.uv;
		o.uv2 = o.uv;
#if UNITY_UV_STARTS_AT_TOP
			o.uv2.y = 1 - o.uv2.y;
			o.uv.y = 1- o.uv.y;
#endif	
		return o;
	}
	half4 frag_add(v2f_add i):COLOR
	{
		//获取屏幕
		fixed4 scene = tex2D(_MainTex, i.uv1);
		fixed4 blurCol = tex2D(_BlurTex,i.uv1);
		fixed4 pureCol = tex2D(_OriTex,i.uv1);
		return (blurCol - pureCol)+scene;
		//fixed4 outlineColor = clamp(blurCol - pureCol,0,1);
	//	return scene * (1 - all(outlineColor.rgb))  +  _OutlineColor*any(outlineColor.rgb);

		
	}

	//add
	ENDCG
	SubShader
	{
	
		ZTest Always
			
			ZWrite Off
			Fog{ Mode Off }

		//0
		Pass 
		{
			ZTest Always
			Cull Off
			CGPROGRAM
			#pragma vertex vert_blur_Horizonal
			#pragma fragment frag_blur
			ENDCG
		}
		//1
		Pass
		{
			ZTest Always
			Cull Off
			CGPROGRAM
			#pragma vertex vert_blur_Vertical
			#pragma fragment frag_blur
			ENDCG
		}
		//2
		Pass
		{
			ZTest Off
			Cull Off
 
			CGPROGRAM
			#pragma vertex vert_add
			#pragma fragment frag_add
			ENDCG
		}

	}
}
