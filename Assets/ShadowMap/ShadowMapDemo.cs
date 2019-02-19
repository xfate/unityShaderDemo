using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowMapDemo : MonoBehaviour {
    public Camera mCam;
    public Shader mSampleDepthShader;
	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
        if (mCam == null)
            return;
	}
}
