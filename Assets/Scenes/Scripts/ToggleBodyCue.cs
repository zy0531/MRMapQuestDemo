using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToggleBodyCue : MonoBehaviour
{
    public Transform DecisionPoints;
    [SerializeField] GameObject BodyFixedCue;

    void Update()
    {
        CheckVisible();
    }

    // Check whether the current decision point is in the camera view frustum
    void CheckVisible()
    {
        Transform currentDecisionPoint = DecisionPoints.GetChild(UpdateBodyCueInfo.DecisionPointToPoint_Index).gameObject.transform;
        
        Vector3 screenPoint = Camera.main.WorldToViewportPoint(currentDecisionPoint.position);
        bool onScreen = screenPoint.z > 0 && screenPoint.x > 0 && screenPoint.x < 1 && screenPoint.y > 0 && screenPoint.y < 1;

        //if users are looking at the correct direction, inactive the body-fixed cue
        if (onScreen)
        {
            BodyFixedCue.SetActive(false);
        }
        //if users are not looking at the correct direction, active the body-fixed cue
        else if (!onScreen)
        {
            BodyFixedCue.SetActive(true);
        }
    }
}
