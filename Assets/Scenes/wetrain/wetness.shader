Shader "xjm/wetness"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RippleTex("Ripple",2D) = ""{}
		_NormalTex("Normal Tex",2D) = ""{}
		_HeightTex("HeightTex",2D) = ""{}
		_LightPos("LightPosition",Vector) = (0,0,0,0)
		_MaskTex("Mask Tex",2D) = ""{}
		_CubeMap("Environment",CUBE) = ""{}
		_Gloss("Gloss",Range(1,256)) = 20
		_LightCol("LightColor",Color) = (1,1,1,1)
		_RippleDensity("Ripple Density",float) = 1
		_AccumulateWater("AccumulateWater",Range(0,1)) = 0
		_BrickF0("_BrickF0",float) = 0.04
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
			sampler2D _MaskTex;
			samplerCUBE _CubeMap;
			uniform float4 _LightPos;
			float _Gloss;
			float4 _LightCol;
			float _RippleDensity;
			float _AccumulateWater;
			float _BrickF0;
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
			void DoWetShading(inout float3 albedo, inout float gloss,float wetLevel)
			{
				// 越潮湿，地面越暗
				albedo *= lerp(1.0,0.3, wetLevel);
				//越潮湿，gloss越大，镜面反射更明亮，高光凝聚度更高。
				gloss = min(gloss * lerp(1.0,3,wetLevel),1.0);
			}
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				float mask = 1 - tex2D(_MaskTex,i.uv).r;
				float glossParam = 1.0 - mask;// 中间是水坑，gloss中间最大，边缘最小
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
				
				DoWetShading(col.rgb, glossParam,_AccumulateWater);
				glossParam = lerp(glossParam, 1.0, _AccumulateWater);
				
				float3 halfDir = normalize(lightDir + viewDir);
				float3 dotNH = max(0,dot(normal,halfDir));
				float3 dotNL = max(0,dot(normal,lightDir));
				float dotNV = saturate(dot(normal,viewDir));
				// diffuse
				float3 diffuse = _LightCol.rgb * col.rgb* dotNL;
				//specular 【0-1024】
				float  specPower = exp2(glossParam * 8);

				// frensel
				float f0 = lerp(_BrickF0,0.02,_AccumulateWater);
				float frensel = f0 + (1 - f0) * pow((1 - dotNV),5);
				//比起bllin-phong.乘了dotNL，高光颜色在眼睛与水面平行时，变暗。
				float3 specular = frensel * ((specPower + 2.0) / 8.0)* pow(dotNH,specPower) * dotNL;
				// reflection
				float3 reflection = reflect(viewDir,normal);
				float3 reflCol = texCUBE(_CubeMap,reflection) * glossParam;
				
				float3 ambient =reflCol * 0.2f;
				
				return float4(diffuse+specular+ambient,1.0f);
			}
			ENDCG
		}
	}
}
