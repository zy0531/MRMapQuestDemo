using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class LineGenerator : Points
{
    [HideInInspector]
    public List<AddedObject> addedObjects = new List<AddedObject>(); //list of objects to be added

    public TypePosAndRot typePosAndRot; //Type position and rotation
    public TypeOrder typeOrder; //generator order
    public Constraints constraints = new Constraints();

    private float maxPercent;
    public bool IntervalBetPoints;
    private float interval = 5; //interval generator
    public float Interval
    {
        get { return interval; }
        set { interval = (value > 0) ? value : 0.1f; }
    }
    
    /*Function Generation*/
    public void Generator()
    {
        if (addedObjects.Count > 0 && base.nodePosition.Count > 1)
        {
            maxPercent = MaxPercent();
            if (transform.childCount > 0)
                AllDelete(); // Delete All Object
            if (IntervalBetPoints)
                FuncGeneratorIntervalOneLine(); //calculation interval between two points
            else
                FuncGeneratorIntervalAllLine(); //calculation  interval on all points
        }
        else if (addedObjects.Count == 0)
        {
            Debug.LogWarning("There is no object for generation"); //If you have not added any objects to generate
        }
        else
        {
            Debug.LogError("Points has to be more than one");
        }
    }

    /*Function Generator*/
    private void FuncGeneratorIntervalOneLine()
    {
        List<Vector3> pos = base.nodePosition;
        int currIndexObj = 0;

        for (int i = 0; i < pos.Count; i++)
        {
            if (!base.loop && i == pos.Count - 1)
                break;

            Vector3 nextPoint = pos[(i + 1) % pos.Count];
            float dstVector = DstBeeVector(pos[i],nextPoint);

            int countLine = Mathf.FloorToInt(dstVector / Interval);

            for (int j = 0; j < countLine; j++)
            {
                Vector3 newPos = Vector3.Lerp(pos[i], nextPoint, (float)j / countLine);

                if (typeOrder == TypeOrder.Random)
                    currIndexObj = PercentRandom();
                if (addedObjects[currIndexObj].Prefab != null)
                {
                    Transform currTran = CreateObject(currIndexObj, newPos, nextPoint);
                    currTran.parent = transform;
                }
                currIndexObj = (currIndexObj + 1 == addedObjects.Count) ? 0 : currIndexObj + 1;
            }
        }
    }

    private void FuncGeneratorIntervalAllLine()
    {
        List<Vector3> pos = base.nodePosition;
        int currIndexObj = 0;
        bool isRepeat = true;
        int indexPos = 0;
        float dstPlus = 0;

        int tempInd = 0;

        Vector3 newPos = pos[0];
        Vector3 nextPoint = pos[1];

        do
        {
            if (typeOrder == TypeOrder.Random)
                currIndexObj = PercentRandom();
            if (addedObjects[currIndexObj].Prefab != null)
            {
                Transform currTran = CreateObject(currIndexObj, newPos, nextPoint);
                currTran.parent = transform;
            }
            currIndexObj = (currIndexObj + 1 == addedObjects.Count) ? 0 : currIndexObj + 1;

            for (int i = indexPos; i < pos.Count; i++)
            {
                nextPoint = pos[(i + 1) % pos.Count];
                float dst = DstBeeVector(newPos, nextPoint);

                if (dst + dstPlus > Interval)
                {
                    newPos = Vector3.MoveTowards(newPos, nextPoint, Interval - dstPlus);
                    dstPlus = 0;
                    break;
                }
                else
                {
                    if ((i == pos.Count - 1) || (!base.loop && i == pos.Count - 2))
                    {
                        isRepeat = false;
                        break;
                    }
                    dstPlus = dst;
                    newPos = nextPoint;
                    indexPos = i + 1;
                }
                
            }

            tempInd++;
            if (tempInd > 1000)
                isRepeat = false;

        } while (isRepeat);
    }

    float DstBeeVector(Vector3 a, Vector3 b)
    {
       return (typePosAndRot == TypePosAndRot.NormalPolygon) ? Vector3.Distance(new Vector3(a.x, 0, a.z), new Vector3(b.x, 0, b.z)) : Vector3.Distance(a, b);
    }

    /*Position and Rotation Object*/
    private Transform CreateObject(int currInt,Vector3 pos, Vector3 nextPos)
    {
        Vector3 newPos = pos;
        Quaternion newRot = Quaternion.LookRotation(nextPos - pos);

        if (typePosAndRot == TypePosAndRot.NormalPolygon)
        {
            RaycastHit hit;
            Ray ray = new Ray(pos + new Vector3(0, 10, 0), Vector3.down);
            if (Physics.Raycast(ray, out hit, 400))
            {
                newPos = hit.point;
                newRot = Quaternion.FromToRotation(Vector3.up, hit.normal) * Quaternion.Euler(0, newRot.eulerAngles.y, 0);
            }
        }

        newRot = Freeze(newRot);

        return Instantiate(addedObjects[currInt].Prefab, newPos, newRot).transform;
    }

    private Quaternion Freeze(Quaternion rot)
    {
        Vector3 rotVector = rot.eulerAngles;
        rotVector.x *= (constraints.RotX) ? 0 : 1;
        rotVector.y *= (constraints.RotY) ? 0 : 1;
        rotVector.z *= (constraints.RotZ) ? 0 : 1;
        return Quaternion.Euler(rotVector);
    }

    private float MaxPercent()
    {
        float maxPercent = 0;

        for (int i = 0; i < addedObjects.Count; i++)
        {
            maxPercent += addedObjects[i].Percent;
        }
        return maxPercent;
    }
    /*Random number from the list*/
    private int PercentRandom()
    {
        float currRange = Random.Range(0, maxPercent);
        float currPercent = 0;
        int currInt = 0;

        for (int i = 0; i < addedObjects.Count; i++)
        {
            currPercent += addedObjects[i].Percent;

            if (currPercent >= currRange)
            {
                currInt = i;
                break;
            }
        }
        return currInt;
    }

    /*All Delete GameObject*/
    public void AllDelete()
    {
        int maxDelete = transform.childCount;
        for (int i = 0; i < maxDelete; i++)
        {
            if (Application.isEditor && transform.GetChild(0) != null)
            {
                DestroyImmediate(transform.GetChild(0).gameObject);
            }
            else if (transform.GetChild(0) != null)
            {
                Destroy(transform.GetChild(0));
            }
        }
    }
}

[System.Serializable]
public struct AddedObject
{
    public GameObject Prefab;
    public float Percent;
}

public struct Constraints
{
    public bool RotX;
    public bool RotY;
    public bool RotZ;
}

public enum TypePosAndRot { ByLine, NormalPolygon }

public enum TypeOrder {Random, Seriatim }
