using System;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MapDrawingAnswer : MonoBehaviour
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
            + "est_x" + ";"
            + "est_y" + ";"
            + "est_z" + ";"
            + "answer_x" + ";"
            + "anwser_y" + ";"
            + "answer_z" + '\n');
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
            float est_x = Landmark_viewPos.x;
            float est_y = Landmark_viewPos.y;
            float est_z = Landmark_viewPos.z;
            Debug.Log("Landmark_name: " + Landmarks[i].gameObject.name);
            Debug.Log("Landmark_viewPos: " + Landmark_viewPos.ToString("f3"));
            
            Vector3 correctAnswer = GetMapAnswer(i);
            float ans_x = correctAnswer.x;
            float ans_y = correctAnswer.y;
            float ans_z = correctAnswer.z;
            
            RecordData.SaveData(Path, FileName,
                          DateTime.Now.ToString() + ";"
                        + Landmarks[i].gameObject.name + ";"
                        + Landmark_viewPos.ToString("f3") + ";"
                        + est_x.ToString("f3") + ";"
                        + est_y.ToString("f3") + ";"
                        + est_z.ToString("f3") + ";"
                        + ans_x.ToString("f3") + ";"
                        + ans_y.ToString("f3") + ";"
                        + ans_z.ToString("f3") + '\n');
        }
    }

    // This answer is got from the camera viewport transform from the "Exploration" environment
    public Vector3 GetMapAnswer(int i)
    {
        switch(i)
        {
            case 0:
                return new Vector3(0.598f, 0.395f, 290.000f);
            case 1:
                return new Vector3(0.394f, 0.217f, 292.500f);
            case 2:
                return new Vector3(0.117f, 0.395f, 260.000f);
            case 3:
                return new Vector3(0.307f, 0.677f, 295.000f);
            case 4:
                return new Vector3(0.604f, 0.882f, 275.000f);
            case 5:
                return new Vector3(0.869f, 0.849f, 235.000f);
            case 6:
                return new Vector3(0.791f, 0.569f, 280.000f);
            default:
                return new Vector3(0f,0f,0f);
        }
                
    }


}
