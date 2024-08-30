using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VarjoExample;

public class DragDrop : MonoBehaviour
{
    public Transform projectileOrigin;
    bool buttonDown;

    Controller controller;
    GameObject projectile;
    bool IsTriggerEnter;

    // Start is called before the first frame update
    void Start()
    {
        controller = GetComponent<Controller>();
    }

    // Update is called once per frame
    void Update()
    {
        if (controller.triggerButton)
        {
            if (!buttonDown)
            {
                // Button is pressed
                buttonDown = true;              
            }
            else
            {
                // When Button is held down
                // If trigger with an existing object
                if (IsTriggerEnter)
                {
                    projectile.transform.position = projectileOrigin.transform.position;
                }
            }
        }
        else if (!controller.triggerButton && buttonDown)
        {
            // Button is released
            if (projectile)
            {
                projectile.transform.parent = null;
            }
            buttonDown = false;
        }
    }


    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Landmark"))
        {
            Debug.Log("Enter!!!!!!!!!!!");
            IsTriggerEnter = true;
            if (!projectile) // if we don't have anything holding
                projectile = other.gameObject;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Landmark"))
        {
            Debug.Log("Stay!!!!!!!!!!!");
            IsTriggerEnter = true;
            if (!projectile) // if we don't have anything holding
                projectile = other.gameObject;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Landmark"))
        {
            Debug.Log("Exit!!!!!!!!!!!");
            IsTriggerEnter = false;
            if (projectile) // if we don't have anything holding
                projectile = null;
        }
    }




    public string GetHoldingObjectName()
    {
        if (projectile)
            return projectile.transform.name;
        else
            return "None";
    }

    public Vector3 GetHoldingObjectPosition()
    {
        if (projectile)
            return projectile.transform.position;
        else
            return new Vector3(0f, 0f, 0f);
    }
}
