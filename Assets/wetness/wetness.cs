﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
namespace Assets.wetness
{
    public class Wetness : MonoBehaviour
    {
        public float rainIntensity  = 1.0f;
        RenderTexture ripple;
        public Material mat;
        public Material RainDropMat;
        Texture2D rainDropMap;
        public GameObject terrain;
        private void Start()
        {
            ripple = new RenderTexture(512, 512, 24);
            ripple.name = "ripple";
            ripple.wrapMode = TextureWrapMode.Repeat;
        }
        Vector4 vec = new Vector4(1, 0.8f, 0.9f, 1.13f);
        Vector4 Frac(Vector4 v)
        {
            return new Vector4((float)v.x - (int)v.x,
                (float)v.y - (int)v.y,
            (float)v.z - (int)v.z,(float)v.w - (int)v.w);
        }
        private void Update()
        {
            if (mat != null)
            {
                Vector4 t = Frac(Time.time * vec);
                mat.SetFloat("_RainIntensity", rainIntensity);
                mat.SetVector("_RainTime", t);
                Graphics.Blit(rainDropMap, ripple, RainDropMat);
                Renderer rd = terrain.GetComponent<Renderer>();
                rd.material.SetTexture("_RippleTex", ripple);
                
            }
        }
    }
}