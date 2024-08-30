using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SaveRouteSketch : MonoBehaviour
{
    [SerializeField]
    Camera cam;

    [SerializeField] DataManager dataManager;
    string Path;
    string FileName;

    //public string file;
    public RenderTexture rt;

    void Start()
    {
        Path = dataManager.folderPath;
        FileName = dataManager.fileName;
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.M))
        {
            string file = Path + "/" + FileName + "RouteDrawing.png";
            Debug.Log(file);
            SaveTexture(file);
            Debug.Log("Texture was saved from Render Texture.");
        }
    }


    public void SaveTexture(string file)
    {
        // Render the camera to its active RenderTexture (no need to create a new one)
        cam.Render();

        // Create a new Texture2D to hold the rendered data
        Texture2D texture2D = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);

        // Read the pixels from the active RenderTexture to the Texture2D
        RenderTexture.active = cam.targetTexture;
        texture2D.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        texture2D.Apply();

        // Encode the Texture2D to a PNG file and save it
        byte[] bytes = texture2D.EncodeToPNG();
        System.IO.File.WriteAllBytes(file, bytes);

        // Clean up resources
        RenderTexture.active = null;
        Destroy(texture2D);
    }
}
