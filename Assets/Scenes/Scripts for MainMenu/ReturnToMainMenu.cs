using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.SceneManagement;

public class ReturnToMainMenu : MonoBehaviour
{
    //public SceneLoader sceneLoader;
    [SerializeField] GameObject XRRig;
    [SerializeField] GameObject XRRigMenu;
    [SerializeField] GameObject Canvas;
    [SerializeField] GameObject CanvasReturnToLobby;

    InputDevice device;
    bool ButtonState;
    bool buttonDown_XRInput;

    // Start is called before the first frame update
    void Start()
    {
        //Find SceneLoader
        //sceneLoader = GetComponent<SceneLoader>();

        //Find Right Controller
        var RightHandDevices = new List<InputDevice>();
        InputDevices.GetDevicesAtXRNode(XRNode.RightHand, RightHandDevices);

        if (RightHandDevices.Count == 1)
        {
            device = RightHandDevices[0];
            Debug.Log(string.Format("Device name '{0}' with role '{1}'", device.name, device.role.ToString()));
        }
        else if (RightHandDevices.Count > 1)
        {
            Debug.Log("Found more than one right hand!");
        }
    }

    // Update is called once per frame
    void Update()
    {
        //if (Input.GetKeyDown(KeyCode.Space))
        //{
        //    // Use a coroutine to load the Scene in the background
        //    // StartCoroutine(LoadYourAsyncScene("MainMenu"));
        //    SceneManager.LoadScene("MainMenu", LoadSceneMode.Single);
        //}
        if (device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.primaryButton, out ButtonState) && ButtonState) // using primary button
        {
            //Debug.Log("primary button is pressed.");
            if (!buttonDown_XRInput)
            {
                // Button is pressed
                Debug.Log("buttonDown_XRInput is pressed");
                buttonDown_XRInput = true;
            }
            else
            {
                // Button is held down
                Debug.Log("buttonDown_XRInput is held");
            }
        }
        else if (!(device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.primaryButton, out ButtonState) && ButtonState) && buttonDown_XRInput)
        {
            // Button is released
            Debug.Log("buttonDown_XRInput is released");
            //Go back to MainMenu by pressing the primary button
            //sceneLoader.LoadScene("MainMenu");
            //SceneManager.LoadScene("MainMenu", LoadSceneMode.Additive);
            XRRig.SetActive(false);
            XRRigMenu.SetActive(true);
            Canvas.SetActive(true);
            CanvasReturnToLobby.SetActive(false);

            buttonDown_XRInput = false;
        }
    }
}
