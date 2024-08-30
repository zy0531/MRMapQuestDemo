using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
//using VarjoExample;
using UnityEngine.XR;

public class TeleportToStartPosition : MonoBehaviour
{
    [SerializeField] ExperimentManager experimentManager;
    [SerializeField] Transform startPosition_Route1;
    [SerializeField] Transform startPosition_Route2;
    [SerializeField] GameObject xrRig;
    [SerializeField] Timer timer;
    [SerializeField] AudioSource StartNavigationAudio;

    [SerializeField] DataManager dataManager;

    bool hasStarted;
    //bool buttonDown;
    bool buttonDown_XRInput;
    //Controller controller;

    InputDevice device;
    bool triggerValue;

    string Path;
    string FileName;


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

        hasStarted = false;
        buttonDown_XRInput = false;

        Path = dataManager.folderPath;
        FileName = dataManager.fileName;
        //RecordData.SaveData(Path, FileName,
        //     "Start Time: "+ DateTime.Now.ToString()
        //               + '\n');
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
        //    if(!hasStarted)
        //    {
        //        if(experimentManager.routeType == RouteType.Route1)
        //            xrRig.transform.position = startPosition_Route1.position;
        //        else if (experimentManager.routeType == RouteType.Route2)
        //            xrRig.transform.position = startPosition_Route2.position;
        //        hasStarted = true;
        //        experimentManager.ActiveBodyFixedCue(hasStarted);
        //        // timer.SetTimerOff();

        //        StartNavigationAudio.PlayDelayed(2);


        //        RecordData.SaveData(Path, FileName,
        //                "Exploration Start Time: " + DateTime.Now.ToString()
        //                + '\n');
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
                if (experimentManager.routeType == RouteType.Route1)
                    xrRig.transform.position = startPosition_Route1.position;
                else if (experimentManager.routeType == RouteType.Route2)
                    xrRig.transform.position = startPosition_Route2.position;
                hasStarted = true;
                experimentManager.ActiveBodyFixedCue(hasStarted);
                // timer.SetTimerOff();

                // StartNavigationAudio.PlayDelayed(2);


                //RecordData.SaveData(Path, FileName,
                //        "Exploration Start Time: " + DateTime.Now.ToString()
                //        + '\n');
            }
            buttonDown_XRInput = false;
        }
    }
}
