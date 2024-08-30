// ****************************************************************************
//<copyright file=Geosim_Uber_Opaque_Interior company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
Shader "Geosim/x/Uber/Geosim_Uber_Opaque_Interior"
{
	Properties
	{
		cDiffuseMap("Diffuse", 2D) = "white" {}
		cBumpMap("Bump", 2D) = "bump" {}
		cMaskMap("Specular", 2D) = "white" {}
		cDetailMap("Detail", 2D) = "black" {}
		cLightMap("Lightmap", 2D) = "white" {}

		cSpecColor("Specular Color", Color) = (1,1,1,1)
		cDetailColor("Detail Color", Color) = (1,1,1,1)
		cBlendColor1("Blending Color 1", Color) = (1,1,1,1)
		cBlendColor2("Blending Color 2", Color) = (1,1,1,1)

		cPack0("cBumpAmount,cSpecularLevel,cSpecGlossiness,cBlendFunc", Vector) = (1,0.33,1,0)
		cPack1("cReflAmount,cReflrPerturb,cDetailFunc,cParallaxAmount", Vector) = (1,0,2,0)
	}

	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" "ForceNoShadowCasting" = "True" }
		CGPROGRAM
			#pragma target 3.0 
			#pragma surface SurfaceOpaque PhongGeosimInterior vertex:VertOpaque noshadow
			#pragma shader_feature PARALLAX
			#pragma shader_feature __ USE_UNITY_GI
			#pragma shader_feature __ USE_UNITY_LIGHTMAPS
			#pragma shader_feature __ _GEOSIM_EXTENSIONS 

			#define GEOSIM_USE_REFLECTIONS 1
			#define GEOSIM_SURFACE_SHADERS 1 
			#define SURFACE_INPUT_LIGHTMAPPED_FULL 1
				
			#include "../../Common/Functions.cginc"   
			
			sampler2D 	cDiffuseMap;
			sampler2D 	cBumpMap;
			sampler2D 	cMaskMap;
			sampler2D 	cLightMap;
			sampler2D 	cDetailMap;

			half4	  	cSpecColor;
			half4 		cBlendColor1;
			half4 		cBlendColor2;
			half4 		cDetailColor;

			void VertOpaque(inout appdata_full v, out Input o)
			{
				VertexFullInterior(v, o);
				GEOSIM_EXT_VERTEX(v, o);
			}

			// -----------------------------------------------------------------------------
			void SurfaceOpaque(Input IN, inout GSSurfaceOutput o)
			{
				half4 vMask;

			#if PARALLAX
					half fHeight = tex2D(cBumpMap ,IN.oTexcoord0).a;
					IN.oTexcoord0.xy += ParallaxOffsetFunc(fHeight, cPack1.w, IN.viewDir);
			#endif
					AlbedoBlendedFunc(IN.oTexcoord0, cPack0.w, cDiffuseMap, cBlendColor1, cBlendColor2,o);
					DetailFunc(IN.oTexcoord1, cDetailColor, IN.color.a, cDetailMap, o);
#if !USE_UNITY_LIGHTMAPS
					Lightmaps(IN.oTexcoord2, cLightMap, o);
					o.Emission = 0.5*o.Albedo;
#endif
					ModulateVetexColorFunc(IN.color,o);
					BumpFunc(IN.oTexcoord0, cBumpMap, cPack0.x, o);
					MaskFunc(IN.oTexcoord0, cMaskMap,vMask);
					SpecularFunc(cSpecColor,vMask, o);

					GEOSIM_EXT_FRAGMENT(IN, o);
			}
		ENDCG
	}
	FallBack "Legacy Shaders/Diffuse"
}
