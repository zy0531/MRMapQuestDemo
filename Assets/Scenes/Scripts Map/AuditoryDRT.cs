using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using Varjo.XR;

public class AuditoryDRT : MonoBehaviour
{
    [SerializeField] AudioSource auditoryStimuli;
    public float minInterval;
    public float maxInterval;

    [SerializeField] DataManager dataManager;
    string Path;
    string FileName;

    double AudioTime;

    // Start is called before the first frame update
    void Start()
    {
        // Record Data
        //Path = dataManager.folderPath;
        //FileName = dataManager.fileName;
        //RecordData.SaveData(Path, "DRTAudioStimuli",
        //  "AudioPlayTime(ms)" + ","
        //  + "AudioPlayTime(DateTime)" + ","
        //  + "isInDirectionTrigger" + ","
        //  + "DirectionTriggerName" + ","
        //  + "isInLandmarkTrigger" + ","
        //  + "LandmarkTriggerName"
        //  + '\n');

        // Start the auditory DRT task when teleport to the starting position
        StartCoroutine(InvokeUntilCondition());
    }

    IEnumerator InvokeUntilCondition()
    {
        while (!SharedVariables.hasStarted)
        {
            yield return null; // Wait for the next frame before checking the condition again
        }

        // Condition is met
        Invoke("PlayAuditoryStimuli", 1f);
        yield break;
    }

    void PlayAuditoryStimuli()
    {
        float randomTime = UnityEngine.Random.Range(minInterval, maxInterval);

        /// do something here
        // get AudioTime in ms
        AudioTime = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
        //Debug.Log("AudioTime: " + AudioTime);
        // record data
        //RecordData.SaveData(Path, "DRTAudioStimuli",
        //                      AudioTime.ToString() + ","
        //                      + DateTime.Now.ToString() + ","
        //                      + SharedVariables.isInDirectionTrigger + ","
        //                      + SharedVariables.DirectionTriggerName + ","
        //                      + SharedVariables.isInLandmarkTrigger + ","
        //                      + SharedVariables.LandmarkTriggerName
        //                      + '\n');
        // play the audio
        auditoryStimuli.Play();
        ///

        Invoke("PlayAuditoryStimuli", randomTime);
    }
}
