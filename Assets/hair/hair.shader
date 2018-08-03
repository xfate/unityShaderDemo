Shader "xjm/hair"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("Normal Map",2D) = ""{}
		_MainColor("MainColor",Color) = (1,1,1,1)
		_tSpecShift("tangent shift",2D) = ""{}
		_PrimaryShift ( "Specular Primary Shift", float) = 0.0
		_SecondaryShift ( "Specular Secondary Shift", float) = .7
		_specExp1 ( "_specExp1", float) =100
		_specExp2 ( "_specExp2", float) =100
		_specularColor1( "_specularColor1", Color) =(1,1,1,1)
		_specularColor2( "_specularColor2", Color) = (1,1,1,1)
		_specular ("Specular Amount", Range(0, 5)) = 1.0 

	}
	SubShader
	{
	
		LOD 100
   		Tags{"LightMode"="ForwardBase"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;

				float4 vertex : SV_POSITION;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			sampler2D _tSpecShift;
			float _PrimaryShift;
			float _SecondaryShift;
			float4 _MainColor;
			float _specExp1;
			float _specExp2;
			float4 _specularColor1;
			float4 _specularColor2;
			half _specular;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				float3 worldNormal  = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent =UnityObjectToWorldDir(v.tangent.xyz);  
				float3 worldBinoraml = cross(worldNormal,worldTangent).xyz * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x,worldBinoraml.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinoraml.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinoraml.z,worldNormal.z,worldPos.z);
		
				return o;
			}
			//高光偏移
			fixed3 ShiftTangent(float3 tangent,float3 normal,float shift)
			{
				return normalize(tangent + shift * normal);
			}
			fixed StrandSpecular(fixed3 T,fixed3 V,fixed3 L,fixed exponent)
			{
				float3 H = normalize(L+V);
				float dotTH = dot(T,H);
				float sinTH = sqrt(1- dotTH * dotTH);
				float dirAtten = smoothstep(-1,0,dotTH);	
				return dirAtten*pow(sinTH,exponent);
			}
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 tNormal  = UnpackNormal(tex2D(_NormalMap,i.uv));
				fixed3 worldBinormal = normalize(half3(i.TtoW0.y, i.TtoW1.y, i.TtoW2.y));	
				float3x3 matT2W = float3x3(i.TtoW0.xyz,i.TtoW1.xyz,i.TtoW2.xyz);
				float3 normal = normalize(mul(matT2W,tNormal));
				//tNormal.xy = tex2D(_NormalMap,i.uv).xy*2-1;
				//tNormal.z = sqrt(1- saturate(dot(tNormal.xy,tNormal.xy)));
				float4 mainTex =  tex2D(_MainTex,i.uv);

				float3 tangent = float3(i.TtoW0.x,i.TtoW1.x,i.TtoW2.x);
				float shiftTex = tex2D(_tSpecShift,i.uv).r;
				float3 t1 = ShiftTangent(-worldBinormal,normal,_PrimaryShift+shiftTex);
				float3 t2 = ShiftTangent(worldBinormal,normal,_SecondaryShift+shiftTex);
				float3 diffuse = mainTex.rgb* _MainColor.rgb;
				half3 spec1 = StrandSpecular(t1, viewDir, lightDir, _specExp1)* _specularColor1;
				half3 spec2 = StrandSpecular(t2, viewDir, lightDir, _specExp2)* _specularColor2;

				float3 specular = spec1*_specular;
				//float3 specMask = tex2D(tSpecMask,i.uv);
				specular += spec2*_specularColor2*_specular;
				

				// sample the texture
				float4 o;
				o.rgb =diffuse + specular;
				o.a = mainTex.a;
			
				return o;
			}
			ENDCG
		}
	}
}
