using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Bsp : MonoBehaviour {

    int count = 3;

    public Image panel;
    public Button btnGo;
    public Text tipText;
    bool isVaild = true;
    public int num = 20;
    List<Button> goList = new List<Button>();
	void Start () {
    }
	
    public void OnClick()
    {
        var go = GameObject.Instantiate(btnGo, panel.transform);
        Vector3 point = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        go.transform.position = point;
        goList.Add(go);
        isVaild = true;

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
            tipText.text = "选择控制点";
        }
        else if (goList.Count == 1)
        {
            tipText.text = "选择控制点";
        }
    }
    void DrawLine()
    {

    }
    void OnGUI()
    {
        if(Event.current.keyCode == KeyCode.Space)
        {
            Event.current.mousePosition
        }
    }
    void ButtonClick()
    {
        foreach (var go in goList)
            GameObject.DestroyImmediate(go);
        goList.Clear();
        
    }

}
