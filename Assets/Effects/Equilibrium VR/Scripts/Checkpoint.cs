using UnityEngine;
 using System.Collections;
 
 public class Checkpoint : MonoBehaviour 
 {
    //Using for text mesh look at player camera
     private GameObject target;
     private Vector3 targetPoint;
     private Quaternion targetRotation;
 
     void Start () 
     {
         target = GameObject.Find("MainCamera");
     }
 
     void Update()
     {
         targetPoint = target.transform.position - transform.position;
         targetRotation = Quaternion.LookRotation (-targetPoint, Vector3.up);
         transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime * 2.0f);
     }
 }