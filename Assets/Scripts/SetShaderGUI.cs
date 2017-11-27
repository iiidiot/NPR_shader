using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class SetShaderGUI : MonoBehaviour {
	public Renderer[] meshes;
	public Shader shader;

	public void SelectMeshes(){
		var obj = Selection.activeGameObject;
		Debug.Log(obj.name);
		if(!obj) return;
		meshes = obj.GetComponentsInChildren<Renderer>();
		Selection.selectionChanged -= SelectMeshes;
	}

	public void SelectAll(){
		meshes = GameObject.FindObjectsOfType<Renderer>();	// only active loaded objs
	}

	public void ClearMeshes(){
		meshes = null;
	}

	public void SetShader(){
		if(meshes == null) return;
		foreach(var mesh in meshes){
			foreach(var mat in mesh.sharedMaterials){
				mat.shader = shader;
			}
		}
	}
}
