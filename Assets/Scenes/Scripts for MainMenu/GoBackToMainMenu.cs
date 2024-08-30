using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.SceneManagement;


public class GoBackToMainMenu : MonoBehaviour
{
    [SerializeField] string sceneName = "MainMenuRoom";


    bool buttonDown;
    InputDevice righthand;
    InputDevice lefthand;
    bool hasStarted;

    // Start is called before the first frame update
    void Start()
    {
        // Find Right Controller
        var RightHandDevices = new List<InputDevice>();
        InputDevices.GetDevicesAtXRNode(XRNode.RightHand, RightHandDevices);

        if (RightHandDevices.Count == 1)
        {
            righthand = RightHandDevices[0];
            Debug.Log(string.Format("Device name '{0}' with role '{1}'", righthand.name, righthand.role.ToString()));
        }
        else if (RightHandDevices.Count > 1)
        {
            Debug.Log("Found more than one right hand!");
        }

        // Find Left Controller
        var LeftHandDevices = new List<InputDevice>();
        InputDevices.GetDevicesAtXRNode(XRNode.LeftHand, LeftHandDevices);

        if (LeftHandDevices.Count == 1)
        {
            lefthand = LeftHandDevices[0];
            Debug.Log(string.Format("Device name '{0}' with role '{1}'", lefthand.name, lefthand.role.ToString()));
        }
        else if (LeftHandDevices.Count > 1)
        {
            Debug.Log("Found more than one left hand!");
        }
    }

    // Update is called once per frame
    void Update()
    {
        // use "Right Primary Button" to teleport back to the main menu
        righthand.TryGetFeatureValue(CommonUsages.secondaryButton, out bool secondaryPressed);

        // if (controller.triggerButton)
        if (secondaryPressed)
        {
            if (!buttonDown)
            {
                // Button is pressed
                buttonDown = true;
            }
            else
            {
                // Button is held down
            }
        }
        // else if (!controller.triggerButton && buttonDown)
        else if (!secondaryPressed && buttonDown)
        {
            // Button is released
            Debug.Log("tRIGGER");
            LoadScene(sceneName);
            buttonDown = false;
        }
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
