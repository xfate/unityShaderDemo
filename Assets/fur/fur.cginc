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
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal:NORMAL0;
				float3 lightDir:TEXCOORD1;				
			};
           
			sampler2D _MainTex;
			float4 _MainTex_ST;
            sampler2D _FurTex;
            fixed _FurLength;
            float _Thinkness;
			float3 _Gravity;
			float _FurDensity;
			float _FurShader;
            v2f vert_base (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;
				o.normal = mul(v.normal,(float3x3)unity_WorldToObject);
				
				return o;
			}
			
			fixed4 frag_base (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy);
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
				//加入毛发阴影，越是中心位置，阴影越明显，边缘位置阴影越浅
				float znormal = 1 - dot(v.normal,float3(0,0,1));
				o.uv.xy = v.uv ;
				o.uv.zw = float2(znormal,znormal)*0.001;
				o.normal = mul(v.normal,(float3x3)unity_WorldToObject);
				
				return o;
			}
			
			fixed4 frag_fur (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy);
			
			
				//增加毛发阴影，毛发越靠近根部的像素点颜色越暗
				//col.rgb-= (pow(1-FURSTEP, 3))*_FurShader;
				
				fixed3 lightDir = normalize(_WorldSpaceLightPos0);
				//_Thinkness 毛发细度，改变tile增强毛发细度
                float4 furCol = tex2D(_FurTex,i.uv.xy* _Thinkness);
				fixed4 ColOffset = tex2D(_FurTex, i.uv.xy*_Thinkness+i.uv.zw );
				float3 final = dot(float3(0.299,0.587,0.114) ,col.rgb - ColOffset.rgb);
				col.rgb-=final*_FurShader;
		
				fixed3 diffuse = _LightColor0.rgb*col.rgb * max(0,dot(normalize(i.normal),lightDir));
                float alpha =  clamp(furCol.r - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);
    	
    			return float4(col.rgb+diffuse,alpha);
			}
 

