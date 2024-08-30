using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExitExploration : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            StartCoroutine(Quit.WaitQuit(6));
        }
    }
}
