using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class Timer : MonoBehaviour
{
    public float TimeLeft;
    public bool TimerOn = false;
    public TMP_Text TimerTxt;

    // Start is called before the first frame update
    void Start()
    {
        // TimerOn = true;
    }

    // Update is called once per frame
    void Update()
    {
        if(TimerOn)
        {
            if(TimeLeft > 0)
            {
                TimeLeft -= Time.deltaTime;
                UpdateTimer(TimeLeft);
            }
            else
            {
                Debug.Log("Time is UP!");
                TimeLeft = 0;
                TimerOn = false;
                TimerTxt.text = "";
            }
        }
    }
    void UpdateTimer(float currentTimeLeft)
    {
        currentTimeLeft += 1;
        float minutes = Mathf.FloorToInt(currentTimeLeft / 60);
        float seconds = Mathf.FloorToInt(currentTimeLeft % 60);

        TimerTxt.text = string.Format("{0:00}:{1:00}",minutes,seconds);
    }

    public void SetTimerOn()
    {
        Debug.Log("SetTimerOn!");
        TimerOn = true;
    }

    public void SetTimerOff()
    {
        Debug.Log("SetTimerOff!");
        TimeLeft = 0;
        TimerOn = false;
        TimerTxt.text = "";
    }

}
