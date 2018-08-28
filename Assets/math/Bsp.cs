using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Bsp : MonoBehaviour
{

    int count = 3;
    public Material LineMat;
    public Image panel;
    public Button btnGo;
    public Text tipText;
    bool isVaild = true;
    public int num = 40;
    public Canvas canvas;
    List<Vector3> posList = new List<Vector3>();
    List<Button> goList = new List<Button>();
    bool isRenderLine = false;
    public BSplineUtil.eBSPLINE_TYPE type = BSplineUtil.eBSPLINE_TYPE.eClamped;
    [Range(3,100)]
    public int degree = 3;
    public bool customdegree = false;
    void Start()
    {

    }

    public void OnClick()
    {
        var go = GameObject.Instantiate(btnGo, panel.transform);
        go.gameObject.SetActive(true);
        Vector2 _pos = Vector2.one;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform,
                    Input.mousePosition, canvas.worldCamera, out _pos);

        go.transform.localPosition = new Vector3(_pos.x, _pos.y, 0);
        goList.Add(go);
        posList.Add(go.transform.position);
        isVaild = true;


    }
    // Update is called once per frame
    void Update()
    {
        if (isVaild)
        {
            isVaild = false;
            RefreshText();

        }
        if (Input.GetKeyDown(KeyCode.C))
        {
            Clear();
            isVaild = true;
            isRenderLine = false;
        }
        if (Input.GetKeyDown(KeyCode.Space))
        {
            isRenderLine = true;

        }
    }
    void RefreshText()
    {

        if (goList.Count <= 0)
        {
            tipText.text = "先选择起始点";
        }
        else if (goList.Count == 1)
        {
            tipText.text = "选择控制点";
        }


    }
    private void OnRenderObject()
    {
        DrawLine();
    }
    void DrawLine()
    {
        if (!isRenderLine || LineMat == null)
            return;
        for (int i = 0; i < posList.Count - 1; ++i)
        {
            var points = new Vector3[] { posList[i], posList[i + 1] };
            DrawLine_Impl(points, Color.red);
        }
        List<Vector3> bspPoints;
        if (customdegree)
            bspPoints = BSplineUtil.GetBspline(posList, num, type,degree);
        else
            bspPoints = BSplineUtil.GetBspline(posList, num, type);
        DrawLine_Impl(bspPoints.ToArray(), Color.blue);
    }

    void Clear()
    {
        foreach (var go in goList)
        {
            GameObject.DestroyImmediate(go.gameObject);

        }
        posList.Clear();
        goList.Clear();

    }
    void DrawLine_Impl(Vector3[] verts, Color color)
    {
        GL.PushMatrix(); //保存当前Matirx  
        LineMat.SetPass(0); //刷新当前材质  
        GL.LoadPixelMatrix();//设置pixelMatrix  
        GL.Color(color);
        GL.Begin(GL.LINES);

        for (int i = 0; i < verts.Length; ++i)
        {
            if (i - 1 >= 0)
                GL.Vertex(verts[i - 1]);
            else
                GL.Vertex(verts[0]);
            GL.Vertex(verts[i]);
        }
        GL.End();
        GL.PopMatrix();//读取之前的Matrix 
    }


}
