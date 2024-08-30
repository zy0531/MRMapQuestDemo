using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClearRenderTexture : MonoBehaviour
{
    [SerializeField] RenderTexture mapRenderTexture;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.C))
        {
            ClearOutRenderTexture(mapRenderTexture);
        }
    }

    public void ClearOutRenderTexture(RenderTexture renderTexture)
    {
        RenderTexture rt = RenderTexture.active;
        RenderTexture.active = renderTexture;
        GL.Clear(true, true, Color.clear);
        RenderTexture.active = rt;
    }
}
