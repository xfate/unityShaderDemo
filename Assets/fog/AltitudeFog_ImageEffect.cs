using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AltitudeFog_ImageEffect : MonoBehaviour {

	// Use this for initialization
	void Start () {
        //输出深度图
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
	}
	
	void OnRenderImage(RenderTexture source,RenderTexture destination)
    {

    }
}
