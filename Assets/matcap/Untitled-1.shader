Shader "Custom/Role/Role_SH"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv)
#pragma exclude_renderers d3d11
            #pragma fragment frag
            #pragma vertex vert
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  ：TEXCOORD0;
                fixed3 vlight : TEXCOORD1;
            };
            v2f vert(appdata_tan v)
            {
                v2f o;
                o.pos = mul(UNITY_NATRIX_MVP,v.vertex);
                o.uv = v.texcoord;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                #if UNITY_SHOULD_SAMPLE_SH
                    float shlight = ShadeSH9(float4(worldNormal,1.0f));
                    o.vlight = shlight;
                #else
                    o.vlight = 0.0f;
            }

            fixed4 frag(v2f v)
            {
                fixed4 col;
                col = tex2D(_MainTex,v.uv);
                col *= v.vlight;
            }

            ENDCG
        }
    }
}