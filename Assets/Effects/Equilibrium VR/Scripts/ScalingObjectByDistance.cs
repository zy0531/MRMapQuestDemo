using UnityEngine;
using System.Collections;

public class ScalingObjectByDistance : MonoBehaviour
{
    //This script using for scaling text mesh above checkpoints by distance

    public float startingDistance;
    public Vector3 startingScale;
    public float curDistance;

    void Update()
    {
        curDistance = Vector3.Distance(Camera.main.transform.position, transform.position);
        if (curDistance > 0 && curDistance < 200) transform.localScale = new Vector3(2, 2, 2) * curDistance/200;


    }
}
