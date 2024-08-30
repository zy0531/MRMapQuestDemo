using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayDestinationAudio : MonoBehaviour
{
    [SerializeField] AudioSource audioData;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            Debug.Log("Enter Destination Collider !!!!!!!!!!!");
            PlayAudio();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            Debug.Log("Exit Destination Collider !!!!!!!!!!!");
        }
    }

    public void PlayAudio()
    {
        audioData.Play();
    }
}
