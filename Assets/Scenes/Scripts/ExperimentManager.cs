using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum InfoType
{
    WithoutLandmark,
    WithLandmark
}
public enum RouteType
{
    Route1,
    Route2
}
public enum CueType
{
    ScreenFixed,
    WorldFixed
}

public class ExperimentManager : MonoBehaviour
{
    // public static ExperimentManager Instance; //singleton https://learn.unity.com/tutorial/implement-data-persistence-between-scenes#
    public RouteType routeType;
    public CueType cueType;
    public InfoType infoType;

    [SerializeField] GameObject Instruction_Route1;
    [SerializeField] GameObject Instruction_Route2;

    [SerializeField] GameObject BodyFixedCue_Route1;
    [SerializeField] GameObject BodyFixedCue_Route2;

    [SerializeField] GameObject WorldARCues_Direction_Route1;
    [SerializeField] GameObject WorldARCues_Direction_Route2;

    [SerializeField] GameObject ScreenARCues_Direction_Route1;
    [SerializeField] GameObject ScreenARCues_Direction_Route2;

    [SerializeField] GameObject WorldARCues_Landmark_Route1;
    [SerializeField] GameObject WorldARCues_Landmark_Route2;

    [SerializeField] GameObject ScreenARCues_Landmark_Route1;
    [SerializeField] GameObject ScreenARCues_Landmark_Route2;

    /// <summary>
    /// This field sets the go-straignt cue for WorldFixed condition
    /// </summary>
    [SerializeField] GameObject WorldARCues_Straight_Route1;
    [SerializeField] GameObject WorldARCues_Straight_Route2;

    [SerializeField] Timer timer;


    void Awake()
    {
        Instruction_Route1.SetActive(false);
        Instruction_Route2.SetActive(false);

        BodyFixedCue_Route1.SetActive(false);
        BodyFixedCue_Route2.SetActive(false);

        WorldARCues_Direction_Route1.SetActive(false);
        WorldARCues_Direction_Route2.SetActive(false);
        ScreenARCues_Direction_Route1.SetActive(false);
        ScreenARCues_Direction_Route2.SetActive(false);
        WorldARCues_Landmark_Route1.SetActive(false);
        WorldARCues_Landmark_Route2.SetActive(false);
        ScreenARCues_Landmark_Route1.SetActive(false);
        ScreenARCues_Landmark_Route2.SetActive(false);

        WorldARCues_Straight_Route1.SetActive(false);
        WorldARCues_Straight_Route2.SetActive(false);

        ////Read in TransferValue.infoType_Message sent from the Dropdown UI in the Mainmanu scene
        //if (TransferValue.infoType_Message == InfoType.WithoutLandmark.ToString())
        //{
        //    infoType = InfoType.WithoutLandmark;
        //    Debug.Log(infoType);
        //}

        //else if (TransferValue.infoType_Message == InfoType.WithLandmark.ToString())
        //{
        //    infoType = InfoType.WithLandmark;
        //    Debug.Log(infoType);
        //}
        ////Read in TransferValue.cueType_Message sent from the Dropdown UI in the Mainmanu scene
        //if (TransferValue.cueType_Message == CueType.ScreenFixed.ToString())
        //{
        //    cueType = CueType.ScreenFixed;
        //    Debug.Log(cueType);
        //}
            
        //else if(TransferValue.cueType_Message == CueType.WorldFixed.ToString())
        //{
        //    cueType = CueType.WorldFixed;
        //    Debug.Log(cueType);
        //}
        ////Read in TransferValue.routeType_Message sent from the Dropdown UI in the Mainmanu scene
        //if (TransferValue.routeType_Message == RouteType.Route1.ToString())
        //{
        //    routeType = RouteType.Route1;
        //    Debug.Log(routeType);
        //}

        //else if (TransferValue.routeType_Message == RouteType.Route2.ToString())
        //{
        //    routeType = RouteType.Route2;
        //    Debug.Log(routeType);
        //}

    }
    
    void Start()
    {
        //If Route1, teleport to Route1 (after reading the instructions)
        // Active cues on Route1 
        if(routeType == RouteType.Route1)
        {
            //Instruction_Route1.SetActive(true);
            if (cueType == CueType.ScreenFixed)
            {
                ScreenARCues_Direction_Route1.SetActive(true);
                //BodyFixedCue_Route1.SetActive(true);
                if (infoType == InfoType.WithLandmark)
                {
                    ScreenARCues_Landmark_Route1.SetActive(true);
                }
            }
            else if (cueType == CueType.WorldFixed)
            {
                WorldARCues_Direction_Route1.SetActive(true);
                WorldARCues_Straight_Route1.SetActive(true);
                if (infoType == InfoType.WithLandmark)
                {
                    WorldARCues_Landmark_Route1.SetActive(true);
                }
            }
        }

        //else if Route2, teleport to Route2
        // Active cues on Route1 
        else if (routeType == RouteType.Route2)
        {
            //Instruction_Route2.SetActive(true);
            if (cueType == CueType.ScreenFixed)
            {
                ScreenARCues_Direction_Route2.SetActive(true);
                // BodyFixedCue_Route2.SetActive(true);
                if (infoType == InfoType.WithLandmark)
                {
                    ScreenARCues_Landmark_Route2.SetActive(true);
                }
            }
            else if (cueType == CueType.WorldFixed)
            {
                WorldARCues_Direction_Route2.SetActive(true);
                WorldARCues_Straight_Route2.SetActive(true);
                if (infoType == InfoType.WithLandmark)
                {
                    WorldARCues_Landmark_Route2.SetActive(true);
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.L))
        {
            Debug.Log("Press Keycode.L: Start Timer & Show All Target Landmarks.");
            timer.SetTimerOn();
            if (routeType == RouteType.Route1)
            {
                Instruction_Route1.SetActive(true);
            }
            else if (routeType == RouteType.Route2)
            {
                Instruction_Route2.SetActive(true);
            }
        }
    }
    //call in class - TeleportToStartPosition
    public void ActiveBodyFixedCue(bool hasStarted)
    {
        //if (cueType == CueType.ScreenFixed)
        //{
            if (routeType == RouteType.Route1)
            {
                BodyFixedCue_Route1.SetActive(true);
            }
            else if (routeType == RouteType.Route2)
            {
                BodyFixedCue_Route2.SetActive(true);
            }
        //}
    }
}
