Shader "xjm/wetness"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RippleTex("Ripple",2D) = ""{}
		_NormalTex("Normal Tex",2D) = ""{}
		_HeightTex("HeightTex",2D) = ""{}
		_LightPos("LightPosition",Vector) = (0,0,0,0)
		_Gloss("Gloss",Range(1,256)) = 20
		_LightCol("LightColor",Color) = (1,1,1,1)
		_RippleDensity("Ripple Density",float) = 1
		_AccumulateWater("AccumulateWater",Range(0,1)) = 0
	}
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
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 tToW0:TEXCOORD1;
				float4 tToW1:TEXCOORD2;
				float4 tToW2:TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalTex;
			sampler2D _RippleTex;
			sampler2D _HeightTex;
			uniform float4 _LightPos;
			float _Gloss;
			float4 _LightCol;
			float _RippleDensity;
			float _AccumulateWater;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 pos = mul(unity_ObjectToWorld,v.vertex.xyz).xyz;
				float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject).xyz);
				float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld,v.tangent).xyz);
				float3 worldBinormal = normalize(cross(worldNormal,worldTangent))*v.tangent.w;
				o.tToW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,pos.x);
				o.tToW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,pos.y);
				o.tToW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,pos.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 worldPos = float3(i.tToW0.w,i.tToW1.w,i.tToW2.w);
				float3 lightDir = normalize(_LightPos.xyz - worldPos);
				float3 viewDir  = normalize(UnityWorldSpaceViewDir(worldPos));
				float3x3 matToW = float3x3(i.tToW0.xyz,i.tToW1.xyz,i.tToW2.xyz);
				float3 tNormal = UnpackNormal(tex2D(_NormalTex,i.uv));
				float3 wNormal = normalize(mul(matToW,tNormal)).xyz;
				// ripple tex
				float3 rippleNormal = tex2D(_RippleTex,i.uv * _RippleDensity).xyz * 2 - 1;
				float3 wRippleNormal = normalize(mul(matToW,rippleNormal));
				float3 normal = lerp(wNormal,wRippleNormal,_AccumulateWater);

				float3 diffuse = _LightCol.rgb * col.rgb * max(0,dot(normal,lightDir));
				//specular 
				float3 halfDir = normalize(lightDir + viewDir);
				float3 specular = _LightCol.rgb * pow(max(0,dot(normal,halfDir)),_Gloss);

				return float4(diffuse+specular,1.0f);
			}
			ENDCG
		}
	}
}
