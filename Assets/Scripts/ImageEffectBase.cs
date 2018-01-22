using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ImageEffectBase : MonoBehaviour {

    // Use this for initialization
    void Start() {
        CheckResource();

    }

    // Update is called once per frame
    void Update() {

    }

    protected bool CheckSupport()
    {
        return true;
    }
    protected void CheckResource()
    {
        bool isSupport = CheckSupport();
        if (!isSupport)
        {
            enabled = false;
        }
    }
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material mat)
    {
        if (shader == null  || !shader.isSupported)
            return null;
        if (shader.isSupported && mat && mat.shader == shader)
            return mat;
        else
        {
            var material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            return material;
        }

    }

}
