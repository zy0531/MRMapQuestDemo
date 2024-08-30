using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.XR;
using Varjo.XR;

public class GazeInteraction : MonoBehaviour
{
    [SerializeField] GameObject landmarksParent;
    [SerializeField] GameObject landmarksReplicasParent;
    [SerializeField] LayerMask layermask;
    [SerializeField] GameObject gazeIndicator;
    public float fixationLength = 1f;

    EyeTrackingExploration gaze;

    Vector3 gazeOrigin;
    Vector3 gazeDirection;

    float fixationTimer;
    string preGazeHitObject;
    int i;



    // Start is called before the first frame update
    void Start()
    {
        gaze = GetComponent<EyeTrackingExploration>();
    }

    // Update is called once per frame
    void Update()
    {
        // Read in the gaze origin and gaze direction (world coordinate) from EyeTrackingExample
        gazeOrigin = gaze.getRayOrigin();
        gazeDirection = gaze.getDirection();
    }
    
    
    // update in 50Hz
    void FixedUpdate() 
    {
        // Read in the gaze origin and gaze direction (world coordinate) from EyeTrackingExample
        gazeOrigin = gaze.getRayOrigin();
        gazeDirection = gaze.getDirection();

        // Check if the gaze vector is hit any target landmark or target landmark replica
        RaycastHit hit;
        // if gaze hits target landmarks
        if (Physics.SphereCast(gazeOrigin, 0.1f, gazeDirection, out hit, Mathf.Infinity, layermask))
        {
            // if look at another landmark -> reset the timer
            if (hit.transform.name != preGazeHitObject)
            {
                ResetFixationTimer();
            }
            // check the hit gameobject
            switch (hit.transform.name)
            {
                case "LandmarkReplica7(Clone)":
                    print("LandmarkReplica7(Clone)");
                    i = 6;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                case "LandmarkReplica6(Clone)":
                    print("LandmarkReplica6(Clone)");
                    i = 5;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                case "LandmarkReplica5(Clone)":
                    print("LandmarkReplica5(Clone)");
                    i = 4;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                case "LandmarkReplica4(Clone)":
                    print("LandmarkReplica4(Clone)");
                    i = 3;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                case "LandmarkReplica3(Clone)":
                    print("LandmarkReplica3(Clone)");
                    i = 2;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                case "LandmarkReplica2(Clone)":
                    print("LandmarkReplica2(Clone)");
                    i = 1;
                    FixationTimeUpdate(i,hit.transform);
                    break;
                case "LandmarkReplica1(Clone)":
                    print("LandmarkReplica1(Clone)");
                    i = 0;
                    FixationTimeUpdate(i, hit.transform);
                    break;
                default:
                    print("Incorrect intelligence level.");
                    break;
            }
            preGazeHitObject = hit.transform.name;
        }
        // if gaze not hits any target landmarks -> reset the timer
        else
        {
            ResetFixationTimer();
        }
    }

    void FixationTimeUpdate(int i, Transform hit)
    {
            fixationTimer += Time.deltaTime;
            if (fixationTimer >= fixationLength)
            {
                Debug.Log("Fixation on " + hit.name + " complete!");
                hit.GetChild(0).gameObject.SetActive(true);
                if (i < landmarksParent.transform.childCount)
                    landmarksParent.transform.GetChild(i).GetChild(0).gameObject.SetActive(true);
            }
    }

    void ResetFixationTimer()
    {
        fixationTimer = 0f;
    }

}
