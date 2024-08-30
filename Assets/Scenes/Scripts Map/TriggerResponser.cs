using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerResponser : MonoBehaviour
{
    [SerializeField] GameObject landmarkTrigger;
    [SerializeField] GameObject LandmarkCue;
    TriggerMapCue triggerMapCue;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        triggerMapCue = landmarkTrigger.GetComponent<TriggerMapCue>();
        if (triggerMapCue.GetMapCueStatus())
        {
            Debug.Log("triggerMapCue.mapCueActive TRUE!!!");
            LandmarkCue.SetActive(true);
        }
        else
        {
            Debug.Log("triggerMapCue.mapCueActive FALSE!!!");
            LandmarkCue.SetActive(false);
        }
    }
}
