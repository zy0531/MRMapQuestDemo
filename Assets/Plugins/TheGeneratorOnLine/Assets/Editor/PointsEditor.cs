using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Points), true)]
public class PointsEditor : Editor {

    Points pointsPos; // variable class Points
    SelectInfo selectInfo; // variable class SelectInfo

    bool showEdit = false; // show point editing tools
    bool ShowEdit
    {
        get { return showEdit; }
        set
        {
            showEdit = value;
            Tools.hidden = value; // hide tools
            needRepaint = true;
            SceneView.RepaintAll();
        }
    }

    bool addMode = false; // fast addition of points
    bool AddMode
    {
        get { return addMode; }
        set
        {
            addMode = value;
            needRepaint = true;
            SceneView.RepaintAll();
        }
    }

    bool needRepaint = true; // Update scene

    protected virtual void OnEnable()
    {
        pointsPos = (Points)target; // assign component Points
        selectInfo = new SelectInfo(); // new class Select Info

        Undo.undoRedoPerformed += OnUndoRedo;
    }

    protected virtual void OnDisable()
    {
        Tools.hidden = false;
        Undo.undoRedoPerformed -= OnUndoRedo;
    }

    void OnUndoRedo()
    {
        if (selectInfo.pointIndex >= pointsPos.nodePosition.Count)
        {
            selectInfo.pointIndex = -1;
        }
    }

    public override void OnInspectorGUI()
    {
        ShowEdit = GUILayout.Toggle(ShowEdit, "Show Points Editor","Button"); // toggle - show/hide button tools in inspector
        if (ShowEdit)
        {
            GUILayout.BeginVertical("Box");
            GUI.skin.label.alignment = TextAnchor.MiddleCenter;
            GUILayout.Label("Tools");
            pointsPos.sizeButton = EditorGUILayout.FloatField("Size Point:", pointsPos.sizeButton);
            pointsPos.loop = EditorGUILayout.Toggle("Loop:", pointsPos.loop);
            AddMode = GUILayout.Toggle(AddMode, "Add Mode", "Button"); // toggle - On/Off add points with the left mouse button
            GUILayout.BeginHorizontal();
            ToolLine();
            GUILayout.EndHorizontal();

            if (GUILayout.Button("All Delete Point")) // Delete All Ponts
            {
                Undo.RecordObject(pointsPos, "All Delete Point");
                pointsPos.nodePosition.Clear();
                selectInfo.lineIndex = -1;
                selectInfo.pointIndex = -1;
                SceneView.RepaintAll();
                needRepaint = true;
            }
            GUILayout.EndVertical();
        }
    }

    /*Average value*/
    private Vector3 AvegVector()
    {
        Vector3 startPoint = pointsPos.nodePosition[selectInfo.lineIndex];
        Vector3 nextPoint = pointsPos.nodePosition[(selectInfo.lineIndex + 1) % pointsPos.nodePosition.Count];
        return Vector3.Lerp(startPoint, nextPoint, 0.5f);
    }

    /*Instruments: Add a point between points, Delete point*/
    private void ToolLine()
    {
        EditorGUI.BeginDisabledGroup(selectInfo.lineIndex == -1);
        if (GUILayout.Button("Divide Line") && selectInfo.lineIndex != -1)
        {
            Undo.RecordObject(pointsPos, "Divide  Line");
            pointsPos.nodePosition.Insert(selectInfo.lineIndex + 1, AvegVector());
            selectInfo.pointIndex = selectInfo.lineIndex + 1;
            selectInfo.lineIndex = -1;
            SceneView.RepaintAll();
            needRepaint = true;
        }
        EditorGUI.EndDisabledGroup();
        EditorGUI.BeginDisabledGroup(selectInfo.pointIndex == -1);
        if (GUILayout.Button("Delete Point") && selectInfo.pointIndex != -1)
        {
            Undo.RecordObject(pointsPos, "Delete Point");
            pointsPos.nodePosition.RemoveAt(selectInfo.pointIndex);
            selectInfo.pointIndex -= 1;
            SceneView.RepaintAll();
            needRepaint = true;
        }
        EditorGUI.EndDisabledGroup();
    }

    public void OnSceneGUI()
    {
        Event guiEvent = Event.current;
        if (showEdit)
        {
            if (selectInfo.pointIndex != -1) // Draw Tool position point
                pointsPos.nodePosition[selectInfo.pointIndex] = Handles.PositionHandle(pointsPos.nodePosition[selectInfo.pointIndex], Quaternion.identity);

            if (guiEvent.type == EventType.Repaint && pointsPos.nodePosition.Count > 0)
            {
                Draw(); //Draw Scene ponts and line
            }
            else if (guiEvent.type == EventType.Layout)
            {
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
            }
            else
            {
                HandlesInput(guiEvent); //Input Mouse
                if (needRepaint)
                    HandleUtility.Repaint();
            }            
        }
    }

    /*Draw Scene line and point*/
    private void Draw()
    {
        for(int i = 0; i < pointsPos.nodePosition.Count; i++)
        {
            Vector3 nextPoint = pointsPos.nodePosition[(i + 1) % pointsPos.nodePosition.Count];

            /*Draw Point*/
            Handles.color = (selectInfo.pointIndex== i) ? Color.red : Color.white; ;
            Handles.DrawSolidDisc(pointsPos.nodePosition[i], Camera.current.transform.forward, pointsPos.sizeButton);

            if (i == pointsPos.nodePosition.Count - 1 && !pointsPos.loop)
                break;
            /*Draw Line*/
            Handles.color = (selectInfo.lineIndex == i) ? Color.red : Color.white;
            Handles.DrawDottedLine(pointsPos.nodePosition[i], nextPoint, 4);
        }
        needRepaint = false;
    }

    private void HandlesInput(Event guiEvent)
    {
        if (guiEvent.type == EventType.MouseDown && guiEvent.button == 0)
        {
            if (pointsPos.nodePosition.Count > 0)
            {
                SelectLineAndPoint(); //Сhoice of line or point
            }
            if (selectInfo.pointIndex == -1 && selectInfo.lineIndex == -1 && AddMode)
            {
                AppPoint(guiEvent); //Add point - if addmode on
            }
        }
    }

    /*Сhoice of line or point*/
    private void SelectLineAndPoint()
    {
        for (int i = 0; i < pointsPos.nodePosition.Count; i++)
        {
            Vector3 nextPoint = pointsPos.nodePosition[(i + 1) % pointsPos.nodePosition.Count];

            /*Select Point*/
            if (HandleUtility.DistanceToDisc(pointsPos.nodePosition[i], Camera.current.transform.forward, pointsPos.sizeButton * 0.1f) < pointsPos.sizeButton * 14)
            {
                selectInfo.lineIndex = -1;
                selectInfo.pointIndex = i;
                break;
            }
            /*Select Line*/
            else if (HandleUtility.DistanceToLine(pointsPos.nodePosition[i], nextPoint) < 3f)
            {
                if (i == pointsPos.nodePosition.Count - 1 && !pointsPos.loop)
                    continue;
                selectInfo.lineIndex = i;
                selectInfo.pointIndex = -1;
                break;
            }
            /*Reset selected*/
            else
            {
                selectInfo.lineIndex = -1;
                selectInfo.pointIndex = -1;
            }
        }
        Repaint();
        needRepaint = true;
    }

    /*AppMode - AddPoints*/
    private void AppPoint(Event guiEvent)
    {
        Undo.RecordObject(pointsPos, "Add Point");
        Ray mouseRay = HandleUtility.GUIPointToWorldRay(guiEvent.mousePosition);
        RaycastHit hit;
        float dstToDraw = (0 - mouseRay.origin.y) / mouseRay.direction.y;
        Vector3 point = mouseRay.GetPoint(dstToDraw);
        if (Physics.Raycast(mouseRay, out hit, 1000))
        {
            point = hit.point;
        }
        pointsPos.nodePosition.Insert(pointsPos.nodePosition.Count, point);
        selectInfo.pointIndex = pointsPos.nodePosition.Count - 1;
        selectInfo.lineIndex = -1;

        needRepaint = true;
    }

    public class SelectInfo
    {
        public int pointIndex = -1;
        public int lineIndex = -1;
    }
}
