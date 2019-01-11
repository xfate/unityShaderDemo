Shader "xjm/ripple"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RainIntensity("Rain Instensity",float) = 1
		_RainTime("Rain Time",Vector) = (0,0,0,0)
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		//LOD 100
	ZTest Always Cull Off ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#define PI 3.141592653
			float _RainIntensity;
			float4 _RainTime;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//ripple.x r通道:圆中间是1，渐变到0的圆。
			// ripple.yz 是圆心的方向
			float3 ComputeRipple(float2 uv, float currentTime, float weight)
			{
				float4 ripple = tex2D(_MainTex,uv);
				//gb 通道从[0,1]变成[-1,1]
				ripple.yz = ripple.yz * 2.0 - 1.0;
				//rippleTex的w通道（Alpha通道）圆圈外面都是0
				//加上时间偏移。dropFrac 限制在[0,1)
				float dropFrac = frac(ripple.w +currentTime);
				//timeFrac限制在[-1,1],dropFrac - 1.0,可以确保圆圈的外面(ripple.x=0),timeFrac<=0.
				//从而波纹外面的法线是垂直的。也就是水平的。
				float timeFrac = dropFrac - 1.0 + ripple.x;
				// 波纹随着时间扩大(dropFrac 变大)，dropFator越小，波纹慢慢变平
				float dropFator = saturate(0.2 + weight * 0.8 - dropFrac);
				//从波纹出现开始，时间越大(dropFrac 变大)，dropFator 越小，final 越小，波纹越平。
				//sin(clamp(timeFrac * 9.0,0.0,3.0)*PI)：0-3*PI之间，sin就是一个波峰-波谷-波峰的函数图像，
				//在0-3*PI之外sin函数皆为0.9.0是一个把timeFrac参数放大的因子。
				//波纹圈内的值，比如波纹中心值，经过sin函数的计算，变成0.也就是说波纹中心点也是平的。这个平的区域，
				// 随着时间变大，慢慢扩大，（时间越大，只有红色通道部分越小的地方(红色通道ripple.x渐变到0)，
				//sin函数才不为0.所有波纹就会有慢慢变大的效果
				float final = dropFator * ripple.x * sin(clamp(timeFrac * 9.0,0.0,3.0)*PI);
				return float3(ripple.yz * final * 0.35,1.0);

			}
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
					float4 weight = _RainIntensity.xxxx - float4(0, 0.25, 0.5, 0.75);
			weight = saturate(weight * 4);   
   			//几个ripple的混合
			float3 ripple1 = ComputeRipple(i.uv + float2( 0.25f,0.0f), _RainTime.x, weight.x);
			float3 ripple2 = ComputeRipple(i.uv + float2(-0.55f,0.3f), _RainTime.y, weight.y);
			float3 ripple3 = ComputeRipple(i.uv + float2(0.6f, 0.85f), _RainTime.z, weight.z);
			float3 ripple4 = ComputeRipple(i.uv + float2(0.5f,-0.75f), _RainTime.w, weight.w);
		
			float4 Z = lerp(1, float4(ripple1.z, ripple2.z, ripple3.z, ripple4.z), weight);
			float3 N = float3(
				weight.x * ripple1.xy +
				weight.y * ripple2.xy + 
				weight.z * ripple3.xy + 
				weight.w * ripple4.xy, 
				Z.x * Z.y * Z.z * Z.w);
				//[-1,1]->[0,1]
			return float4(normalize(N) * 0.5 + 0.5, 1.0); 
				///return float4(ripple1.xyz,1.0);
			}
			ENDCG
		}
	}
}
