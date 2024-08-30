using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using VarjoExample;
using UnityEngine.XR;

public class TeleportToStartTraining : MonoBehaviour
{
    [SerializeField] Transform startPosition;
    [SerializeField] GameObject xrRig;
    [SerializeField] GameObject ScreenInstruction; 
    bool hasStarted;
    //bool buttonDown;
    //Controller controller;
    bool buttonDown_XRInput;
    InputDevice device;
    bool triggerValue;


    // Start is called before the first frame update
    void Start()
    {
        //controller = GetComponent<Controller>();
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
        //if (controller.triggerButton)
        //{
        //    if (!buttonDown)
        //    {
        //        // Button is pressed
        //        buttonDown = true;
        //    }
        //    else
        //    {
        //        // Button is held down
        //    }
        //}
        //else if (!controller.triggerButton && buttonDown)
        //{
        //    // Button is released
        //    Debug.Log("tRIGGER");
        //    if (!hasStarted)
        //    {
        //        xrRig.transform.position = startPosition.position;
        //        hasStarted = true;
        //        ScreenInstruction.SetActive(true);
        //    }
        //    buttonDown = false;
        //}



        if (device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue)
        {
            //Debug.Log("Trigger button is pressed.");
            //Debug.Log("triggerValue: " + triggerValue);
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
        else if (!(device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue) && buttonDown_XRInput)
        {
            // Button is released
            Debug.Log("buttonDown_XRInput is released");
            if (!hasStarted)
            {
                xrRig.transform.position = startPosition.position;
                hasStarted = true;
                ScreenInstruction.SetActive(true);
            }
            buttonDown_XRInput = false;
        }
    }
}

