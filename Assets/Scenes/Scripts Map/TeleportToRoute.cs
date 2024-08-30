using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;



public class TeleportToRoute : MonoBehaviour
{
    [SerializeField] Transform startPosition;
    [SerializeField] GameObject xrRig;
    [SerializeField] Locomotion locomotion;

    // Controller controller;
    InputDevice righthand;
    InputDevice lefthand;

    bool buttonDown;
    bool hasStarted;


    // Start is called before the first frame update
    void Start()
    {
        locomotion.enabled = false;

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

        // use "T" on the keyboard to teleport to the start position
        if (Input.GetKeyUp(KeyCode.T))
        {
            if (!hasStarted)
            {
                xrRig.transform.position = startPosition.position;
                locomotion.enabled = true;
                hasStarted = true;
                SharedVariables.hasStarted = hasStarted;
            }
        }


        // use "Right TriggerButton" on the keyboard to teleport to the start position
        // Get the current state of the trigger button
        righthand.TryGetFeatureValue(CommonUsages.triggerButton, out bool triggerPressed);

        // if (controller.triggerButton)
        if (triggerPressed)
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
        else if (!triggerPressed && buttonDown)
        {
            // Button is released
            Debug.Log("tRIGGER");
            if (!hasStarted)
            {
                xrRig.transform.position = startPosition.position;
                locomotion.enabled = true;
                hasStarted = true;
                SharedVariables.hasStarted = hasStarted;
            }
            buttonDown = false;
        }
    }
}
