using UnityEngine;
using System.Collections;

// You can try using ExecuteInEditMode, although that's asking for trouble
// (remember to use DestroyImmediate, sharedMaterial, with all it's consequences)
//[ExecuteInEditMode()]

public class RenderCubeMap : MonoBehaviour {
	// Example based on http://docs.unity3d.com/ScriptReference/Camera.RenderToCubemap.html
	// Simplified as much as possible.
		
	int cubemapSize = 128;
	private Camera cam;
	private RenderTexture rtex;
	
	void Start () {
		// render all six faces at startup
		UpdateCubemap( 63 );
	}
	
	void LateUpdate () {
		UpdateCubemap (63); // all six faces
	}
	
	void UpdateCubemap (int faceMask) 
	{
		if (rtex == null) {	
			rtex = new RenderTexture (cubemapSize, cubemapSize, 16);
			rtex.isCubemap = true;
			rtex.hideFlags = HideFlags.HideAndDontSave;
		}
		
		if (cam == null) {
			cam = gameObject.AddComponent<Camera>();
			cam.farClipPlane = 100; // don't render very far into cubemap
			cam.enabled = false;
		}

		cam.transform.position = transform.position;
		cam.RenderToCubemap (rtex, faceMask);

		// do something with rtex
		GameObject.Find("Plane").GetComponent<Renderer>().material.SetTexture("_Cube", rtex);
	}
	
	void OnDisable () {
		Destroy (cam);
		Destroy (rtex);
	}
}
