using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SetShaderGUI)), CanEditMultipleObjects]
public class SetShader : Editor
{
	public override void OnInspectorGUI()
	{

		DrawDefaultInspector();

		SetShaderGUI myScript = (SetShaderGUI)target;
		if (GUILayout.Button("Select Meshes of Next GameObject"))
		{
			Selection.selectionChanged += myScript.SelectMeshes;
		}
		if (GUILayout.Button("Select All Meshes in Scene"))
		{
			myScript.SelectAll();
		}
		if (GUILayout.Button("Clear Meshes"))
		{
			myScript.ClearMeshes();
		}
		if (GUILayout.Button("Set Shader"))
		{
			myScript.SetShader();
		}
	}
}
