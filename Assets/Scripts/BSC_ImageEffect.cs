using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BSC_ImageEffect : ImageEffectBase {

    [Range(0,3.0f)]
    public float brightness = 1.0f;
    [Range(0, 3.0f)]
    public float saturation = 1.0f;
    [Range(0, 3.0f)]
    public float contrast = 1.0f;

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
		if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
            Graphics.Blit(src, dst, material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
	}
}
