using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Bezier : MonoBehaviour {

    int count = 3;
    public Material LineMat;
    public Image panel;
    public Button btnGo;
    public Text tipText;
    bool isVaild = true;
    public int num = 40;
    public Canvas canvas;
    List<Button> goList = new List<Button>();
	void Start () {

    }
	
    public void OnClick()
    {
        if (goList.Count < count)
        {
            var go = GameObject.Instantiate(btnGo, panel.transform);
            go.gameObject.SetActive(true);
            Vector2 _pos = Vector2.one;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform,
                        Input.mousePosition, canvas.worldCamera, out _pos);

            go.transform.localPosition = new Vector3(_pos.x,_pos.y,0);
            goList.Add(go);
            isVaild = true;
        }
    

    }
	// Update is called once per frame
	void Update () {
        if (isVaild)
        {
            isVaild = false;
            RefreshText();
  
        }
        if (Input.GetKeyDown(KeyCode.C))
        {
            Clear();
            isVaild = true;
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
        else if (goList.Count == 2)
        {
            tipText.text = "选择终点";
        }

    }
    private void OnRenderObject()
    {
        DrawLine();
    }
    void DrawLine()
    {
        if (goList.Count < count || LineMat == null)
            return;
        var p0 = goList[0].transform.position;
        var p1 = goList[1].transform.position;
        var p2 = goList[2].transform.position;
        var points1 = new Vector3[] { p0, p1 };
        DrawLine_Impl(points1,Color.red);
        var points2 = new Vector3[] { p1, p2 };
        DrawLine_Impl(points2, Color.red);
        var points3 = new Vector3[num];
        BezierUtil.GetBezier(ref points3, p0, p1, p2, num);
        DrawLine_Impl( points3, Color.blue);
    }

    void Clear()
    {
        foreach (var go in goList)
        {
            GameObject.DestroyImmediate(go.gameObject);
       
        }
          
        goList.Clear();
        
    }
    void DrawLine_Impl(Vector3 [] verts, Color color)
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
