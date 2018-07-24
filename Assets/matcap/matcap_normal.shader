Shader "xjm/matcap_normal"
{
	Properties
	{
		_MatCap ("Mat Cap",2D) = "white" {}
		_MainColor("Main Color",color) = (1,1,1,1)
		_MainTex("Main Tex",2D)=""{}
		_NormalMap("Normal Map",2D)=""{}
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
			fixed4 _MainColor;

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
                fixed3 worldNormView = normalize(mul((float3x3)UNITY_MATRIX_V,worldNorm));
				worldNormView.xy  = worldNormView.xy * 0.5 + 0.5;
				fixed4 matcapcolor = tex2D(_MatCap,worldNormView);
				return mainTexColor *matcapcolor*_MainColor*2;
           
			   
			}
			ENDCG
		}
	}
}