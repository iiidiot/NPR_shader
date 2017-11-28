using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class SetShaderGUI : MonoBehaviour
{
	public Renderer[] meshes;
	public Shader shader;
	public float thickness = 0.000005f;

	public void Update()
	{
		SetOutlineThick();
	}

	public void SelectMeshes()
	{
		var obj = Selection.activeGameObject;
		Debug.Log(obj.name);
		if (!obj) return;
		meshes = obj.GetComponentsInChildren<Renderer>();
		Selection.selectionChanged -= SelectMeshes;
	}

	public void SelectAll()
	{
		meshes = GameObject.FindObjectsOfType<Renderer>();  // only active loaded objs
	}

	public void ClearMeshes()
	{
		meshes = null;
	}

	public void SetShader()
	{
		if (meshes == null) return;
		foreach (var mesh in meshes)
		{
			if (mesh != null)
			{
				foreach (var mat in mesh.materials)
				{
					if (mat != null)
					{
						mat.shader = shader;
					}
				}
			}
		}
	}

	public void SetOutlineThick()
	{
		if (meshes == null) return;
		Vector3 cam = Camera.main.transform.position;
		foreach (var mesh in meshes)
		{
			if (mesh != null)
			{
				float d = (mesh.transform.position - cam).magnitude;
				float thick = thickness * d * d;
				foreach (var mat in mesh.materials)
				{
					if (mat != null)
					{
						mat.SetFloat("_Outline", thick);
					}
				}
			}
		}
	}
}
