using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DOF_CommandBuffer : MonoBehaviour {
    public Renderer targetRenderer;
    private CommandBuffer m_CommandBuffer;
    public Material m_mat;
    public Camera m_cam;
    private void OnEnable()
    {
        m_CommandBuffer = new CommandBuffer();
        m_CommandBuffer.DrawRenderer(targetRenderer, m_mat,0,0);
        // 放在后处理完之后再渲染
        m_cam.AddCommandBuffer(CameraEvent.AfterImageEffects, m_CommandBuffer);
        targetRenderer.enabled = false;
    }
    private void OnDisable()
    {
        //移除command buffer
        m_cam.RemoveCommandBuffer(CameraEvent.AfterImageEffects, m_CommandBuffer);
        m_CommandBuffer.Clear();
        targetRenderer.enabled = true;
    }
}
