// ****************************************************************************
//<copyright file=Geosim_Uber_TransparentDepth company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
Shader "Geosim/x/Uber/Geosim_Uber_TransparentDepth"
{
	Properties
	{
		cDiffuseMap("Diffuse", 2D) = "white" {}
		cBumpMap("Bump", 2D) = "bump" {}
		cMaskMap("Specular", 2D) = "white" {}
		cDetailMap("Detail", 2D) = "black" {}

		cSpecColor("Specular Color", Color) = (1,1,1,1)
		cDetailColor("Detail Color", Color) = (1,1,1,1)
		cBlendColor1("Blending Color 1", Color) = (1,1,1,1)
		cBlendColor2("Blending Color 2", Color) = (1,1,1,1)

		cPack0("cBumpAmount,cSpecularLevel,cSpecGlossiness,cBlendFunc", Vector) = (1,0.33,1,0)
		cPack1("cReflAmount,cReflrPerturb,cDetailFunc,-", Vector) = (1,0,2,1)
	}

	SubShader
	{
		Tags {"Queue" = "Transparent+3" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True"}
		cull off
		CGPROGRAM
			#pragma target 3.0 
			
			//PhongGeosimTransparentCutout For this shader Unity only used GI for the second pass which
			// made the cutout pass dark. Created a function which force the GI for the cutout pass

			#pragma surface SurfaceCutout PhongGeosimTransparentCutout vertex:VertCutout
			#pragma shader_feature __ _GEOSIM_EXTENSIONS 
			#pragma shader_feature __ USE_UNITY_GI	
			#define GEOSIM_SURFACE_SHADERS 1 
			#define SURFACE_INPUT_FULL 1

			#include "../../Common/Functions.cginc" 

			sampler2D 	cDiffuseMap;
			sampler2D 	cBumpMap;
			sampler2D 	cMaskMap;
			sampler2D 	cDetailMap;

			half4	  	cSpecColor;
			half4 		cBlendColor1;
			half4 		cBlendColor2;
			half4 		cDetailColor;

			void VertCutout(inout appdata_full v, out Input o)
			{
				half3 view = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex));
				half l_Dot = dot(v.normal, view) > 0 ? 0 : 1;
				v.normal = lerp(v.normal, -v.normal, l_Dot);
			
				VertexFull(v, o);
				
				GEOSIM_EXT_VERTEX(v, o);
			}

			// -----------------------------------------------------------------------------
			void SurfaceCutout(Input IN, inout GSSurfaceOutput o)
			{
				half4 vMask;
				AlbedoBlendedFunc(IN.oTexcoord0, cPack0.w, cDiffuseMap, cBlendColor1, cBlendColor2,o);
				clip(o.Alpha - 0.5);
				DetailFunc(IN.oTexcoord1,cDetailColor,IN.color.a,cDetailMap,o);
				o.Albedo *= IN.color.rgb;
				BumpFunc(IN.oTexcoord0, cBumpMap, cPack0.x, o);
				MaskFunc(IN.oTexcoord0, cMaskMap,vMask);
				SpecularFunc(cSpecColor,vMask, o);

				GEOSIM_EXT_FRAGMENT(IN, o);
			}
		ENDCG

		cull off
		zwrite off
		CGPROGRAM
			#pragma target 3.0     
			#pragma surface SurfaceTransparent PhongGeosimTransparent vertex:VertTransparent exclude_path:prepass alpha:fade noshadow
			#pragma shader_feature __ USE_UNITY_GI  
			#pragma shader_feature __ _GEOSIM_EXTENSIONS 
			#define GEOSIM_SURFACE_SHADERS 1
			#define SURFACE_INPUT_FULL_TRANSPARENT 1 
			
			#include "../../Common/Functions.cginc" 
			
			sampler2D 	cDiffuseMap;
			sampler2D 	cBumpMap;
			sampler2D 	cMaskMap;
			sampler2D 	cDetailMap;

			half4	  	cSpecColor;
			half4 		cBlendColor1;
			half4 		cBlendColor2;
			half4 		cDetailColor;

			void VertTransparent(inout appdata_full v, out Input o)
			{
				VertexFull(v, o);
				half3 view = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex));
				half l_Dot = dot(v.normal, view) > 0 ? 0 : 1;
				v.normal = lerp(v.normal, -v.normal, l_Dot);
				
				// Used for faking light penetration. 
				o.oFaceSign = 0.375*l_Dot;
				
				GEOSIM_EXT_VERTEX(v, o);
			}


			// -----------------------------------------------------------------------------
			void SurfaceTransparent(Input IN, inout GSSurfaceOutput o)
			{
				half4 vMask;

				AlbedoBlendedFunc(IN.oTexcoord0, cPack0.w, cDiffuseMap, cBlendColor1, cBlendColor2,o);
				DetailFunc(IN.oTexcoord1,cDetailColor,IN.color.a,cDetailMap,o);
				IN.color.rgb *= 0.5;
				ModulateVetexColorFunc(IN.color,o);
				BumpFunc(IN.oTexcoord0, cBumpMap, cPack0.x, o);
				MaskFunc(IN.oTexcoord0, cMaskMap,vMask);
				SpecularFunc(cSpecColor,vMask, o);
				float  NdV = abs(dot(o.Normal, IN.viewDir));
				float  fresnelTerm = 1.0f - NdV;
				o.Alpha += o.Alpha*lerp(0, 1, fresnelTerm);
				o.Alpha = saturate(o.Alpha);
				
				o.Ambient = IN.oFaceSign;
				GEOSIM_EXT_FRAGMENT(IN, o);
			}
			ENDCG
	}
	Fallback "Legacy Shaders/Transparent/VertexLit"
}
