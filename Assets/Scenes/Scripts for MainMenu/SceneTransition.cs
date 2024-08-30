using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;


public class SceneTransition : MonoBehaviour
{
    public Toggle WorldToggle;
    public Toggle MapToggle;
    public Toggle WorldMapToggle;

    void Update()
    {

    }

    // Method to find which toggle is on
    private string GetActiveToggle()
    {
        if (WorldToggle.isOn) return "World";
        if (MapToggle.isOn) return "Map";
        if (WorldMapToggle.isOn) return "World_Map";
        return null; // No toggle is on
    }

    private void GetMapCueType()
    {
        // Determine which toggle is on and set the mapCueType accordingly
        switch (GetActiveToggle())
        {
            case "World":
                GlobalSceneVariables.mapCueType = MapCueType.World;
                break;
            case "Map":
                GlobalSceneVariables.mapCueType = MapCueType.Map;
                break;
            case "World_Map":
                GlobalSceneVariables.mapCueType = MapCueType.World_Map;
                break;
            default:
                Debug.LogWarning("No toggle is selected.");
                break;
        }
    }






    public void LoadSceneExploration()
    {
        // Get the selected cue condition
        GetMapCueType();
        // Use a coroutine to load the Scene in the background
        StartCoroutine(LoadYourAsyncScene("MRMapExploration"));
    }

    public void LoadScenePointing()
    {
        // Use a coroutine to load the Scene in the background
        StartCoroutine(LoadYourAsyncScene("MRMapPointing"));
    }

    public void LoadSceneMapDrawing()
    {
        // Use a coroutine to load the Scene in the background
        StartCoroutine(LoadYourAsyncScene("MRMapMapDrawing"));
    }

    public void LoadScene(string sceneName)//e.g. "Exploration"
    {
        // Use a coroutine to load the Scene in the background
        StartCoroutine(LoadYourAsyncScene(sceneName));
    }


    IEnumerator LoadYourAsyncScene(string sceneName)
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(sceneName);

        // Wait until the asynchronous scene fully loads
        while (!asyncLoad.isDone)
        {
            yield return null;
        }

    }
}
