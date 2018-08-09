using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class Outline_CommandBuffer : ImageEffectBase
{
    private RenderTexture m_renderTexture;
    private Camera m_mainCamera;
    public Shader m_outlineShader;
    [Range(1, 8)]
    public int m_downSampler;

    private Material m_outlineMat;
    public Shader m_outlinePreShader;
    private Material m_outlinePreMat;
    [Range(0, 2)]
    public int blurIterator;
    public float blurSize = 1.0f;
    public Color outlineColor;
    public bool hardSide = false;
    public bool onlyShowBlur = false;
    private CommandBuffer m_commandBuffer;
    public Renderer[] Renderers;
    public Material outlineMaterial
    {
        get
        {
            m_outlineMat = CheckShaderAndCreateMaterial(m_outlineShader, m_outlineMat);
            return m_outlineMat;
        }
    }
    public Material outlinePreMaterial
    {
        get
        {
            m_outlinePreMat = CheckShaderAndCreateMaterial(m_outlinePreShader, m_outlinePreMat);
            return m_outlinePreMat;
        }
    }
    private void OnEnable()
    {
  
        m_commandBuffer = new CommandBuffer();
        if (m_renderTexture == null)
            m_renderTexture = RenderTexture.GetTemporary(Screen.width >> m_downSampler, Screen.height >> m_downSampler, 0);
        m_commandBuffer.SetRenderTarget(m_renderTexture);
        m_commandBuffer.ClearRenderTarget(true, true, Color.black);
        foreach (var renderer in Renderers)
        {
            m_commandBuffer.DrawRenderer(renderer, outlinePreMaterial);
        }
    }
    private void OnDisable()
    {
    
    }
    private void OnDestroy()
    {
        
        if (m_renderTexture)
        {
            RenderTexture.ReleaseTemporary(m_renderTexture);
            RenderTexture.DestroyImmediate(m_renderTexture);
        }
        if (m_commandBuffer != null)
        {
            m_commandBuffer.Release();
            m_commandBuffer = null;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int rtW = source.width >> m_downSampler;
        int rtH = source.height >> m_downSampler;

        // 插入commandbuffer，绘制出纯色的图片
        m_outlinePreMat.SetColor("_OutlineColor", outlineColor);
        Graphics.ExecuteCommandBuffer(m_commandBuffer);
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 16);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 16);
        Graphics.Blit(m_renderTexture, temp1, outlineMaterial, 0);
        Graphics.Blit(temp1, temp2, outlineMaterial, 1);
        for (int i = 0; i < blurIterator; ++i)
        {
            Graphics.Blit(temp2, temp1, outlineMaterial, 0);
            Graphics.Blit(temp1, temp2, outlineMaterial, 1);
        }
        if (onlyShowBlur)
        {
            Graphics.Blit(temp2, destination);
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
            return;
        }
        //add
        //把模糊的边框加到原来的照片中
        if (hardSide)
        {
            outlineMaterial.EnableKeyword("_Hard_Side");
            outlineMaterial.SetColor("_OutlineColor", outlineColor);
        }
        else
        {
            outlineMaterial.DisableKeyword("_Hard_Side");
        }
        outlineMaterial.SetTexture("_BlurTex", temp2);
        outlineMaterial.SetTexture("_SrcTex", m_renderTexture);
        outlineMaterial.SetFloat("_BlurSize", blurSize);
        Graphics.Blit(source, destination, outlineMaterial, 2);
        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}