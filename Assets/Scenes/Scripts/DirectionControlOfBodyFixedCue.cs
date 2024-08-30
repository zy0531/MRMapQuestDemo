using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectionControlOfBodyFixedCue : MonoBehaviour
{
    public Transform DecisionPoints;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(DecisionPoints.GetChild(UpdateBodyCueInfo.DecisionPointToPoint_Index).gameObject.transform);
        transform.Rotate(Vector3.left * 90);
        transform.Rotate(Vector3.forward * 90);
    }
}
