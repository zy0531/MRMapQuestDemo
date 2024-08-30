using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;


public class VisibilityTest : MonoBehaviour
{
    [SerializeField] LayerMask layermask;
    [SerializeField] public Transform[] Points;
    [SerializeField] public float moveSpeed;
    [SerializeField] public Transform globalLandmark;
    private int waypointsIndex;

    string folderPath;
    [SerializeField] public string fileName;


    Vector3 oldPos;
    Vector3 newPos;
    float distance;

    bool IsHit;

    // Start is called before the first frame update
    void Start()
    {
        transform.position = Points[waypointsIndex].transform.position;
        folderPath = Application.dataPath + "/Logs/" + "CheckVisibility";
        DirectoryInfo folder = Directory.CreateDirectory(folderPath); // returns a DirectoryInfo object

        // Record Data
        RecordData.SaveData(folderPath, fileName, "Time from Start" + "," + "Position" + "," + "deltaDistance" + "," + "isHit" + "\n");
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void FixedUpdate()
    {
        oldPos = transform.position;
        if (waypointsIndex <= Points.Length - 1)
        {
            transform.position = Vector3.MoveTowards(transform.position, Points[waypointsIndex].transform.position, moveSpeed * Time.deltaTime);

            // Cast a ray to check visibility
            // LayerMask layermask = LayerMask.NameToLayer("GlobalLandmarkR1");
            // int layerMask_int = 1 << 0; // cast rays only against colliders in layer Default (0)
            // Debug.Log(layerMask_int);
            RaycastHit hit;
            Vector3 dir = globalLandmark.position - transform.position;
            float distance = Vector3.Distance(globalLandmark.position, transform.position);
            Debug.DrawRay(transform.position, dir, Color.green, 1.0f);
            if (Physics.Raycast(transform.position, dir, out hit, distance, layermask))
            {
                IsHit = true;
            }
            else
            {
                IsHit = false;
            }

            newPos = transform.position;
            distance = Vector3.Distance(newPos, oldPos);
            Debug.Log(Time.fixedTime);
            Debug.Log(transform.position);
            Debug.Log(distance);
            Debug.Log(IsHit);
            // Record Data
            RecordData.SaveData(folderPath, fileName, Time.fixedTime + "," + transform.position + "," + distance + "," + IsHit + "\n");


            // Next Waypoint
            if (transform.position == Points[waypointsIndex].transform.position)
            {
                waypointsIndex += 1;
            }
        }


        else
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#endif
            Application.Quit();

        }
    }
}
