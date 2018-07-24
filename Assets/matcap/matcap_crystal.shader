Shader "xjm/matcap_crystal"
{
	Properties
	{
		_MatCap ("反射贴图",2D) = "white" {}
		_MainColor("Main Color",color) = (1,1,1,1)
		_MainTex("Main Tex",2D)=""{}
		_NormalMap("Normal Map",2D)=""{}
		_RefractMatCap ("Refract Cap",2D) = "white" {}
		_FrenselScale("Frensel Scale",Range(0,1)) = 0.5
		_RefractRatio("折射系数",float) = 1
		_RefractColor("折射颜色",Color) = (0.5,0.5,0.5,1)
		_reflRatio("反射系数",float) = 0.4
		_ReflColor("反射颜色",Color) = (0.5,0.5,0.5,1)

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
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent :TANGENT;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 TtoW1:TECOORD1;
				float4 TtoW2:TECOORD2;
				float4 TtoW3:TECOORD3;
			};
			sampler2D _MatCap;
			sampler2D _MainTex;
			sampler2D _NormalMap;
			sampler2D _RefractMatCap;
			float _FrenselScale;
			fixed4 _MainColor;
			float _RefractRatio;
			float4 _RefractColor;
			float4 _ReflColor;
			float _reflRatio;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldNorm = normalize(mul(float4(v.normal,0.0f),unity_WorldToObject));
				float3 worldTangent = mul(unity_ObjectToWorld,v.tangent);
                float3 worldBinormal = cross(worldNorm,worldTangent)*v.tangent.w;
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.TtoW1 = float4(worldTangent.x,worldBinormal.x,worldNorm.x,worldPos.x);
                o.TtoW2 = float4(worldTangent.y,worldBinormal.y,worldNorm.y,worldPos.y);
                o.TtoW3 = float4(worldTangent.z,worldBinormal.z,worldNorm.z,worldPos.z);

				worldNorm = mul((float3x3)UNITY_MATRIX_V,worldNorm);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
 				fixed4 mainTexColor = tex2D(_MainTex,i.uv);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap,i.uv));
                float3 worldNorm;
                worldNorm.x = dot(i.TtoW1.xyz,normal);
                worldNorm.y = dot(i.TtoW2.xyz,normal);
                worldNorm.z = dot(i.TtoW3.xyz,normal);
				half3 worldPos = half3(i.TtoW1.w,i.TtoW2.w,i.TtoW3.w);
				fixed3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
                fixed3 worldNormView = normalize(mul((float3x3)UNITY_MATRIX_V,worldNorm));
				worldNormView.xy  = worldNormView.xy * 0.5 + 0.5;

				//反射
				float3 reflectDir = reflect(-worldViewDir,worldNorm);
				float2 reflectuv =  normalize(mul((float3x3)UNITY_MATRIX_V,reflectDir));
				reflectuv = reflectuv.xy * _reflRatio + 0.5;
				fixed4 reflectColor = tex2D(_MatCap,reflectuv.xy)*_ReflColor;
				//折射
				fixed3 worldRefr = refract(-normalize(worldViewDir), normalize(worldNorm), 0.75f);
				float2 refractuv =  normalize(mul((float3x3)UNITY_MATRIX_V,worldRefr));
				refractuv = refractuv.xy * _RefractRatio + 0.5;
				fixed4 refractColor = tex2D(_RefractMatCap,refractuv.xy)*_RefractColor;

		
				//fixed frensel = _FrenselScale + (1 - _FrenselScale) * pow(1 - dot(worldViewDir,worldNorm),5);
				fixed4 diffuse = mainTexColor*_MainColor;
				return diffuse + lerp(reflectColor ,refractColor,_FrenselScale);
              //  return lerp(float4(worldRefr,1.0f)*matcapColor,matcapColor*diffuse*2,saturate(frensel));
			   
			}
			ENDCG
		}
	}
}