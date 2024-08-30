using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum MapCueType
{
    World,
    Map,
    World_Map
}
public class MapExperimentManager : MonoBehaviour
{
    public MapCueType mapCueType;
    
    bool isWorldCueActive = false;
    [SerializeField] GameObject MRMap;
    bool isMRMapActive;
    [SerializeField] GazeInteraction gazeInteraction;
   
    

    // Start is called before the first frame update
    void Awake()
    {
        if (mapCueType == MapCueType.World)
        {
            isWorldCueActive = true;
            MRMap.SetActive(false);
            gazeInteraction.enabled = false;
        }
        else if (mapCueType == MapCueType.Map)
        {
            isWorldCueActive = false;
            isMRMapActive = false; // set false at the beginning, set active after started
            MRMap.SetActive(false);
            gazeInteraction.enabled = false;
        }
        else // else if (mapCueType == MapCueType.World_Map)
        {
            isWorldCueActive = true;
            isMRMapActive = false; // set false at the beginning, set active after started
            MRMap.SetActive(false);
            gazeInteraction.enabled = true;
        }
    }


    private void Start()
    {
        // assign the mapCueType from the MainMenu Scene
        mapCueType = GlobalSceneVariables.mapCueType;
        if (mapCueType == MapCueType.World)
        {
            isWorldCueActive = true;
            MRMap.SetActive(false);
            gazeInteraction.enabled = false;
        }
        else if (mapCueType == MapCueType.Map)
        {
            isWorldCueActive = false;
            isMRMapActive = false; // set false at the beginning, set active after started
            MRMap.SetActive(false);
            gazeInteraction.enabled = false;
        }
        else // else if (mapCueType == MapCueType.World_Map)
        {
            isWorldCueActive = true;
            isMRMapActive = false; // set false at the beginning, set active after started
            MRMap.SetActive(false);
            gazeInteraction.enabled = true;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (SharedVariables.hasStarted & !isMRMapActive)
        {
            if(mapCueType == MapCueType.Map | mapCueType == MapCueType.World_Map)
            {
                MRMap.SetActive(true);
                isMRMapActive = true;
            }
        }

    }


    public bool GetWorldCueStatus()
    {
        return isWorldCueActive;
    }
}
