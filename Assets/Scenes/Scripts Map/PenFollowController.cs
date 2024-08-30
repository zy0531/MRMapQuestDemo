using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using VarjoExample;


public class PenFollowController : MonoBehaviour
{
    [SerializeField] GameObject pen;
    [SerializeField] GameObject eraser;
    public Transform projectileOrigin;

    InputDevice righthand;
    bool ButtonState;
    bool buttonDown;

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
    }

    // Update is called once per frame
    void Update()
    {
        if (righthand.TryGetFeatureValue(UnityEngine.XR.CommonUsages.triggerButton, out ButtonState) && ButtonState)
        {
            if (!buttonDown)
            {
                // Button is pressed
                ResetEraserPosition();
                buttonDown = true;
            }
            else
            {
                // When Button is held down
                pen.transform.position = projectileOrigin.transform.position;
            }
        }
        else if (buttonDown)
        {
            // Button is released
            buttonDown = false;
        }
    }

    void ResetEraserPosition()
    {
        eraser.transform.position = new Vector3(1.05f, 1.1f, 2.5f);
    }
}
