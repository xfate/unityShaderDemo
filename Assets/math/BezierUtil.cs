using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BezierUtil  {

    /// <summary>
    /// 获取二阶贝塞尔曲线的点
    /// </summary>
    /// <param name="p0"></param>
    /// <param name="p1"></param>
    /// <param name="p2"></param>
    /// <param name="t"></param>
    public static Vector3 GetBezierPoint_SecondOrder(Vector3 p0, Vector3 p1, Vector3 p2,float t)
    {
        return (1-t) * (1-t) * p0 + (1 - t) * p1 + t * t * p2;
    }

    public static void GetBezier(ref Vector3[] points,Vector3 p0, Vector3 p1, Vector3 p2,int num)
    {
        float line = Vector3.Distance(p2, p0);
        float step = line / num;
        for (int i = 0; i < num; ++i)
        {
            points[i] = GetBezierPoint_SecondOrder(p0, p1, p2, i * step);
        }
    }
}
