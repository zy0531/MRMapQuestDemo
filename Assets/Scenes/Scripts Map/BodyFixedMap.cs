using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyFixedMap : MonoBehaviour
{
    public float offset_X = 0f;
    public float offset_Y = 0f;
    public float offset_Z = 0f;
    public float rotation_X = 0f;
    public float rotation_Y = 0f;
    public float rotation_Z = 0f;

    [SerializeField] Transform parent;
    [SerializeField] Camera minimapCam;


    Vector3 cameraPos;

    // Start is called before the first frame update
    void Start()
    {
        transform.localRotation = Quaternion.Euler(rotation_X, rotation_Y, rotation_Z);
    }

    // Update is called once per frame
    void Update()
    {
        transform.localPosition = new Vector3(offset_X, offset_Y, offset_Z);
    }

    public GameObject LandmarkVisualize(Vector2 viewportPos, GameObject landmark)
    {
        var prefab = landmark;
        GameObject childGameObject = Instantiate(prefab, parent);

        float scaleSize = 1.0f / (minimapCam.orthographicSize * 2.0f);
        childGameObject.transform.localScale = new Vector3(scaleSize, scaleSize, scaleSize);

        //childGameObject.transform.localScale = new Vector3(0.05f, 0.05f, 0.05f);
        //childGameObject.transform.localRotation = Quaternion.Euler(-90, 0, 0);
        return childGameObject;
    }

    public void LandmarkPositionUpdate(Vector2 viewportPos, GameObject landmark)
    {
        var x = viewportPos.x;
        var y = viewportPos.y;

        // update the position of the landmark replicas
        landmark.transform.localPosition = new Vector3(-0.5f+x,-0.5f+y,0f); // viewport origin is bottom-left

        // freeze the rotation of the landmark replicas
        landmark.transform.rotation = Quaternion.Euler(0, 0, 0);
    }
}
