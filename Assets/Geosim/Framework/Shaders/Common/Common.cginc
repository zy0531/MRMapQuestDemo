// ****************************************************************************
//<copyright file=Common company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
#ifndef __GEOSIM_UNITY_SHADERS_INCLUDED__
#define __GEOSIM_UNITY_SHADERS_INCLUDED__

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"  
#include "GeosimExt.cginc" 

#define K_TEX_COLOR_MODULATE 		0 
#define K_TEX_COLOR_INV_MODULATE 	1
#define K_TEX_COLOR_BLEND 			2
#define K_TEX_DOUBLE_COLOR_BLEND 	3  

#define K_SRC_ALPHA 				0
#define K_ONE_MINUS_SRC_ALPHA 		1
#define K_DST_ALPHA 				2
#define K_ONE_MINUS_DST_ALPHA 		3 


CBUFFER_START(GeosimPacks)
half4		cPack0;
half4		cPack1;
CBUFFER_END

UNITY_DECLARE_TEXCUBE(Geosim_Sky);

#if !defined(_GEOSIM_EXTENSIONS) // !GEOSIM_EXTENSIONS
struct GSSurfaceOutput
{
	half3 Albedo;
	half3 Ambient;
	half3 Normal;
	half3 Emission;
	half  Specular;
	half3 GlossColor;
	half  Alpha;
	half  Glossiness;
};
struct GSSurfaceOutputNoLight
{
	half3 Albedo;
	half  Alpha;
	half3 Normal;	// Unity wants it bhaaa
	half3 Emission; // Unity wants it bhaaa
};

#	ifdef GEOSIM_SURFACE_SHADERS
#		ifdef SURFACE_VERTEX_INPUT_BASIC
struct appdata
{
	float4 vertex 	: POSITION;
	float3 normal 	: NORMAL;
	float2 texcoord : TEXCOORD0;
	float2 texcoord1: TEXCOORD1;	// For unity lightmaps
	float2 texcoord2: TEXCOORD2;	// For unity GI
	fixed4 color : COLOR;
};
#		elif SURFACE_VERTEX_INPUT_BASIC_TAN
struct appdata
{
	float4 vertex 	: POSITION;
	float3 normal 	: NORMAL;
	float2 texcoord : TEXCOORD0;
	float2 texcoord1: TEXCOORD1;	// For unity lightmaps
	float2 texcoord2: TEXCOORD2;	// For unity GI
	fixed4 color : COLOR;
	float4 tangent 	: TANGENT;
};
#		endif
#		ifdef SURFACE_INPUT_FULL 	// Input keyword is used for surface shaders.
struct Input
{
	float2 oTexcoord0 		: TEXCOORD0;
	float2 oTexcoord1 		: TEXCOORD1;
	float4 color			: COLOR;
	float3 viewDir;
};
#		elif SURFACE_INPUT_LIGHTMAPPED_FULL 	// Lightmapped case
struct Input
{
	float2 oTexcoord0 		: TEXCOORD0;
	float2 oTexcoord1 		: TEXCOORD1;
	float2 oTexcoord2 		: TEXCOORD2;
	float4 color			: COLOR;
	float3 viewDir;
};
#		elif SURFACE_INPUT_FULL_TRANSPARENT 	// Input keyword is used for surface shaders.
struct Input
{
	float2 oTexcoord0 		: TEXCOORD0;
	float2 oTexcoord1 		: TEXCOORD1;
	float  oFaceSign : TEXCOORD2;
	float4 color			: COLOR;
	float3 viewDir;
};
#		elif SURFACE_INPUT_DETAIL 
struct Input
{
	float2 oTexcoord0 		: TEXCOORD0;
	float4 oDetailTexCoor	: TEXCOORD1;
	float4 color			: COLOR;
	float3 viewDir;
	UNITY_SHADOW_COORDS(2)
};
#		elif SURFACE_INPUT_UV_COLOR
struct Input
{
	float2 uvcDiffuseMap	: TEXCOORD0;
	float4 color			: COLOR;
};
#		elif SURFACE_INPUT_SPLAT
struct Input
{
	float4 vTexcoord 			: TEXCOORD0;
	float4 vBuffer0				: TEXCOORD1;
	float4 color				: COLOR;
	INTERNAL_DATA
};
#		elif SURFACE_INPUT_VEGETATION
struct Input
{
	float2 vTexcoord0	: TEXCOORD0;
	float4 vElements 	: TEXCOORD1;
};
#		elif SURFACE_INPUT_LOD3
struct Input
{
	half2 uvcDiffuseMap;
	half NdL;
};
#		elif SURFACE_INPUT_UV
struct Input
{
	float2 uvcDiffuseMap	: TEXCOORD0;
};
#		elif SURFACE_INPUT_CHARACTHER 	// Input keyword is used for surface shaders.
struct Input
{
	float2 uvcDiffuseMap 	: TEXCOORD0;
	float4 vElements 		: TEXCOORD1;
	float4 color			: COLOR;
	float3 viewDir;
	INTERNAL_DATA
		UNITY_SHADOW_COORDS(2)
};
#		elif SURFACE_INPUT_TRANSLUCENT
struct Input
{
	float4 vTexcoord 		: TEXCOORD0;
	float2 vElements		: TEXCOORD1;
	float4 color			: COLOR;
};
#		elif SURFACE_INPUT_FLUIDS 	
struct Input
{
	float4 vTexcoord0 		: TEXCOORD0;
	float4 vTexcoord1 		: TEXCOORD1;
	float4 color			: COLOR;
	INTERNAL_DATA
		float3 worldNormal;
	float3 viewDir;
};
#			elif SURFACE_INPUT_CLOUDS
struct Input
{
	float4 vTexcoord0 : TEXCOORD0;
	float4 vFormation : TEXCOORD1;
	float4 color 	  : COLOR;
};
#			elif SURFACE_INPUT_FAKE_INTERIOR 	// Input keyword is used for surface shaders.
struct Input
{
	float2 oTexcoord0 		: TEXCOORD0;
	float2 oTexcoord1 		: TEXCOORD1;
	float3 oTexcoord2 		: TEXCOORD2;
	float4 color			: COLOR;
	float3 viewDir;
};
#		endif
#	else // Not Surface
struct VertInFull
{
	float4 vertex 	 	  : POSITION;
	float3 normal 	 	  : NORMAL;
	float4 tangent	 	  : TANGENT;
	float2 texcoord  	  : TEXCOORD0;
	float2 texcoord1  	  : TEXCOORD1;
	float2 texcoord2  	  : TEXCOORD2;
	float4 color	 	  : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct V2FFluids
{
	float4 pos 	          : SV_POSITION;
	float4 oTexcoord0     : TEXCOORD0;
	float3 oNormal 	      : NORMAL;
	float4 oColor		  : COLOR;
	float3 oLightVec	  : TEXCOORD1;
	float3 oWorldTangent  : TEXCOORD2;
	float3 oWorldBinormal : TEXCOORD3;
	float3 oWorldView	  : TEXCOORD4;
	float4 oScreenPos	  : TEXCOORD5;
	float3 worldPos		  : TEXCOORD6;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
		UNITY_FOG_COORDS(7)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		LIGHTING_COORDS(8, 9)
#endif
};
struct V2FFull
{
	float4 pos 	   	  	  : SV_POSITION;
	float4 vTexcoord      : TEXCOORD0;
	float3 vNormal		  : NORMAL;
	float4 vColor		  : COLOR;
	float3 vLightVec	  : TEXCOORD1;
	float3 vTangent  	  : TEXCOORD2;
	float3 vBinormal      : TEXCOORD3;
	float3 vWorldView	  : TEXCOORD4;
	float3 worldPos		  : TEXCOORD5;

	UNITY_FOG_COORDS(6)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		LIGHTING_COORDS(7, 8)
#endif
		UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct VertexSimple
{
	float4 vertex 	 	  : POSITION;
	float3 normal 	 	  : NORMAL;
	float2 texcoord  	  : TEXCOORD0;
	float4 color	 	  : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct V2FSimple
{
	// Unity macros expect pos name
	float4 pos 	   	  	  : SV_POSITION;
	float2 oTexcoord0     : TEXCOORD0;
	float3 worldPos		  : TEXCOORD1;
	UNITY_FOG_COORDS(2)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		LIGHTING_COORDS(3, 4)
#endif

		float3 oNormal		  : NORMAL;
	fixed4 oAlbedo : COLOR0;
	fixed4 oAmbient : COLOR1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};
struct V2FSimpleSpecular
{
	// Unity macros expect pos name
	float4 pos 	   	  	  : SV_POSITION;
	float2 oTexcoord0     : TEXCOORD0;
	UNITY_FOG_COORDS(1)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		UNITY_SHADOW_COORDS(1)
#endif

		float3 oNormal		  : NORMAL;
	fixed4 oAlbedo : COLOR0;
	fixed4 oAmbient : COLOR1;
	fixed3 oWorldViewDir : TEXCOORD2;
	fixed3 oWorldLightDir : TEXCOORD3;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};

struct VertexSimpleNoLight
{
	float4 vertex 	 	  : POSITION;
	float2 texcoord  	  : TEXCOORD0;
	float4 color	 	  : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};
struct V2FSimpleNoLight
{
	// Unity macros expect pos name
	float4 pos 	   	  	  : SV_POSITION;
	float2 oTexcoord0     : TEXCOORD0;
	UNITY_FOG_COORDS(1)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		UNITY_SHADOW_COORDS(1)
#endif
		fixed4 oColor : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};
struct VertexSimpleNoTexcoord
{
	float4 vertex 	 	  : POSITION;
	float3 normal 	 	  : NORMAL;
	float4 color	 	  : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};
struct V2FSimpleNoTexcoord
{
	// Unity macros expect pos name
	float4 pos 	   	  	  : SV_POSITION;
	UNITY_FOG_COORDS(0)
#ifdef GEOSIM_SHADOW_RECEIVE_PASS
		UNITY_SHADOW_COORDS(1)
#endif
		fixed4 oAlbedo : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
};
#endif
#endif //!defined(_GEOSIM_EXTENSIONS)


#endif //__GEOSIM_UNITY_SHADERS_INCLUDED__
