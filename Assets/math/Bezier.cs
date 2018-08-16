using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Bezier : MonoBehaviour {

    int count = 3;
    LineRenderer bezier;
    LineRenderer line1;
    LineRenderer line2;
    public Image panel;
    public Button btnGo;
    public Text tipText;
    bool isVaild = true;
    public int num = 20;
    List<Button> goList = new List<Button>();
	void Start () {

        line1 = new LineRenderer();
        line2 = new LineRenderer();
        bezier = new LineRenderer();
    }
	
    public void OnClick()
    {
        if (goList.Count < count)
        {
            var go = GameObject.Instantiate(btnGo, panel.transform);
            Vector3 point = Camera.main.ScreenToWorldPoint(Input.mousePosition);
            go.transform.position = point;
            goList.Add(go);
            isVaild = true;
        }
        DrawLine();

    }
	// Update is called once per frame
	void Update () {
        if (isVaild)
        {
            isVaild = false;
            RefreshText();
  
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
        else if (goList.Count == 3)
        {
            tipText.text = "拖动控制点";
        }
    }
    void DrawLine()
    {
        if (goList.Count < count)
            return;
        var p0 = goList[0].transform.position;
        var p1 = goList[1].transform.position;
        var p2 = goList[2].transform.position;
        var points1 = new Vector3[] { p0, p1 };
        Draw_Impl(line1,ref points1,Color.red);
        var points2 = new Vector3[] { p1, p2 };
        Draw_Impl(line2, ref points2, Color.red);
        var points3 = new Vector3[num];
        BezierUtil.GetBezier(ref points3, p0, p1, p2, num);
        Draw_Impl(bezier, ref points3, Color.blue);
    }
    void Draw_Impl(LineRenderer line,ref Vector3 [] points,Color color)
    {
        line.SetPositions(points);
        line.startColor = color;
        line.endColor = color;
    }
    void ButtonClick()
    {
        foreach (var go in goList)
            GameObject.DestroyImmediate(go);
        goList.Clear();
        
    }

}
