using System;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ViewportCoord : MonoBehaviour
{
    [SerializeField] Transform[] Landmarks;
    [SerializeField] Camera OrthoCamera;
    [SerializeField] DataManager dataManager;
    string Path;
    string FileName;

    // Start is called before the first frame update
    void Start()
    {
        //Record Data -- First Line
        Path = dataManager.folderPath;
        FileName = dataManager.fileName;
        RecordData.SaveData(Path, FileName,
              "Time" + ";"
            + "Landmark_name" + ";"
            + "Landmark_viewPos" + ";"
            + "x" + ";"
            + "y" + ";"
            + "z" 
            + '\n');
        //Record the task starting time
        RecordData.SaveData(Path, FileName,
              DateTime.Now.ToString() + ";"
                        + ";"
                        + '\n');
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyUp(KeyCode.M))
            CalculateViewportCoord();
    }

    public void CalculateViewportCoord()
    {
        for (int i = 0; i < Landmarks.Length; i++)
        {
            Vector3 Landmark_viewPos = OrthoCamera.WorldToViewportPoint(Landmarks[i].position);
            var x = Landmark_viewPos.x;
            var y = Landmark_viewPos.y;
            var z = Landmark_viewPos.z;
            Debug.Log("Landmark_name: " + Landmarks[i].gameObject.name);
            Debug.Log("Landmark_viewPos: " + Landmark_viewPos.ToString("f3"));
            RecordData.SaveData(Path,FileName,
                          DateTime.Now.ToString() + ";"
                        + Landmarks[i].gameObject.name + ";"
                        + Landmark_viewPos.ToString("f3") + ";"
                        + x + ";"
                        + y + ";"
                        + z
                        + '\n');
        }
    }


}
