using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : MonoBehaviour
{
    //void Update()
    //{
    //    // Press the space key to start coroutine
    //    if (Input.GetKeyDown(KeyCode.Space))
    //    {
    //        // Use a coroutine to load the Scene in the background
    //        StartCoroutine(LoadYourAsyncScene("Exploration"));
    //    }
    //}


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
