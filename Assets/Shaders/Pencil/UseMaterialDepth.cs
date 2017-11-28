using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class UseMaterialDepth : MonoBehaviour 
{
	public Material curMaterial; 
	// Use this for initialization
	void Start () 
	{
		if (curMaterial == null || curMaterial.shader.isSupported == false) 
		{  
			enabled = false;  
		}
	}
	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, curMaterial);
	}
	void OnEnable() 
	{
		//camera.depthTextureMode |= DepthTextureMode.Depth;        
	}
	// Update is called once per frame
	void Update () 
	{
		if(curMaterial==null)
			enabled=false;
	}
}
