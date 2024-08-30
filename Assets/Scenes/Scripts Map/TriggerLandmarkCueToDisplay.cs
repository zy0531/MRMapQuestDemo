using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerLandmarkCueToDisplay : MonoBehaviour
{
    //public 
    bool isWorldCueActive = true;
    [SerializeField] GameObject CueToDisplay;
    [SerializeField] MapExperimentManager mapExperimentManager;

    void Start()
    {
        isWorldCueActive = mapExperimentManager.GetWorldCueStatus();
    }


    private void OnTriggerEnter(Collider other)
    {
        if (isWorldCueActive)
        {
            if (other.CompareTag("MainCamera"))
            {
                CueToDisplay.SetActive(true);

                SharedVariables.isInLandmarkTrigger = true;
                SharedVariables.LandmarkTriggerName = this.transform.name;
            }
        }

    }

    void OnTriggerStay(Collider other)
    {
        if (isWorldCueActive)
        {
            if (other.CompareTag("MainCamera") && !CueToDisplay.activeSelf)
            {
                CueToDisplay.SetActive(true);

                SharedVariables.isInLandmarkTrigger = true;
                SharedVariables.LandmarkTriggerName = this.transform.name;
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (isWorldCueActive)
        {
            if (other.CompareTag("MainCamera"))
            {
                CueToDisplay.SetActive(false);

                SharedVariables.isInLandmarkTrigger = false;
                SharedVariables.LandmarkTriggerName = this.transform.name;
            }
        }

    }
}
