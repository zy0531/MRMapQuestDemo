using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

[CustomEditor(typeof(LineGenerator))]
public class LineGeneratorEditor : PointsEditor {

    LineGenerator lineGen; //variable class LineGenerator

    ReorderableList listGUI; //variable ReorderableList for list

    bool showConstraints;

    protected override void OnEnable()
    {
        base.OnEnable();
        if (target == null)
            return;
        lineGen = (LineGenerator)target;

        listGUI = new ReorderableList(serializedObject, serializedObject.FindProperty("addedObjects"), true, true, true, true);
        listGUI.drawElementCallback = BuildGUI;
        listGUI.drawHeaderCallback = BuildTitle;
    }

    /*GUI List*/
    void BuildGUI(Rect rect, int index, bool  isActive, bool isFocused)
    {
        var element = listGUI.serializedProperty.GetArrayElementAtIndex(index);
        float padding;
        rect.y += 2;
        EditorGUI.PropertyField(new Rect(rect.x, rect.y, padding = rect.width - 50, EditorGUIUtility.singleLineHeight),
        element.FindPropertyRelative("Prefab"), GUIContent.none);
        EditorGUI.PropertyField(new Rect(padding + 41, rect.y, 40, EditorGUIUtility.singleLineHeight),
        element.FindPropertyRelative("Percent"), GUIContent.none);
    }

    /*Title List*/
    void BuildTitle(Rect rect)
    {
        EditorGUI.LabelField(rect, "Added Objects");
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        serializedObject.Update();

        GUILayout.BeginVertical("Box");
        GUI.skin.label.alignment = TextAnchor.MiddleCenter;
        GUILayout.Label("Generator");
        lineGen.IntervalBetPoints = EditorGUILayout.Toggle("Calcul two point:", lineGen.IntervalBetPoints); //Type intervals
        lineGen.Interval = EditorGUILayout.FloatField("Interval:", lineGen.Interval); //generation interval
        lineGen.typePosAndRot =(TypePosAndRot)EditorGUILayout.EnumPopup("Type Pos and Rot:", lineGen.typePosAndRot); //position and rotation of the object
        lineGen.typeOrder = (TypeOrder)EditorGUILayout.EnumPopup("Order:", lineGen.typeOrder); //type of generation order

        EditorGUI.indentLevel++;
        showConstraints = EditorGUILayout.Foldout(showConstraints, "Constraints");
        EditorGUI.indentLevel--;
        if (showConstraints)
        {
            
            GUIFreezeRotAndPos();
            
        }

        listGUI.DoLayoutList(); //List object
        serializedObject.ApplyModifiedProperties();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Generator")) //Button generation
        {
            Undo.RecordObject(lineGen, "Generator");
            lineGen.Generator();
        }
        if (GUILayout.Button("AllDelete")) //Button destroy all object
        {
            Undo.RecordObject(lineGen, "Delete");
            lineGen.AllDelete();
        }
        GUILayout.EndHorizontal();
        GUILayout.EndVertical();
    }

    private void GUIFreezeRotAndPos()
    {
        GUILayout.BeginVertical();

        GUI.skin.label.alignment = TextAnchor.MiddleLeft;

        GUILayout.BeginHorizontal();
        GUILayout.Space(20);
        GUILayout.Label("Freeze Rotation");
        lineGen.constraints.RotX = GUILayout.Toggle(lineGen.constraints.RotX, "X");
        lineGen.constraints.RotY = GUILayout.Toggle(lineGen.constraints.RotY, "Y");
        lineGen.constraints.RotZ = GUILayout.Toggle(lineGen.constraints.RotZ, "Z");
        GUILayout.EndHorizontal();

        GUILayout.EndVertical();
    }
}
