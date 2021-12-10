using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scr_Interact : MonoBehaviour
{
    public Shader standardShader;
    public Shader outlineShader;


    // Start is called before the first frame update
    void Start()
    {
        outlineShader = outlineShader;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {    
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            
            if(Physics.Raycast(ray,out hit,1000.0f))
            {
                Transform parent  = hit.collider.gameObject.transform;
                for (int i = 0; i < parent.childCount; i++)
                {
                    GameObject childObj = hit.collider.gameObject;
                    childObj.GetComponent<Renderer>().sharedMaterial.shader = standardShader; 
                    
                }
                GameObject gameObj = hit.collider.gameObject;
                Material mat = gameObj.GetComponent<Renderer>().material;
                mat.shader = outlineShader;
                mat.SetFloat("_Outline",0.1f);
            }
        }
    }
}
