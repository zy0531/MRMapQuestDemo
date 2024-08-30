using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class FillScreen : MonoBehaviour
{
    public float HorizontalRatio = 1.0f;
    public float VerticalRatio = 1.0f;


    void Start()
    {
        StartCoroutine(SetARLensSimulator());
    }

    IEnumerator SetARLensSimulator()
    { 
        yield return new WaitForSeconds(1);

        float distance = (Camera.main.nearClipPlane + 0.2f);

        transform.position = Camera.main.transform.position + Camera.main.transform.forward * distance;


        /// Set the aspect ratio by the sensor size properties of the physical camera ("film gate")
        Camera.main.aspect = 36f / 24f;
        //https://docs.unity3d.com/Manual/PhysicalCameras.html


        /// manipulate the FOV by VertocalRatio and HorizontalRatio
        float fieldOfView_Height = Camera.main.fieldOfView * VerticalRatio;
        float fieldOfView_Width = Camera.VerticalToHorizontalFieldOfView(Camera.main.fieldOfView, Camera.main.aspect) * HorizontalRatio;
        /// Same results as using the function above
        //float hFOVrad = Mathf.Atan(Mathf.Tan(Camera.main.fieldOfView * Mathf.Deg2Rad * 0.5f) * Camera.main.aspect) * 2f;
        //float fieldOfView_Width = hFOVrad * Mathf.Rad2Deg * HorizontalRatio;
        
        float height = 2.0f * distance * Mathf.Tan(fieldOfView_Height * 0.5f * Mathf.Deg2Rad);
        float width = 2.0f * distance * Mathf.Tan(fieldOfView_Width * 0.5f * Mathf.Deg2Rad);
        //https://docs.unity3d.com/Manual/FrustumSizeAtDistance.html
        //https://forum.unity.com/threads/how-to-calculate-horizontal-field-of-view.16114/


        transform.localScale = new Vector3(width * 0.1f, 1f, height * 0.1f); //use plane object -- scale 1: 10m 

        Debug.Log("fieldOfView_Height" + fieldOfView_Height.ToString() 
            + " fieldOfView_Width " + fieldOfView_Width.ToString() 
            + " Camera.main.aspect " + Camera.main.aspect
            + " Camera.main.fieldOfView" + Camera.main.fieldOfView
            + " Camera.main.nearClipPlane" + Camera.main.nearClipPlane
            + " height " + height.ToString()
            + " width " + width.ToString());

    }
        


}
