using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
	public float speed = 5.0f;
	public float rotationSpeed = 100.0f;
	void Update()
	{
		float tV, tH, rV, rH;
		tV = tH = rV = rH = 0;
		if (Input.GetKey(KeyCode.W))
		{
			tV += 1;
		}
		if (Input.GetKey(KeyCode.S))
		{
			tV -= 1;
		}
		if (Input.GetKey(KeyCode.A))
		{
			tH -= 1;
		}
		if (Input.GetKey(KeyCode.D))
		{
			tH += 1;
		}
		if (Input.GetKey(KeyCode.UpArrow))
		{
			rV -= 1;
		}
		if (Input.GetKey(KeyCode.DownArrow))
		{
			rV += 1;
		}
		if (Input.GetKey(KeyCode.LeftArrow))
		{
			rH -= 1;
		}
		if (Input.GetKey(KeyCode.RightArrow))
		{
			rH += 1;
		}
		tV *= speed * Time.deltaTime;
		tH *= speed * Time.deltaTime;
		rV *= rotationSpeed * Time.deltaTime;
		rH *= rotationSpeed * Time.deltaTime;
		transform.Translate(tH, 0, tV);
		transform.Rotate(rV, rH, 0);
		var angle = transform.rotation.eulerAngles;
		angle.z = 0;
		transform.rotation = Quaternion.Euler(angle);
	}
}
