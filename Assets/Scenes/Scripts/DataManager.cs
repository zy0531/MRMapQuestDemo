using System.Collections;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DataManager : MonoBehaviour
{
    public string participantID;
    public string folderPath;
    public int taskNum;
    public string fileName;

    void Awake()
    {
        folderPath = Application.dataPath + "/Logs/" + participantID;
        DirectoryInfo folder = Directory.CreateDirectory(folderPath); // returns a DirectoryInfo object

        if(fileName==null || fileName == "")
            fileName = SceneManager.GetActiveScene().name + "_Trial" + taskNum.ToString();
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
