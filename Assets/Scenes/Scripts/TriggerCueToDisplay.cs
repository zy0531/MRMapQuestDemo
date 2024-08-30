using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerCueToDisplay : MonoBehaviour
{
    [SerializeField] GameObject CueToDisplay;

    private void OnTriggerEnter(Collider other)
    {
         if (other.CompareTag("MainCamera"))
         {
            CueToDisplay.SetActive(true);

            SharedVariables.isInDirectionTrigger = true;
            SharedVariables.DirectionTriggerName = this.transform.name;
         }
        
    }

    void OnTriggerStay(Collider other)
    {

        if (other.CompareTag("MainCamera") && !CueToDisplay.activeSelf)
        {
            CueToDisplay.SetActive(true);

            SharedVariables.isInDirectionTrigger = true;
            SharedVariables.DirectionTriggerName = this.transform.name;
        }
    }

    private void OnTriggerExit(Collider other)
    {

        if (other.CompareTag("MainCamera"))
        {
            CueToDisplay.SetActive(false);

            SharedVariables.isInDirectionTrigger = false;
            SharedVariables.DirectionTriggerName = "";
        }
        
    }
}
