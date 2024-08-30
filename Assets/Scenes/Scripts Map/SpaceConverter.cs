using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class SpaceConverter : MonoBehaviour
{
    [SerializeField] private LayerMask layermask;
    [SerializeField] private Camera minimapCam;
    [SerializeField] private List<GameObject> landmarks;
    [SerializeField] private List<GameObject> landmarksReplicas;

    [SerializeField] BodyFixedMap bodyFixedMap;

    /// <summary>
    /// Record landmarks that already are visualized
    /// </summary>
    Dictionary<int, GameObject> VisualizedLandmarks = new Dictionary<int, GameObject>();


    // Start is called before the first frame update
    void Start()
    {
        // Get BodyFixedMap
        bodyFixedMap = bodyFixedMap.GetComponent<BodyFixedMap>();
    }

    // Update is called once per frame
    void Update()
    {
        // for each target landmarks
        for (int index = 0; index < landmarks.Count; index++)
        {
            // landmark world space position -> viewport space position            
            Vector3 worldPos = landmarks[index].transform.position;
            Vector2 viewPos = minimapCam.WorldToViewportPoint(worldPos);

            //Debug.Log("landmark: " + landmarks[index].name + worldPos + viewPos.ToString("F3"));

            // if the landmark is in the viewport
            bool InViewport = viewPos.x > 0.1 && viewPos.x < 0.9 && viewPos.y > 0.1 && viewPos.y < 0.9;
            bool InBoundary = viewPos.x > -0.1 && viewPos.x < 1.1 && viewPos.y > -0.1 && viewPos.y < 1.1;
            if (InViewport)
            {
                // if the landmark has not been visualized yet, clone it as a landmark replica
                if (!VisualizedLandmarks.ContainsKey(index))
                {
                    // clone the landmark replica
                    GameObject LandmarkClone = bodyFixedMap.LandmarkVisualize(viewPos, landmarksReplicas[index]);
                    // update dictionary
                    VisualizedLandmarks.Add(index, LandmarkClone);
                }


                // update the landmark position on the map, if the "index" key exists in the dictionary
                string iVal;
                if (VisualizedLandmarks.ContainsKey(index))
                {
                    // key exists
                    bodyFixedMap.LandmarkPositionUpdate(viewPos, VisualizedLandmarks[index]);
                }
                else
                {
                    // key not exists
                }
            }
            // if the landmark is in the boundary
            else if(InBoundary)
            {
                // do nothing (for smoother transformation) - not make it appear or disappear
                
                // update the landmark position on the map, if the "index" key exists in the dictionary
                string iVal;
                if (VisualizedLandmarks.ContainsKey(index))
                {
                    // key exists
                    bodyFixedMap.LandmarkPositionUpdate(viewPos, VisualizedLandmarks[index]);
                }
                else
                {
                    // key not exists
                }
            }
            // if the landmark is out of the viewport
            else
            {
                if (VisualizedLandmarks.ContainsKey(index))
                {
                    Destroy(VisualizedLandmarks[index]);
                    VisualizedLandmarks.Remove(index);
                }
                    
            }
        }
    }
}
