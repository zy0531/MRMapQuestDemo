using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEngine;

public static class RecordData
{
    public static void SaveData(string Inputpath, string fileName, string data)
    {
        // string path = Path.Combine(Application.persistentDataPath, fileName+ ".csv");
        string path = Path.Combine(Inputpath, fileName + ".csv");
        // Debug.Log(Application.persistentDataPath);
        // This text is added only once to the file.
        if (!File.Exists(path))
        {
            // Create a file to write to.
            string createText = Environment.NewLine;
            File.WriteAllText(path, createText);
        }

        // This text is always added, making the file longer over time if it is not deleted.
        File.AppendAllText(path, data);

    }
}