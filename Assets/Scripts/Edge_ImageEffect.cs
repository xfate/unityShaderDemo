using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Edge_ImageEffect : ImageEffectBase {

    [Range(0,3.0f)]
    public float edgeOnly = 1.0f;
    public Color edgeColor;
    public Color edgeBKColor;

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
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_backGroundColor", edgeBKColor);
            Graphics.Blit(src, dst, material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
	}
}
