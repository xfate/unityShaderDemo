Shader "xjm/ShadowMap/DepthTextureShader"
{
SubShader{
    Tags {"RenderType"="Opaque"}
    Pass
    {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        struct a2v
        {
            float4 vertex:POSITION;
        };
        struct v2f
        {
            float4 vertex :SV_POSITION;
            float2 depth :TEXCOORD0;
        };
        v2f vert(a2v i)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(i.vertex);
            o.depth = o.vertex.zw;
            return o;
        }
        fixed4 frag(v2f i):SV_Target
        {
            float depth = i.depth.x /i.depth.y;
            fixed4 col = EncodeFloatRGBA(depth);
            return col;
        }
        ENDCG
    }
}
}