using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ControllerRay : MonoBehaviour
{
    public Transform teleportPointer;           // Teleport pointer
    public LayerMask ControllerRayLayerMask;        // Collision layers

    [Tooltip("This field sets a LineRenderer")]
    [SerializeField] LineRenderer rend;  // teleportPointer LineRenderer

    public Vector3 EstimatedDirection { get; set; }

    Vector3[] points;
    bool buttonDown;

    // Start is called before the first frame update
    void Start()
    {
        rend = teleportPointer.GetComponent<LineRenderer>();
        points = new Vector3[2];
        points[0] = Vector3.zero;
        points[1] = teleportPointer.transform.position + new Vector3(0, 0, 10);
        rend.SetPositions(points);
        rend.enabled = true;
    }

    // Update is called once per frame
    void Update()
    {
        //version 1
        AlignLineRenderer(rend, teleportPointer.position, teleportPointer.forward); 
    }

    public void SetEstimatedDirection()
    {
        EstimatedDirection = teleportPointer.forward;
        //Debug.Log("EstDirection>>>>>>>>>>>" + EstimatedDirection.ToString("f3"));
        //Debug.Log("EstDirectionProjectOnPlane>>>>>>>>>>>" + Vector3.ProjectOnPlane(EstimatedDirection, new Vector3(0, 1, 0)).ToString("f3")); //vector, plane normal
    }

    // version 1: return void
    public void AlignLineRenderer(LineRenderer rend, Vector3 originposition, Vector3 direction)
    {
        Ray ray = new Ray(originposition, direction);
        RaycastHit hit;
        points[0] = originposition;
        points[1] = originposition + (100f * direction);
        rend.startColor = Color.white;
        rend.endColor = Color.white;
        rend.SetPositions(points);
        rend.material.color = rend.startColor;
    }

    //version 2: return bool (hit or not)
    public bool AlignLineRenderer(LineRenderer rend, Vector3 originposition, Vector3 direction, LayerMask layers)
    {
        bool hitBtn = false;
        Ray ray = new Ray(originposition, direction);
        RaycastHit hit;
        points[0] = originposition;
        points[1] = originposition + (10f * direction);
        if (Physics.Raycast(ray, out hit, layers))
        {
            points[1] = hit.point;
            rend.startColor = new Color32(0, 245, 255, 255);
            rend.endColor = new Color32(128, 255, 128, 255);
            hitBtn = true;
        }
        else
        {
            rend.startColor = Color.white;
            rend.endColor = Color.white;
            hitBtn = false;
        }
        rend.SetPositions(points);
        rend.material.color = rend.startColor;
        return hitBtn;
    }


    
    void DrawControllerRay(Vector3 originposition, Vector3 direction, LayerMask layers)
    {
        Ray ray = new Ray(originposition, direction);
        RaycastHit hit;
        Vector3 endPosition = originposition + (1f * direction);
        //Vector3 endPosition = originposition + (length * direction);

        if (Physics.Raycast(ray, out hit, Mathf.Infinity, layers))
        {
            endPosition = hit.point;
        }

        rend.SetPosition(0, originposition);
        rend.SetPosition(1, endPosition);
    }
}
