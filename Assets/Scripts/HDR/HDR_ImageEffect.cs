using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HDR_ImageEffect : ImageEffectBase {
    public enum BloomType
    {
        AlphaGloss = 0,
        Threshhold = 1,
    }

    public enum Resolution
    {
        Low = 0,
        High = 1,
    }

    public enum BlurType
    {
        Standard = 0,
        Sgx = 1,
    }

 
    [Range(0.0f, 1.5f)]
    public float threshhold = 0.25f;

    [Range(0.0f, 3.0f)]
    public float intensity = 1.0f;

    [Range(0.25f, 5.0f)]
    public float blurSize = 2.0f;

    [Range(1, 2)]
    public int blurIterations = 1;

    [Range(0, 3.0f)]
    public float contrastAmount = 1.05f;

    public BloomType bloomType = BloomType.Threshhold;
    public Resolution resolution = Resolution.Low;
    public BlurType blurType = BlurType.Standard;

    [Range(0,3.0f)]
    public float _Exposure = 1.0f;
    [Range(0, 3.0f)]
    public float _Luminance = 1.0f;
    [Range(0, 3.0f)]
    public float contrast = 1.0f;
    public int downsampler = 2;
    public Shader shader;
    public Material m_mat;
    bool bHdr = false;
    public Material material
    {
        get
        {
            if (m_mat != null)
                return m_mat;
            if (shader == null)
                shader = Shader.Find("xjm/Post/MobileBloom");
            m_mat = CheckShaderAndCreateMaterial(shader, m_mat);
            return m_mat;
        }
    }
	
	
	// Update is called once per frame
	void OnRenderImage (RenderTexture src, RenderTexture dst)
    {
        
        float widthMod = resolution == Resolution.Low ? 0.5f : 1.0f;

        material.SetVector("_Parameter", new Vector4(blurSize * widthMod, 0.0f, threshhold, intensity));
        src.filterMode = FilterMode.Bilinear;

        if (bloomType == BloomType.AlphaGloss)
        {
            if (!material.IsKeywordEnabled("_ALPHA_GLOSS_ON"))
                material.EnableKeyword("_ALPHA_GLOSS_ON");
        }
        else
        {
            if (material.IsKeywordEnabled("_ALPHA_GLOSS_ON"))
                material.DisableKeyword("_ALPHA_GLOSS_ON");
        }

        int divider = resolution == Resolution.Low ? 4 : 2;
        var rtW = src.width / divider;
        var rtH = src.height / divider;
        
        RenderTexture rt = null;
        // downsample
        if (GetComponent<Camera>().allowHDR)
            rt = RenderTexture.GetTemporary(rtW, rtH, 0);
        else
            rt = RenderTexture.GetTemporary(rtW, rtH, 0);
        rt.filterMode = FilterMode.Bilinear;
        Graphics.Blit(src, rt, material, 1);

        // blur
        var passOffs = blurType == BlurType.Standard ? 0 : 2;
        for (int i = 0; i < blurIterations; ++i)
        {
            material.SetVector("_Parameter", new Vector4(blurSize * widthMod + (i * 1.0f), 0.0f, threshhold, intensity));

            // vertical blur
            RenderTexture rt2 = RenderTexture.GetTemporary(rtW, rtH, 0, rt.format);
            rt2.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt, rt2, material, 2 + passOffs);
            RenderTexture.ReleaseTemporary(rt);
            rt = rt2;

            // horizontal blur
            rt2 = RenderTexture.GetTemporary(rtW, rtH, 0, rt.format);
            rt2.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt, rt2, material, 3 + passOffs);
            RenderTexture.ReleaseTemporary(rt);
            rt = rt2;
        }

        // contrast
        material.SetFloat("_conAmount", contrastAmount);

        material.SetTexture("_Bloom", rt);
        if (GetComponent<Camera>().allowHDR)
            rt = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBHalf);
        else
            rt = RenderTexture.GetTemporary(src.width, src.height, 0);
        rt.filterMode = FilterMode.Bilinear;
        Graphics.Blit(src, rt, material, 0);

     
        material.SetFloat("_Exposure", _Exposure);
        Graphics.Blit(rt, dst, material, 6);

        RenderTexture.ReleaseTemporary(rt);
    }


}
