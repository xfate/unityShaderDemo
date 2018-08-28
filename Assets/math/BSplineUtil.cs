using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BSplineUtil
{
    public enum eBSPLINE_TYPE
    {
        eClamped = 0,
        eOpened = 1,
    }
     
    public static Vector3 DeBoor(int j, int k,int i, float t,List<Vector3> controlPoints,float[] knots)
    {
        if (j == 0)
        {
            return controlPoints[i];
        }
        else
        {
            float param = 0.0f;
            float sub = (knots[i + k + 1 - j] - knots[i]);
            if (sub != 0)
            {
                param = (t - knots[i]) / sub;
            }
            else
            {
                param = 0.0f;
            }
           
            return ((1-param) * DeBoor(j - 1, k, i - 1, t, controlPoints, knots)
                + param * DeBoor(j - 1, k, i, t, controlPoints, knots)); 
        }
    }

    public static List<Vector3> GetBspline(List<Vector3> controlPoints,int detail, eBSPLINE_TYPE type,int degree = -1)
    {
        List<Vector3> points = new List<Vector3>();
        if (degree == -1 || degree < 3)
            degree = controlPoints.Count <= 3 ? controlPoints.Count - 1 : 3;
        float[] knots = null;
        if (type == eBSPLINE_TYPE.eClamped)
            knots = createKnots(controlPoints.Count,degree);
        else
            knots = createOpenKnots(controlPoints.Count, degree);
        float zJump = (knots[knots.Length - 1 - degree] - knots[degree]) / (detail-1);
        float z;
        Vector3 point = new Vector3();
        for (int i = 0; i < detail; i++)
        {
            if (i == detail - 1 && type == eBSPLINE_TYPE.eClamped)
            {
                point = controlPoints[controlPoints.Count - 1];
            }
            else
            {
                z = knots[degree] + i * zJump;
                int zInt = whichInterval(z, knots);
                if (controlPoints.Count <= zInt)
                    continue;
                point = DeBoor(degree, degree, zInt, z, controlPoints, knots);
            }
            points.Add(point);
        }
        return points;
    }
    public static int whichInterval(float x,float[] knots)
    {
        for (int i = 1; i < knots.Length - 1; i++)
        {
            if (x < knots[i])
                return (i - 1);
            else if (x == knots[knots.Length - 1])
                return (knots.Length - 1);
        }
        return -1;
    }
    public static float[] createOpenKnots(int nControl, int degree)
    {
        int nKnots = nControl + degree + 1;

        var knots = new float[nKnots];

        for (int i = 0; i < nKnots; i++)
        {
            if (i < 1) knots[i] = 0;
            else knots[i] = knots[i - 1] + 1;
        }
        return knots;
    }
    public static float[] createKnots(int nControl, int degree)
    {
        int nKnots = nControl + degree + 1;

        var knots = new float[nKnots];
        for (int i = 0; i < nKnots; i++)
        {
            if (i < degree + 1) //节点t 属于k-1，n+1
            {
                knots[i] = 0;
            }
            else if (i < nKnots - degree)
            {
                knots[i] = knots[i - 1] + 1;//k-1，n+1 在这个范围内递增
            }
            else
            {
                knots[i] = knots[i - 1];
            }
        }
        return knots;
    }
}
