using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerMapCue : MonoBehaviour
{
    bool mapCueActive;
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            //CueToDisplay.SetActive(true);
            mapCueActive = true;
        }
    }

    void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("MainCamera") && !mapCueActive)
        {
            //CueToDisplay.SetActive(true);
            mapCueActive = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            //CueToDisplay.SetActive(false);
            mapCueActive = false;
        }
    }

    /// <summary>
    /// send to TriggerResponser attached on each LandmarkReplica
    /// </summary>
    /// <returns>mapCueActive</returns>
    public bool GetMapCueStatus()
    {
        return mapCueActive;
    }
}
