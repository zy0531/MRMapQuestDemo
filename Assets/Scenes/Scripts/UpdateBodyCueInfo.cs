using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateBodyCueInfo : MonoBehaviour
{
    public static int DecisionPointToPoint_Index = 0;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            //https://www.1024sou.com/article/47272.html
            Transform parent = this.transform.parent;
            int MyIndex = this.transform.GetSiblingIndex();
            DecisionPointToPoint_Index = MyIndex; 
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("MainCamera"))
        {
            Transform parent = this.transform.parent;
            int MyIndex = this.transform.GetSiblingIndex();
            DecisionPointToPoint_Index = MyIndex+1;
        }
    }
}
