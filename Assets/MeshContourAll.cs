using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshContourAll : MonoBehaviour {
    private Mesh mesh;
    private Vector3[] vertices;
    private Vector3[] normals;
    private int[] triangles;


    private Vector3 camPos;
    private Quaternion camRot;
    //private LineRenderer lr;

    private List<Vector3> drawVertexList;
    private LineRenderer lr;

   
    // Use this for initialization
    void Start () {

        mesh = this.GetComponent<SkinnedMeshRenderer>().sharedMesh;
        vertices = mesh.vertices;
        normals = mesh.normals;
        triangles = mesh.triangles;


        drawVertexList = new List<Vector3>();


        lr = this.GetComponent<LineRenderer>();
        //lr = this.transform.Find("line").GetComponent<LineRenderer>();

        lr.positionCount = vertices.Length;//drawvertexlist.count/2;
        int i = 0;
        foreach (Vector3 v in vertices)
        {

            lr.SetPosition(i, v);
            i++;
        }
    }

    // Update is called once per frame
    void Update () {
		
	}
}
