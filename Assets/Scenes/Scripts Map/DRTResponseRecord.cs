using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;


public class DRTResponseRecord : MonoBehaviour
{
    bool buttonDown_XRInput;
    InputDevice device;
    InputDevice lefthand;
    bool triggerValue;

    double DRTResponseTime;

    [SerializeField] DataManager dataManager;
    string Path;
    string FileName;

    // Start is called before the first frame update
    void Start()
    {
        //// Find Controllers
        //var RightHandDevices = new List<InputDevice>();
        //InputDevices.GetDevicesAtXRNode(XRNode.RightHand, RightHandDevices);

        //if (RightHandDevices.Count == 1)
        //{
        //    device = RightHandDevices[0];
        //    Debug.Log(string.Format("Device name '{0}' with role '{1}'", device.name, device.role.ToString()));
        //}
        //else if (RightHandDevices.Count > 1)
        //{
        //    Debug.Log("Found more than one right hand!");
        //}

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



        // Record Data
        Path = dataManager.folderPath;
        FileName = dataManager.fileName;
        RecordData.SaveData(Path, "DRTResponse",
          "DRTResponseTime(ms)" + ","
          + "DRTResponseTime(DateTime)" + ","
          + "isInDirectionTrigger" + ","
          + "DirectionTriggerName" + ","
          + "isInLandmarkTrigger" + ","
          + "LandmarkTriggerName"
          + '\n');
    }

    // Update is called once per frame
    void Update()
    {
        // if (device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue)
        if (lefthand.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue)
        {
            if (!buttonDown_XRInput)
            {
                // Button is pressed
                Debug.Log("buttonDown_XRInput is pressed");
                buttonDown_XRInput = true;
                // Record the participant's response
                DRTResponseTime = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
                //Debug.Log("DRTResponseTime: " + DRTResponseTime);
                // Record Data
                RecordData.SaveData(Path, "DRTResponse",
                                    DRTResponseTime.ToString() + ","
                                    + DateTime.Now.ToString() + ","
                                    + SharedVariables.isInDirectionTrigger + ","
                                    + SharedVariables.DirectionTriggerName + ","
                                    + SharedVariables.isInLandmarkTrigger + ","
                                    + SharedVariables.LandmarkTriggerName
                                    +'\n');
            }
            else
            {
                // Button is held down
                Debug.Log("buttonDown_XRInput is held");
            }
        }
        // else if (!(device.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue) && buttonDown_XRInput)
        else if (!(lefthand.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out triggerValue) && triggerValue) && buttonDown_XRInput)
        {
            // Button is released
            Debug.Log("buttonDown_XRInput is released");
            buttonDown_XRInput = false;
        }
    }
}
