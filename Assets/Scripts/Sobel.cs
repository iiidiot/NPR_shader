using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sobel : MonoBehaviour {
	public Material m;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture){  

			Graphics.Blit(sourceTexture, destTexture, m);  

	}  
}
