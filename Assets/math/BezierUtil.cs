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
        return (1-t) * (1-t) * p0 + 2*(1 - t)*t * p1 + t * t * p2;
    }
    /// <summary>
    /// 获取贝塞尔曲线
    /// </summary>
    /// <param name="points"></param>
    /// <param name="p0"></param>
    /// <param name="p1"></param>
    /// <param name="p2"></param>
    /// <param name="num"></param>
    public static void GetBezier(ref Vector3[] points,Vector3 p0, Vector3 p1, Vector3 p2,int num)
    {
        for (int i = 1; i <= num; ++i)
        {
            float t =  i / (float)num;
            points[i-1] = GetBezierPoint_SecondOrder(p0, p1, p2, t);
      
        }
    }
}
