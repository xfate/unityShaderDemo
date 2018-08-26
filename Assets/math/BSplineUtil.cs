using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BSplineUtil
{

    public static Vector3 DeBoor(int j, int k,int i, float t,List<Vector3> controlPoints,List<float> knots)
    {
        if (j == 0)
            return controlPoints[i];
        else
        {
            float param = (t - knots[i]) / (knots[i + k- j] - knots[i]);
            return ((1-param) * DeBoor(j - 1, k, i - 1, t, controlPoints, knots)
                + param * DeBoor(j - 1, k, i, t, controlPoints, knots)); 
        }
    }

    public static List<Vector3> GetBspline(List<Vector3> controlPoints,float detail,string type)
    {
        List<Vector3> points = new List<Vector3>();
        int degree = controlPoints.Count <= 3 ? controlPoints.Count - 1 : 3;
        var knots = createKnots(controlPoints.Count,degree);

        float zJump = (knots[knots.Count - 1 - degree] - knots[degree]) / detail;
        float z;
        Vector3 point = new Vector3();
        for (int i = 0; i < detail; i++)
        {
            if (i == detail - 1 && type == "clamped")
            {
                point = controlPoints[controlPoints.Count - 1];
            }
            else
            {
                z = knots[degree] + i * zJump;
                int zInt = whichInterval(z, knots);
                point = DeBoor(degree, degree, zInt, z, controlPoints, knots);
            }
            points.Add(point);
        }
        return points;
    }
    public static int whichInterval(float x,List<float> knots)
    {
        for (int i = 1; i < knots.Count - 1; i++)
        {
            if (x < knots[i])
                return (i - 1);
            else if (x == knots[knots.Count - 1])
                return (knots.Count - 1);
        }
        return -1;
    }
    public static List<float> createOpenKnots(int nControl, int degree)
    {
        int nKnots = nControl + degree + 1;

        List<float> knots = new List<float>(nKnots);

        for (int i = 0; i < nKnots; i++)
        {
            if (i < 1) knots[i] = 0;
            else knots[i] = knots[i - 1] + 1;
        }
        return knots;
    }
    public static List<float> createKnots(int nControl, int degree)
    {
        int nKnots = nControl + degree + 1;

        List<float> knots = new List<float>(nKnots);
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
