using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Outline_ImageEffect : ImageEffectBase
{
    private RenderTexture m_renderTexture;
    private Camera m_mainCamera;
    private Camera m_outlineCamera;
    public Shader m_outlineShader;
    public int m_downSampler;
    private void AddOutlineCamera()
    {
        m_mainCamera = GetComponent<Camera>();
        if (m_outlineCamera != null)
        {
            GameObject.DestroyImmediate(m_outlineCamera);
            m_outlineCamera = null;
        }
        m_outlineCamera = new GameObject("outlineCamera").AddComponent<Camera>();

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
            m_outlineCamera.cullingMask = 1 << LayerMask.NameToLayer("Actor");

            if (!m_renderTexture)
            {
                int width = m_outlineCamera.pixelWidth >> m_downSampler;
                int height = m_outlineCamera.pixelHeight >> m_downSampler;
                m_renderTexture = RenderTexture.GetTemporary(width, height);
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
            RenderTexture.Destroy(m_renderTexture);
        }
        
    }

    private void OnPreRender()
    {
        //先渲染到RT
        if (m_outlineCamera.enabled)
        {
            m_outlineCamera.targetTexture = m_renderTexture;
            m_outlineCamera.RenderWithShader(m_outlineShader, "");
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
       // var tmp1 = RenderTexture.GetTemporary(Screen)
    }
    
}
