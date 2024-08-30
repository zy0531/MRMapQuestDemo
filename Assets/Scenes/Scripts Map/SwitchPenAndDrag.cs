using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;
using TMPro;

public class SwitchPenAndDrag : MonoBehaviour
{
    [SerializeField] DragDrop dragDrop;

    [SerializeField] PenFollowController penFollowController;
    [SerializeField] EraserFollowController eraserFollowController;
    [SerializeField] GameObject pen;
    [SerializeField] GameObject eraser;

    [Tooltip("This field sets a TMP_Text for primarybutton indicating pen status.")]
    [SerializeField] TextMeshPro m_TMP_primarybutton;
    [Tooltip("This field sets a TMP_Text for touchbutton.")]
    [SerializeField] TextMeshPro m_TMP_touchbutton;
    [Tooltip("This field sets a TMP_Text for triggerbutton.")]
    [SerializeField] TextMeshPro m_TMP_triggerbutton;

    [SerializeField] DataManager dataManager;
    string Path;
    string FileName;

    InputDevice righthand;
    bool ButtonState;
    bool buttonDown;
    bool TriggerButtonState;
    Vector3 rightControllerPos;

    bool penToggleOn;

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

        //Record Data -- First Line
        //Path = dataManager.folderPath;
        //FileName = dataManager.fileName;
        
        //RecordData.SaveData(Path, FileName + "RouteDrawingController",
        //      "Time" + ";"
        //    + "controllerPos_x" + ";"
        //    + "controllerPos_y" + ";"
        //    + "controllerPos_z" + ";"
        //    + "PenToggleOn" + '\n');
        ////Record the task starting time
        //RecordData.SaveData(Path, FileName + "RouteDrawingController",
        //      DateTime.Now.ToString() + ";"
        //                + ";"
        //                + '\n');

        // Default: toggle off the pen
        penFollowController.enabled = false;
        eraserFollowController.enabled = false;

        dragDrop.enabled = true;
    }

    // Update is called once per frame
    void Update()
    {
        // update the TMPText for pen status indication
        if (!penFollowController.enabled & !eraserFollowController.enabled)
        {
            m_TMP_primarybutton.text = "Pen & Eraser Off";
            m_TMP_primarybutton.color = Color.white;

            m_TMP_touchbutton.text = "";

            m_TMP_triggerbutton.text = "Drag Landmarks";
        }
        else
        {
            m_TMP_primarybutton.text = "Pen & Eraser On";
            m_TMP_primarybutton.color = Color.green;

            m_TMP_touchbutton.text = "Eraser";

            m_TMP_triggerbutton.text = "Pen for Drawing";
        }
        



        // For data recording (only record controller position when pressing and holding the trigger button)
        if (righthand.TryGetFeatureValue(CommonUsages.triggerButton, out TriggerButtonState) && TriggerButtonState)
        {
            if (righthand.TryGetFeatureValue(CommonUsages.devicePosition, out rightControllerPos))
            {
                Debug.Log("Let's write right hand controller position!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                //RecordData.SaveData(Path, FileName + "RouteDrawingController",
                //  DateTime.Now.ToString() + ";"
                //+ rightControllerPos.x + ";"
                //+ rightControllerPos.y + ";"
                //+ rightControllerPos.z + ";"
                //+ penToggleOn + '\n');
            }
            
        }
    

        // For pen toggling
        if (righthand.TryGetFeatureValue(UnityEngine.XR.CommonUsages.primaryButton, out ButtonState) && ButtonState)
        {
            if (!buttonDown)
            {
                // Button is pressed
                buttonDown = true;
            }
            else
            {
                // When Button is held down
            }
        }
        else if (buttonDown)
        {
            // Button is released
            TogglePen();
            ResetPenPosition();
            ToggleEraser();
            ResetEraserPosition();

            ToggleDragDrop();

            buttonDown = false;
        }
    }

    void TogglePen()
    {
        penFollowController.enabled = !penFollowController.enabled;
        penToggleOn = penFollowController.enabled;
    }
    void ResetPenPosition()
    {
        pen.transform.position = new Vector3(1.05f, 1f, 2.5f);
    }

    void ToggleEraser()
    {
        eraserFollowController.enabled = !eraserFollowController.enabled;
    }
    void ResetEraserPosition()
    {
        eraser.transform.position = new Vector3(1.05f, 1.1f, 2.5f);
    }

    void ToggleDragDrop()
    {
        dragDrop.enabled = !penFollowController.enabled;
    }
}
