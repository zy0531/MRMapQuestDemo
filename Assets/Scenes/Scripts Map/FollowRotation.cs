using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowRotation : MonoBehaviour
{
    [Tooltip("Assign MainCamera as the player here.")]
    [SerializeField] Transform player;

    Vector3 facingDirection;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        // follow rotation
        facingDirection = ProjectToXZPlane(player.transform.forward);
        transform.rotation = Quaternion.LookRotation(facingDirection, Vector3.up);

        //follow position
        transform.position = player.transform.position;
    }

    Vector3 ProjectToXZPlane(Vector3 v)
    {
        return new Vector3(v.x, 0.0f, v.z).normalized;
        // for the specific projection to x-z plane, simply setting y to 0 works.
    }
}
