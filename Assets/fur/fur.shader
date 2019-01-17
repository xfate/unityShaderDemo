// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "xjm/furShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FurLength("Fur Length", Range(0.0, 1)) = 0.5
		_FurTex("Fur Texture",2D)=""{}
		_Thinkness("Thinkness",float) = 1
		_Gravity ("Gravity",Vector)=(0,0,0,0)
		_FurDensity("Fur Density",float)=1
	}
	    Category
    {
	
	//ENDCG
	SubShader
	{
			Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass //0
		{
			CGPROGRAM
			
			#pragma vertex vert_base
			#pragma fragment frag_base
			#define FURSTEP 0
			#include "fur.cginc"
			ENDCG
		}
		Pass //1
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.05
			#include "fur.cginc"
			ENDCG
		}
		Pass //2
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.1
			#include "fur.cginc"
			ENDCG
		}
		Pass //3
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.15
			#include "fur.cginc"
			ENDCG
		}
		
		Pass //4
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.2
			#include "fur.cginc"
			ENDCG
		}
		Pass //5
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.25
			#include "fur.cginc"
			ENDCG
		}
				Pass //1
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.3
			#include "fur.cginc"
			ENDCG
		}
		Pass //2
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.35
			#include "fur.cginc"
			ENDCG
		}
		Pass //3
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.4
			#include "fur.cginc"
			ENDCG
		}
		
		Pass //4
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.45
			#include "fur.cginc"
			ENDCG
		}
		Pass //5
		{
			CGPROGRAM
			
			#pragma vertex vert_fur
			#pragma fragment frag_fur
			#define FURSTEP 0.5
			#include "fur.cginc"
			ENDCG
		}
	}
	}
}
