// ****************************************************************************
//<copyright file=Geosim_Decal_Opaque company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Geosim/x/Decal/Geosim_Decal_Opaque"
{
	Properties
	{
		cDiffuseMap("Diffuse", 2D) = "white" {}
		cBumpMap("Bump", 2D) = "bump" {}
		cMaskMap("Specular", 2D) = "white" {}
		//  		cReflMap 		("Reflection", Cube) = "_Skybox"{}
				cDetailMap("Detail", 2D) = "black" {}

				cSpecColor("Specular Color", Color) = (1,1,1,1)
				cDetailColor("Detail Color", Color) = (1,1,1,1)
				cBlendColor1("Blending Color 1", Color) = (1,1,1,1)
				cBlendColor2("Blending Color 2", Color) = (1,1,1,1)

				cPack0("cBumpAmount,cSpecularLevel,cSpecGlossiness,cBlendFunc", Vector) = (1,0.33,1,0)
				cPack1("cReflAmount,cReflrPerturb,cDetailFunc,-", Vector) = (0,0,2,1)
	}

	SubShader
	{
		// Must be before transparent queue in order to receive shadows.
		Tags{ "Queue" = "AlphaTest+9" "IgnoreProjector" = "True" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True" }
		offset -1, -1
		CGPROGRAM
		#pragma target 3.0 
		// Issue: In Unity 2018 decal:blend prevents shadows to be cast over.
		#pragma surface SurfaceOpaque PhongGeosim vertex:VertOpaque decal:blend  exclude_path:prepass noforwardadd noshadow novertexlights nolightmap 
		#pragma shader_feature UVDERAIL
		#define GEOSIM_SURFACE_SHADERS 1
		#define SURFACE_INPUT_FULL 1 
		#define GEOSIM_USE_REFLECTIONS 1
		#pragma shader_feature __ USE_UNITY_GI

		#include "../../Common/Functions.cginc"   

		sampler2D 	cDiffuseMap;
		sampler2D 	cBumpMap;
		sampler2D 	cMaskMap;
		sampler2D 	cDetailMap;

		half4	  	cSpecColor;
		half4 		cBlendColor1;
		half4 		cBlendColor2;
		half4 		cDetailColor;
		
		void VertOpaque(inout appdata_full v, out Input o)
		{
			VertexFull(v, o);
		}

		// -----------------------------------------------------------------------------
		void SurfaceOpaque(Input IN, inout GSSurfaceOutput o)
		{
			half4 vMask;
			AlbedoBlendedFunc(IN.oTexcoord0, cPack0.w, cDiffuseMap, cBlendColor1, cBlendColor2, o);
			o.Alpha *= 0.5;
#if UVDERAIL
			DetailFunc(IN.oTexcoord1, cDetailColor, IN.color.a, cDetailMap, o);
#endif
			ModulateVetexColorFunc(IN.color, o);
			BumpFunc(IN.oTexcoord0, cBumpMap, cPack0.x, o);
			MaskFunc(IN.oTexcoord0, cMaskMap, vMask);
			SpecularFunc(cSpecColor, vMask, o);
		}
		ENDCG
	}
	FallBack "Legacy Shaders/Diffuse"
}
