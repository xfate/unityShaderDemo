//CGINCLUDE

		#pragma target 3.0

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
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
				float3 normal:NORMAL0;
				float3 lightDir:TEXCOORD1;
				float4 uv_fur:TEXCOORD2;
				
			};
           
			sampler2D _MainTex;
			float4 _MainTex_ST;
            sampler2D _FurTex;
            fixed _FurLength;
            float _Thinkness;
			float3 _Gravity;
			float _FurDensity;
            v2f vert_base (appdata v)
			{
				v2f o;
				float3 newPos = v.vertex.xyz + v.normal *_FurLength*  FURSTEP;
				o.vertex = UnityObjectToClipPos(float4(newPos,1.0f));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(v.normal,(float3x3)unity_WorldToObject);
			
				return o;
			}
			
			fixed4 frag_base (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0);
				fixed3 diffuse = _LightColor0.rgb*col.rgb * max(0,dot(normalize(i.normal),lightDir));
             //   float alpha = clamp(furAlpha - FURSTEP * FURSTEP,0,1);
				return float4(col.rgb+diffuse,1);
			}
            v2f vert_shadow (appdata v)
			{
				v2f o;
				float3 newPos = v.vertex.xyz + v.normal *_FurLength*  FURSTEP;
				o.vertex = UnityObjectToClipPos(float4(newPos,1.0f));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(v.normal,(float3x3)unity_WorldToObject);
		
				return o;
			}
			
			fixed4 frag_shadow (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0);
				fixed3 diffuse = _LightColor0.rgb*col.rgb * max(0,dot(normalize(i.normal),lightDir));
             //   float alpha = clamp(furAlpha - FURSTEP * FURSTEP,0,1);
				return float4(col.rgb+diffuse,1);
			}

			v2f vert_fur (appdata v)
			{
				v2f o;
				float3 newPos = v.vertex.xyz + v.normal *_FurLength*  FURSTEP;
				//float3 gravity = mul(unity_ObjectToWorld,_Gravity);
				float k = pow(FURSTEP,3);
				newPos = newPos + _Gravity *k;
				o.vertex = UnityObjectToClipPos(float4(newPos,1.0f));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = mul(v.normal,(float3x3)unity_WorldToObject);
				
				return o;
			}
			
			fixed4 frag_fur (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col -= (pow(1-FURSTEP, 3))*0.05;
				fixed3 lightDir = normalize(_WorldSpaceLightPos0);
                float furAlpha = tex2D(_FurTex,i.uv * _Thinkness).rgb;
				fixed3 diffuse = _LightColor0.rgb*col.rgb * max(0,dot(normalize(i.normal),lightDir));
                float alpha =  clamp(furAlpha - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);
				return float4(col.rgb+diffuse,alpha);
			}

