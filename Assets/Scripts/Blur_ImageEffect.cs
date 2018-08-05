using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blur_ImageEffect: ImageEffectBase {

    [Range(1, 2)]
    public int blurIterations = 1;
    public float blurSize = 1;
    public int downsampler = 2;
    public Shader shader;
    private Material m_mat;
    public Material material
    {
        get
        {
            m_mat = CheckShaderAndCreateMaterial(shader, m_mat);
            return m_mat;
        }
    }
	
	
	// Update is called once per frame
	void OnRenderImage (RenderTexture src, RenderTexture dst)
    {
        var rtW = src.width >> downsampler;
        var rtH = src.height >> downsampler;
        material.SetFloat("_BlurSize", blurSize);
        RenderTexture rt = RenderTexture.GetTemporary(rtW, rtH, 0, src.format);
        RenderTexture rt2 = RenderTexture.GetTemporary(rtW, rtH, 0, src.format);
        rt2.filterMode = FilterMode.Bilinear;
        rt.filterMode = FilterMode.Bilinear;
        Graphics.Blit(src, rt);// 降低采样

        // blur
        for (int i = 0; i < blurIterations; ++i)
        {
            // vertical blur
            Graphics.Blit(rt, rt2, material, 0);
            // horizontal blur
            Graphics.Blit(rt2, rt, material, 1);

        }
        Graphics.Blit(rt, dst);

        RenderTexture.ReleaseTemporary(rt);
        RenderTexture.ReleaseTemporary(rt2);

    }
    
}
