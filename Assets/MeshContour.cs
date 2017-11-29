using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class MeshContour : MonoBehaviour
{
    
    private Mesh mesh;
    private Vector3[] vertices;
    private Vector3[] normals;
    private int[] triangles;


    private Vector3 camPos;
    private Quaternion camRot;
    //private LineRenderer lr;

    private List<Vector3> drawVertexList;


    private Matrix4x4 model2CameraMatrix;
    private Vector3 cameraFace = new Vector3(0, 0, -1);


    private bool doDraw;

    Vector3 Model2Camera(Vector3 m)
    {
        Vector4 n1_m_4 = new Vector4(m.x, m.y, m.z, 1);
        Vector4 n1_c_4 = model2CameraMatrix * n1_m_4;
        Vector3 n1_c = new Vector3(n1_c_4.x, n1_c_4.y, n1_c_4.z);
        return n1_c;
    }

    // Use this for initialization
    void Start()
    {
        mesh = this.GetComponent<SkinnedMeshRenderer>().sharedMesh;
        vertices = mesh.vertices;
        normals = mesh.normals;
        triangles = mesh.triangles;


        drawVertexList = new List<Vector3>();




        // line renderer set-up
        //lr = this.GetComponent<LineRenderer>();
        //lr = this.transform.Find("Line").GetComponent<LineRenderer>();



        //lr.positionCount = vertices.Length;//drawVertexList.Count/2;
        //i = 0;
        //foreach (Vector3 v in vertices)
        //{

        //   lr.SetPosition(lr.positionCount-1, v);
        //   lr.positionCount++;
        //}

        camPos = Camera.main.transform.position;
        camRot = Camera.main.transform.rotation;
        doDraw = true;
    }



    private void OnPostRender()
    {

    }


    // Update is called once per frame
    void Update()
    {
        int i; 
        if (camPos == Camera.main.transform.position && camRot == Camera.main.transform.rotation)
        {
            if(doDraw)
            {
                for (i = 0; i < drawVertexList.Count; i = i + 2)
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
                    lr.positionCount = 2;
                    lr.SetPosition(0, drawVertexList[i]);
                    lr.SetPosition(1, drawVertexList[i + 1]);
                }
                doDraw = false;
            }
            return;
        }

        
        camPos = Camera.main.transform.position;
        camRot = Camera.main.transform.rotation;

        model2CameraMatrix = Camera.main.worldToCameraMatrix * transform.localToWorldMatrix;

        drawVertexList.Clear();
        int j;
        List<int> tri1 = new List<int>();
        bool doJudgeNorm;
        int v1 = 0, v2 = 0;
        int ev1 = 0, ev2 = 0;
        for (i = 0; i < triangles.Length / 3; i++)
        {
            tri1.Add(triangles[i]);
            tri1.Add(triangles[i + 1]);
            tri1.Add(triangles[i + 2]);
            for (j = 0; j < i; j++)
            {
                doJudgeNorm = false;
                if (tri1.Remove(triangles[j])) // has j
                {
                    ev1 = triangles[j];
                    if (tri1.Remove(triangles[j + 1])) // has j+1
                    {
                        // j~j+1 is common edge, judge (j+2)'s norm and tri1[0]'s norm
                        doJudgeNorm = true;
                        v1 = triangles[j + 2];
                        v2 = tri1[0];
                        
                        ev2 = triangles[j + 1];
                    }
                    else if (tri1.Remove(triangles[j + 2]))
                    {
                        // j~j+2 is common edge, judge (j+1)'s norm and tri1[0]'s norm 
                        doJudgeNorm = true;
                        v1 = triangles[j + 1];
                        v2 = tri1[0];
                        
                        ev2 = triangles[j + 2];
                    }
                    else
                    {
                        tri1.Add(triangles[j]);
                    }
                }
                else if (tri1.Remove(triangles[j + 1])) // has j+1
                {
                    ev1 = triangles[j + 1];
                    if (tri1.Remove(triangles[j + 2]))
                    {
                        // j+1~j+2 is common edge, judge (j)'s norm and tri1[0]'s norm 
                        doJudgeNorm = true;
                        v1 = triangles[j];
                        v2 = tri1[0];
                        ev2 = triangles[j + 2];
                    }
                    else
                    {
                        tri1.Add(triangles[j + 1]);
                    }
                }
                if (doJudgeNorm)
                {
                    if (Vector3.Dot(Model2Camera(normals[v1]), cameraFace) * Vector3.Dot(Model2Camera(normals[v2]), cameraFace) < 0)
                    {
                        //draw edge v1~v2
                        drawVertexList.Add(vertices[ev1]);
                        drawVertexList.Add(vertices[ev2]);
                    }

                }
                j = j + 3;
            }
            i = i + 3;
            tri1.Clear();
        }
        doDraw = true;

        for (i = 0; i < this.transform.childCount; i++)
        {
            DestroyImmediate(transform.GetChild(i).gameObject);
        }

        

    }
}
