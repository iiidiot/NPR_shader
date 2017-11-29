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

        int i;
        for (i = 0; i < triangles.Length; i = i+3)
        {
            GameObject newLine = Instantiate(Resources.Load("Line")) as GameObject;
            newLine.transform.SetParent(this.transform);
            newLine.transform.rotation = Quaternion.Euler(Vector3.zero);
            newLine.transform.localEulerAngles = Vector3.zero;
            newLine.transform.localScale = new Vector3(1, 1, 1);
            LineRenderer lr = newLine.GetComponent<LineRenderer>();
            lr.useWorldSpace = false;
            lr.startWidth = 0.001f;
            lr.endWidth = 0.001f;
            lr.positionCount = 3;
            lr.SetPosition(0, vertices[triangles[i]]);
            lr.SetPosition(1, vertices[triangles[i + 1]]);
            lr.SetPosition(2, vertices[triangles[i + 2]]);
        }


        //lr = this.GetComponent<LineRenderer>();
        ////lr = this.transform.Find("line").GetComponent<LineRenderer>();

        //lr.positionCount = vertices.Length;//drawvertexlist.count/2;
        //int i = 0;
        //foreach (Vector3 v in vertices)
        //{

        //    lr.SetPosition(i, v);
        //    i++;
        //}
    }

    // Update is called once per frame
    void Update () {
		
	}
}
