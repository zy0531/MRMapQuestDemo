using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SaveRenderTexture : MonoBehaviour
{
    [SerializeField]
    Camera cam;

    public string file;
    public RenderTexture rt;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.M))
        {  
            SaveTexture();
            Debug.Log("Texture was saved from Render Texture.");
        }
    }

    //// Use this for initialization
    //public void SaveTexture()
    //{
    //    byte[] bytes = toTexture2D(rt).EncodeToPNG();
    //    System.IO.File.WriteAllBytes(file, bytes); //C:/Users/egsha/SavedScreen.png
    //}
    //Texture2D toTexture2D(RenderTexture rTex)
    //{
    //    Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.ARGB32, false);
    //    RenderTexture.active = rTex;
    //    tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
    //    tex.Apply();
    //    Destroy(tex);//prevents memory leak
    //    return tex;
    //}


    //https://gamedev.stackexchange.com/questions/184785/saving-png-from-render-texture-results-in-much-darker-image
    public void SaveTexture()
    {
        RenderTexture mRt = new RenderTexture(rt.width, rt.height, rt.depth, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
        mRt.antiAliasing = rt.antiAliasing;

        var tex = new Texture2D(mRt.width, mRt.height, TextureFormat.ARGB32, false);
        cam.targetTexture = mRt;
        cam.Render();
        RenderTexture.active = mRt;

        tex.ReadPixels(new Rect(0, 0, mRt.width, mRt.height), 0, 0);
        tex.Apply();

        var path = file;
        System.IO.File.WriteAllBytes(path, tex.EncodeToPNG());
        Debug.Log("Saved file to: " + path);

        DestroyImmediate(tex);

        cam.targetTexture = rt;
        cam.Render();
        RenderTexture.active = rt;

        DestroyImmediate(mRt);
    }

}
