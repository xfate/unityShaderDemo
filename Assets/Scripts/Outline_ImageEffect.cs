using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Outline_ImageEffect : ImageEffectBase
{
    private RenderTexture m_renderTexture;
    private Camera m_mainCamera;
    private Camera m_outlineCamera;
    public Shader m_outlineShader;
    [Range(1, 8)]
    public int m_downSampler;

    private Material m_outlineMat;
    public Shader m_outlinePreShader;
    [Range(1, 2)]
    public int blurIterator;
    public Color outlineColor;

    public Material outlineMaterial
    {
        get
        {
            m_outlineMat = CheckShaderAndCreateMaterial(m_outlineShader, m_outlineMat);
            return m_outlineMat;
        }
    }

    private void AddOutlineCamera()
    {
        m_mainCamera = GetComponent<Camera>();
        if (m_outlineCamera != null)
        {
            GameObject.DestroyImmediate(m_outlineCamera);
            m_outlineCamera = null;
        }
        m_outlineCamera = new GameObject("outlineCamera").AddComponent<Camera>();
        SetOutlineCamera();

    }
    private void SetOutlineCamera()
    {
        if (m_outlineCamera)
        {
            m_outlineCamera.transform.SetParent(m_mainCamera.transform, false);
            m_outlineCamera.farClipPlane = m_mainCamera.farClipPlane;
            m_outlineCamera.nearClipPlane = m_mainCamera.nearClipPlane;
            m_outlineCamera.fieldOfView = m_mainCamera.fieldOfView;
            m_outlineCamera.backgroundColor = Color.clear;
            m_outlineCamera.clearFlags = CameraClearFlags.Color;
            m_outlineCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");

            m_outlineCamera.depth = -999;
            if (!m_renderTexture)
            {
                int width = m_outlineCamera.pixelWidth >> m_downSampler;
                int height = m_outlineCamera.pixelHeight >> m_downSampler;
                m_renderTexture = RenderTexture.GetTemporary(width, height, 24);
            }
        }
    }
    private void Awake()
    {
        AddOutlineCamera();
    }
    private void OnEnable()
    {
        SetOutlineCamera();
        m_outlineCamera.enabled = true;
    }
    private void OnDisable()
    {
        m_outlineCamera.enabled = false;
    }
    private void OnDestroy()
    {
        if (m_outlineCamera != null)
        {
            GameObject.DestroyImmediate(m_outlineCamera);
            m_outlineCamera = null;
        }
        if (m_renderTexture)
        {
            RenderTexture.ReleaseTemporary(m_renderTexture);
            RenderTexture.DestroyImmediate(m_renderTexture);
        }
        
    }

    private void OnPreRender()
    {
        //先渲染到RT
        if (m_outlineCamera.enabled)
        {
            m_outlineCamera.targetTexture = m_renderTexture;
            m_outlineCamera.RenderWithShader(m_outlinePreShader, "");//渲染了一张纯色RT
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int rtW = source.width >> m_downSampler;
        int rtH = source.height >> m_downSampler;
        var temp1 = RenderTexture.GetTemporary(rtW, rtH, 24);
        var temp2 = RenderTexture.GetTemporary(rtW, rtH, 24);
        // 先模糊纯色的图片
        Graphics.Blit(m_renderTexture, temp1);
        for (int i = 0; i < blurIterator; ++i)
        {
            Graphics.Blit(temp1, temp2, outlineMaterial, 0);
            Graphics.Blit(temp2, temp1, outlineMaterial, 1);
        }
        //add
        //把模糊的边框加到原来的照片中
        outlineMaterial.SetTexture("_BlurTex", temp2);
        outlineMaterial.SetTexture("_OriTex", m_renderTexture);
        outlineMaterial.SetColor("_OutlineColor", outlineColor);
        Graphics.Blit(source, destination, outlineMaterial, 2);
        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
    
}
