// ****************************************************************************
//<copyright file=Functions company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#ifndef __GEOSIM_UNITY_SHADERS_FUNCTIONS_INCLUDED__
#define __GEOSIM_UNITY_SHADERS_FUNCTIONS_INCLUDED__

#include "Common.cginc" 

#define SPEED_FACTOR 12.030075
// -----------------------------------------------------------------------------
inline float4x4 LookAtMatrix(float3 Xi_vEye, float3 Xi_vCenter, float3 Xi_vUp)
{
	Xi_vCenter.y = 0;
	Xi_vEye.y = 0;
	float3 vZ_axis = normalize(Xi_vCenter - Xi_vEye);
	float3 vX_axis = normalize(cross(Xi_vUp, vZ_axis));
	float3 vY_axis = cross(vZ_axis, vX_axis);

	float4x4 l_Matrix = { vX_axis.x,vX_axis.y,vX_axis.z,0,
						  vY_axis.x,vY_axis.y,vY_axis.z ,0,
						  vZ_axis.x,vZ_axis.y,vZ_axis.z ,0,
						  0,0,0,1
	};

	////float4x4 l_Matrix = float4x4(float4(vX_axis,0), float4(vY_axis, 0), float4(vZ_axis, 0), float4(0,0,0, 1),
	////
	//l_Matrix[0][0] = vX_axis.x;
	//l_Matrix[1][0] = vX_axis.y;
	//l_Matrix[2][0] = vX_axis.z;
	//l_Matrix[3][0] = 0;
	//
	//l_Matrix[0][1] = vY_axis.x;
	//l_Matrix[1][1] = vY_axis.y;
	//l_Matrix[2][1] = vY_axis.z;
	//l_Matrix[3][1] = 0;
	//
	//l_Matrix[0][2] = vZ_axis.x;
	//l_Matrix[1][2] = vZ_axis.y;
	//l_Matrix[2][2] = vZ_axis.z;
	//l_Matrix[3][2] = 0;
	//
	//l_Matrix[0][3] = 0;
	//l_Matrix[1][3] = 0;
	//l_Matrix[2][3] = 0;
	//l_Matrix[3][3] = 1;

	return (l_Matrix);
}

// -----------------------------------------------------------------------------
inline float4x4 RotationMatrix(float3 Xi_vRight, float3 Xi_vUp, float3 Xi_vForward)
{
	return float4x4(Xi_vRight, 0,
		Xi_vUp, 0,
		Xi_vForward, 0,
		0, 0, 0, 1);
}
// -----------------------------------------------------------------------------
inline fixed GetMipLevel(half2 Xi_UV, half2 Xi_TextureSize)
{
	half2 dx = ddx(Xi_UV * Xi_TextureSize.x);
	half2 dy = ddy(Xi_UV * Xi_TextureSize.y);
	fixed d = max(dot(dx, dx), dot(dy, dy));
	return 0.5 * log2(d); //0.5 is sqrt approx
}
// -----------------------------------------------------------------------------
inline fixed3 UnpackCompNormal(float2 Xi_NormalXY)
{
	fixed3 vNormal;
	vNormal.xy = Xi_NormalXY * 2 - 1.0;
	vNormal.z = sqrt(1 - saturate(dot(vNormal.xy, vNormal.xy)));
	return vNormal;
}
// -----------------------------------------------------------------------------
inline half4 SmoothCurve(half4 x)
{
	return x * x *(3.0 - 2.0 * x);
}
// -----------------------------------------------------------------------------
inline half4 SinCurve(half4 x)
{
	return x * (1.0 - x * x / 3.0);
}
// -----------------------------------------------------------------------------
inline half4 TriangleWave(half4 x)
{
	return abs(frac(x + 0.5) * 2.0 - 1.0);
}
// -----------------------------------------------------------------------------
inline half4 SignedTriangleWave(half4 x)
{
	return abs(frac(x + 0.5) * 2.0 - 1.0) * 2 - 1;
}
// -----------------------------------------------------------------------------
inline half4 SmoothTriangleWave(half4 x)
{
	return SmoothCurve(TriangleWave(x));
}
// -----------------------------------------------------------------------------
inline half4 SmoothSignedTriangleWave(half4 x)
{
	return SmoothCurve(TriangleWave(x)) * 2 - 1;
}

// -----------------------------------------------------------------------------  
inline half3 ToWorldNormal(in half3 Xi_ObjNormal)
{
	// Multiply by transposed inverse matrix, actually using transpose() generates badly optimized code
	return unity_WorldToObject[0].xyz * Xi_ObjNormal.x + unity_WorldToObject[1].xyz * Xi_ObjNormal.y + unity_WorldToObject[2].xyz * Xi_ObjNormal.z;
}

// -----------------------------------------------------------------------------
inline fixed3 unpackNormal(fixed4 v)
{
	return v.xyz * 2.0 - 1.0;
}

// -----------------------------------------------------------------------------
inline void DetailBending(half3 Xi_WorldPos, inout half3 Xio_vPos, half3 Xi_vNormal, half3 Xi_vVertexInfo, half4 Xi_vBendDetailParams)
{
	const half l_fTime = _Time.x*SPEED_FACTOR;

	half l_fSpeed = Xi_vBendDetailParams.w;

	half l_fDetailFreq = Xi_vBendDetailParams.x;
	half l_fDetailLeafAmp = Xi_vBendDetailParams.y;
	half l_fDetailBranchAmp = Xi_vBendDetailParams.z;

	half l_fEdgeAtten = Xi_vVertexInfo.x;
	half l_fBranchPhase = Xi_vVertexInfo.y;
	half l_fBranchAtten = Xi_vVertexInfo.z;

	// Phases (object, vertex, branch)
	half l_fObjPhase = (dot(Xi_WorldPos.xyz, 2));
	l_fBranchPhase += l_fObjPhase;
	half l_fVtxPhase = (dot(Xio_vPos, l_fBranchPhase));

	// Detail bending for leaves/grass
	// x: is used for edges, y is used for branch
	half2 l_vWavesIn = l_fTime;
	l_vWavesIn += half2(l_fVtxPhase, l_fBranchPhase);

	half4 l_vWaves = (frac(l_vWavesIn.xxyy * half4(1.975, 0.793, 0.375, 0.193)) * 2.0 - 1.0) * l_fDetailFreq * l_fSpeed;
	l_vWaves = TriangleWave(l_vWaves);

	// x: is used for edges, y is used for branches
	half2 l_vWavesSum = ((l_vWaves.xz + l_vWaves.yw));

	// Edge and branch bending (xy is used for edges, z for branches)
	Xio_vPos += l_vWavesSum.xxy * half3(l_fEdgeAtten * l_fDetailLeafAmp * Xi_vNormal.xy, l_fBranchAtten * l_fDetailBranchAmp);
}

// -----------------------------------------------------------------------------
inline void MainBending(inout half3 Xio_vPos, half3 Xi_vBendParams)
{
	half fBF = Xio_vPos.z * Xi_vBendParams.z;
	fBF *= fBF;
	Xio_vPos.xz += Xi_vBendParams.xy * fBF;
}
// -----------------------------------------------------------------------------
inline void GeneralMovment(inout half3 Xio_Pos, in half3 Xi_Normal, in half4 Xi_Color,
	in half4 Xi_WavesPhases, in half4 Xi_WaveFreq, in half4 Xi_WaveAmp, in half4 Xi_WaveLevels)
{
	half4 f = (Xio_Pos.x + Xio_Pos.y + Xio_Pos.z) * Xi_WavesPhases * Xi_Color.y;
	f = (f + _Time.x*SPEED_FACTOR*Xi_WaveFreq + Xi_Color.x) * 3.1415926;
	half4 vWaves = sin(f) * Xi_WaveAmp + Xi_WaveLevels;
	Xio_Pos += Xi_Normal.xyz * dot(vWaves, 1) * Xi_Color.z;
}
// -----------------------------------------------------------------------------
inline half3 GetNormal(in half4 Xi_Normal, in half Xi_BumpAmount)
{
	// this is "flat normal" in both DXT5nm and xyz*2-1 cases
	//l_Up = half3(0.5,0.5,1.0)
	const half3 l_Up = half3(0.0, 0.0, 1.0); // When defiend as global, returns unexpected result.

	half3 l_Normal = UnpackNormal(Xi_Normal);
	l_Normal.y = -l_Normal.y;
	l_Normal.xyz = lerp(l_Up, l_Normal, Xi_BumpAmount);

	return l_Normal;
}
// -----------------------------------------------------------------------------
inline half3 Obj2WldNormal(in half3 Xi_Normal)
{
	// Multiply by transposed inverse matrix, actually using transpose() generates badly optimized code
	return (unity_WorldToObject[0].xyz * Xi_Normal.x + unity_WorldToObject[1].xyz * Xi_Normal.y + unity_WorldToObject[2].xyz * Xi_Normal.z);
}

//blending operation on pixel  
// -----------------------------------------------------------------------------
inline void BlendOpOLD(half Xi_BlendingOP, half4 Xi_BlendColor1, half4 Xi_BlendColor2, inout half4 Xio_TextureColor)
{
	fixed3 cond = fixed3(K_TEX_COLOR_MODULATE, K_TEX_COLOR_INV_MODULATE, K_TEX_COLOR_BLEND);
	fixed4 tmp = fixed4(step(fixed3(Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP), cond), 1);
	tmp.w = 1.0 - tmp.z;

	half3 c1 = Xio_TextureColor.rgb * Xi_BlendColor1.rgb;
	half3 c2 = 1 - Xio_TextureColor.rgb*(1 - Xi_BlendColor1.rgb);
	half3 c3 = lerp(Xi_BlendColor1.rgb, Xio_TextureColor.rgb, Xio_TextureColor.a);
	half3 c4 = lerp(c3.rgb, Xi_BlendColor2.rgb, saturate(Xio_TextureColor.a - Xi_BlendColor2.a));
	Xio_TextureColor = half4((c1 * tmp.x) + (c2 *tmp.y*(1.0 - tmp.x)) + (c3*tmp.z*(1.0 - tmp.y)) + (c4*tmp.w * (1.0 - tmp.z)), Xio_TextureColor.a);
}
//blending operation on pixel  
// -----------------------------------------------------------------------------
inline void BlendOp(half Xi_BlendingOP, half4 Xi_BlendColor1, half4 Xi_BlendColor2, inout half4 Xio_TextureColor)
{
	const float4 vConditions = float4(K_TEX_COLOR_MODULATE, K_TEX_COLOR_INV_MODULATE, K_TEX_COLOR_BLEND, K_TEX_DOUBLE_COLOR_BLEND);
	float4 vVal = float4(Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP);

	float4 vMask = step(vVal, vConditions)*step(vConditions, vVal);

	float3 c1 = Xio_TextureColor.rgb * Xi_BlendColor1.rgb;
	float3 c2 = 1 - Xio_TextureColor.rgb*(1 - Xi_BlendColor1.rgb);
	float3 c3 = lerp(Xi_BlendColor1.rgb, Xio_TextureColor.rgb, Xio_TextureColor.a);
	float3 c4 = lerp(c3.rgb, Xi_BlendColor2.rgb, saturate(Xio_TextureColor.a - Xi_BlendColor2.a));
	Xio_TextureColor = float4(vMask.x * c1 + vMask.y * c2 + vMask.z * c3 + vMask.w * c4, Xio_TextureColor.a);
}


// -----------------------------------------------------------------------------
inline void DetailBlendOpOLD(half Xi_BlendingOP, half2 Xi_BlendFactor, out half Xo_Res)
{
	half3 cond = half3(K_SRC_ALPHA, K_ONE_MINUS_SRC_ALPHA, K_DST_ALPHA);
	half4 tmp = half4(step(half3(Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP), cond), 1);
	tmp.w = 1.0 - tmp.z;

	Xo_Res = (Xi_BlendFactor.x * tmp.x) + ((1 - Xi_BlendFactor.x) *tmp.y*(1.0 - tmp.x)) + (Xi_BlendFactor.y*tmp.z*(1.0 - tmp.y)) + ((1 - Xi_BlendFactor.y)*tmp.w * (1.0 - tmp.z));
}
// -----------------------------------------------------------------------------
inline void DetailBlendOp(half Xi_BlendingOP, half2 Xi_BlendFactor, out half Xo_Res)
{
	const float4 vConditions = float4(K_SRC_ALPHA, K_ONE_MINUS_SRC_ALPHA, K_DST_ALPHA, K_ONE_MINUS_DST_ALPHA);
	float4 vVal = float4(Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP, Xi_BlendingOP);
	float4 vMask = step(vVal, vConditions)*step(vConditions, vVal);

	//Xo_Res = (Xi_BlendFactor.x*vMask.x) + ((1 - Xi_BlendFactor.x)*vMask.y) + (Xi_BlendFactor.y*vMask.z) + ((1 - Xi_BlendFactor.y)*vMask.w);
	Xo_Res = dot(float4(Xi_BlendFactor.x, 1 - Xi_BlendFactor.x, Xi_BlendFactor.y, 1 - Xi_BlendFactor.y), vMask);
}
#ifdef GEOSIM_SURFACE_SHADERS
// -----------------------------------------------------------------------------
void VertexFull(inout appdata_full v, out Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);
#if defined (SURFACE_INPUT_FULL ) || defined (SURFACE_INPUT_FULL_TRANSPARENT)
	o.oTexcoord0 = v.texcoord.xy;
	// Unity GI coords override v.texcoord1. Mesh importer set them to v.texcoord2
	o.oTexcoord1 = v.texcoord2.xy;
	//o.oWorldNormal = UnityObjectToWorldDir(v.normal);
	//o.oObjNormal = v.normal;
	//o.oWorldView = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex).xyz);
#endif 
}
// -----------------------------------------------------------------------------
void VertexFullInterior(inout appdata_full v, out Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);
#if defined (SURFACE_INPUT_LIGHTMAPPED_FULL)
	o.oTexcoord0 = v.texcoord.xy;
	// GI is baked in offline process at 3D package. The GI is static, and is accessed by the secondery uvs.
	// Dispite the fact LM used shader does not need to support Unity GI ( As it already has one on a texture )
	// I'm consuming the 3rd uvs, as it reduce issues.
	o.oTexcoord1 = v.texcoord2.xy;
	o.oTexcoord2 = v.texcoord3.xy;
	//o.oWorldNormal = UnityObjectToWorldDir(v.normal);
	//o.oObjNormal = v.normal;
	//o.oWorldView = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex).xyz);
#endif 
}
#endif 


#ifndef GEOSIM_SURFACE_SHADERS

// -----------------------------------------------------------------------------
inline V2FFluids VSFluids(VertInFull v)
{
	UNITY_SETUP_INSTANCE_ID(v);

	V2FFluids Out = (V2FFluids)0;

	UNITY_TRANSFER_INSTANCE_ID(v, Out);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(Out);

	half3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	Out.worldPos = wPos;
	half4 ndcPos = UnityObjectToClipPos(v.vertex);
	Out.pos = ndcPos;
	Out.oNormal = UnityObjectToWorldNormal(v.normal);

	// rbga: To make to flow align with 3dsmax directions. 
	Out.oTexcoord0 = half4(v.texcoord, v.texcoord) + _Time.x * 2 * (v.color.rbga - 0.5) * SPEED_FACTOR;
	Out.oLightVec = UnityWorldSpaceLightDir(wPos);

	Out.oColor = EncodeFloatRGBA(v.texcoord1.x);
	Out.oColor.a = floor(v.texcoord1.x)*0.125;

	half3 l_Binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
	Out.oWorldTangent = UnityObjectToWorldNormal(v.tangent.xyz);
	Out.oWorldBinormal = l_Binormal;

	Out.oWorldView = UnityWorldSpaceViewDir(wPos);
	Out.oScreenPos = ComputeScreenPos(ndcPos);
	Out.oScreenPos.z = v.texcoord1.y;

	return Out;
}
// -----------------------------------------------------------------------------
inline V2FFull VSFull(VertInFull v)
{
	V2FFull Out = (V2FFull)0;

	half3 vWorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	Out.worldPos = vWorldPos;
	Out.pos = UnityObjectToClipPos(v.vertex);;
	Out.vNormal = UnityObjectToWorldNormal(v.normal);
	Out.vTexcoord = half4(v.texcoord, v.texcoord1);
	Out.vLightVec = UnityWorldSpaceLightDir(vWorldPos);
	Out.vColor = v.color;

	half3 vBinormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
	Out.vTangent = UnityObjectToWorldNormal(v.tangent.xyz);
	Out.vBinormal = vBinormal;

	Out.vWorldView = UnityWorldSpaceViewDir(vWorldPos);

	return Out;
}
// -----------------------------------------------------------------------------
inline V2FFull VSFullLightmap(VertInFull v)
{
	V2FFull Out = (V2FFull)0;

	half3 vWorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	Out.worldPos = vWorldPos;
	Out.pos = UnityObjectToClipPos(v.vertex);;
	Out.vNormal = UnityObjectToWorldNormal(v.normal);

	Out.vTexcoord = half4(v.texcoord, v.texcoord2);
	Out.vLightVec = fixed3(0, -1, 0); // Assume indoored
	Out.vColor = v.color;

	half3 vBinormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
	Out.vTangent = UnityObjectToWorldNormal(v.tangent.xyz);
	Out.vBinormal = vBinormal;

	Out.vWorldView = UnityWorldSpaceViewDir(vWorldPos);

	return Out;
}
#endif

// -----------------------------------------------------------------------------  
inline void AlbedoBlendedFunc(in half2 Xi_Texcoord, half Xi_AlbedoBlendingOp, in sampler2D Xi_DiffuseMap, half4 Xi_BlendColor1, half4 Xi_BlendColor2, inout GSSurfaceOutput Xio_Surface)
{
	half4 l_Albedo = tex2D(Xi_DiffuseMap, Xi_Texcoord);
	BlendOp(Xi_AlbedoBlendingOp, Xi_BlendColor1, Xi_BlendColor2, l_Albedo);
	Xio_Surface.Albedo = l_Albedo.rgb;
	Xio_Surface.Alpha = l_Albedo.a;
}
// -----------------------------------------------------------------------------  
inline void AlbedoFunc(in half2 Xi_Texcoord, in sampler2D Xi_DiffuseMap, half4 Xi_BlendColor1, inout GSSurfaceOutput Xio_Surface)
{
	half4 l_Albedo = tex2D(Xi_DiffuseMap, Xi_Texcoord);
	Xio_Surface.Albedo = l_Albedo.rgb * Xi_BlendColor1.rgb;
	Xio_Surface.Alpha = l_Albedo.a * Xi_BlendColor1.a;
}

// -----------------------------------------------------------------------------  
inline void ModulateVetexColorFunc(in half4 Xi_Color, inout GSSurfaceOutput Xio_Surface)
{
	Xio_Surface.Albedo *= Xi_Color.rgb;
	Xio_Surface.Alpha *= Xi_Color.a;
}
// -----------------------------------------------------------------------------   
inline void AmbientFunc(half3 Xi_Color, inout GSSurfaceOutput Xio_Surface)
{
	Xio_Surface.Ambient = Xi_Color;
}

// -----------------------------------------------------------------------------
inline half2 ParallaxOffsetFunc(in half Xi_Height, in half Xi_HeightAmount, in half3 Xi_ViewDir)
{
	Xi_Height = Xi_Height * Xi_HeightAmount - Xi_HeightAmount * 0.5;
	Xi_ViewDir.z += 0.42;
	return Xi_Height * (Xi_ViewDir.xy / Xi_ViewDir.z);
}
// -----------------------------------------------------------------------------
inline void BumpFunc(in half2 Xi_vTexcoord, in sampler2D Xi_BumpMap, in half Xi_fAmount, inout GSSurfaceOutput Xio_Surface)
{
	Xio_Surface.Normal = normalize(GetNormal(tex2D(Xi_BumpMap, Xi_vTexcoord), Xi_fAmount));
}
// -----------------------------------------------------------------------------
inline void BumpFunc(in half2 Xi_vTexcoord, in half3 Xi_vTangent, in half3 Xi_vBinormal, in half3 Xi_vWorldNormal, in half Xi_fBumpAmount, in sampler2D Xi_BumpMap, out half3 Xo_WorldBump)
{
	half3 vBump = GetNormal(tex2D(Xi_BumpMap, Xi_vTexcoord), Xi_fBumpAmount);
	Xo_WorldBump = normalize(vBump.x * Xi_vTangent - vBump.y * Xi_vBinormal + vBump.z * Xi_vWorldNormal);
}
// -----------------------------------------------------------------------------
inline void Bump2Normals(in half3 Xi_WorldTangent, in half3 Xi_WorldBinormal, in half3 Xi_wNormal, in half2 Xi_Bump1, in half2 Xi_Bump2, in half Xi_BumpAmount, inout GSSurfaceOutput Xio_Surface)
{
	// x1y1x2y2 bump1,bump2
	fixed4 vBuffer = fixed4(Xi_Bump1, Xi_Bump2);

	vBuffer = 2 * vBuffer - 1;
	// 1-sqrt(x^2 + y^2).
	fixed2 vZ = sqrt(1 - saturate(fixed2(dot(vBuffer.xy, vBuffer.xy), dot(vBuffer.zw, vBuffer.zw))));

	// Whiteout blending
	float3 vBump = float3(vBuffer.xy + vBuffer.zw, vZ.x*vZ.y);

	fixed3 vWorldSpaceBump = (vBump.x  * Xi_WorldTangent - vBump.y  * Xi_WorldBinormal) + vBump.z  * Xi_wNormal;

	// T,B,N and Bump are not normalize. Normalize the sum to save instructions.
	Xio_Surface.Normal = normalize(lerp(Xi_wNormal, vWorldSpaceBump, Xi_BumpAmount));
}

// -----------------------------------------------------------------------------
half3 Bump2Normals_RNM(in half2 Xi_N1, in half2 Xi_N2)
{
	half4 vBuffer = half4(Xi_N1, Xi_N2);
	vBuffer = half4(2, 2, -2, -2)*vBuffer + half4(-1, -1, 1, 1);
	// 1-sqrt(x^2 + y^2).
	half2 vZ = sqrt(1 - saturate(fixed2(dot(vBuffer.xy, vBuffer.xy), dot(vBuffer.zw, vBuffer.zw))));


	half3 t = half3(vBuffer.xy, vZ.x + 1);
	half3 u = half3(vBuffer.zw, vZ.y);
	half3 r = t * dot(t, u) - u * t.z;
	return r; // Caller need to normalize 
	//return normalize(r);
}
// -----------------------------------------------------------------------------
void Bump2Normals_RNM(in half3 Xi_WorldTangent, in half3 Xi_WorldBinormal, in half3 Xi_wNormal, in half2 Xi_N1, in half2 Xi_N2, in half Xi_BumpAmount, inout GSSurfaceOutput Xio_Surface)
{
	half4 vBuffer = half4(Xi_N1, Xi_N2);
	vBuffer = half4(2, 2, -2, -2)*vBuffer + half4(-1, -1, 1, 1);
	// 1-sqrt(x^2 + y^2).
	half2 vZ = sqrt(1 - saturate(fixed2(dot(vBuffer.xy, vBuffer.xy), dot(vBuffer.zw, vBuffer.zw))));

	half3 t = half3(vBuffer.xy, vZ.x + 1);
	half3 u = half3(vBuffer.zw, vZ.y);
	half3 r = t * dot(t, u) - u * t.z;

	fixed3 vWorldSpaceBump = (r.x  * Xi_WorldTangent - r.y  * Xi_WorldBinormal) + r.z  * Xi_wNormal;

	// T,B,N and Bump are not normalize. Normalize the sum to save instructions.
	Xio_Surface.Normal = normalize(lerp(Xi_wNormal, vWorldSpaceBump, Xi_BumpAmount));
}
// -----------------------------------------------------------------------------
float3 Bump2Normals_RNM_BC5(in half2 Xi_N1, in half2 Xi_N2) // DXT5
{
	float3 t = float3(Xi_N1 * 2 - 1, 1);
	float3 u = float3(-2 * Xi_N2 + 1, 1);
	float q = dot(t, t);
	float s = sqrt(q);
	t.z += s;
	float3 r = t * dot(t, u) - u * (q + s);
	return normalize(r);
}
// -----------------------------------------------------------------------------
inline void BumpSplatFunc(in float2 Xi_UV0, in float2 Xi_UV1, in float2 Xi_UV2, in float2 Xi_UV3, in float Xi_Mipmap, in float4 Xi_BumpAmounts, in sampler2D Xi_BumpMap, inout GSSurfaceOutput Xio_Surface)
{
	Xi_BumpAmounts *= cPack0.x; // Mult the bump scale with the global bump factor.
	half3 vBump0 = GetNormal(tex2Dlod(Xi_BumpMap, half4(Xi_UV0, 0, Xi_Mipmap)), Xi_BumpAmounts.x);
	half3 vBump1 = GetNormal(tex2Dlod(Xi_BumpMap, half4(Xi_UV1, 0, Xi_Mipmap)), Xi_BumpAmounts.y);
	half3 vBump2 = GetNormal(tex2Dlod(Xi_BumpMap, half4(Xi_UV2, 0, Xi_Mipmap)), Xi_BumpAmounts.z);
	half3 vBump3 = GetNormal(tex2Dlod(Xi_BumpMap, half4(Xi_UV3, 0, Xi_Mipmap)), Xi_BumpAmounts.w);

	vBump0 = normalize(vBump0 + vBump1 + vBump2 + vBump3);

	Xio_Surface.Normal = vBump0;
}
// -----------------------------------------------------------------------------
inline void BumpRoadFunc(in float2 Xi_Bump0, in float2 Xi_Bump1, in float2 Xi_Bump2, in float2 Xi_Bump3, in float4 Xi_BumpBlend, inout GSSurfaceOutput Xio_Surface)
{
	const half4 vX = 2 * float4(Xi_Bump0.x, Xi_Bump1.x, Xi_Bump2.x, Xi_Bump3.x) - 1;
	const half4 vY = 2 * float4(Xi_Bump0.y, Xi_Bump1.y, Xi_Bump2.y, Xi_Bump3.y) - 1;
	const half4 vZ = sqrt(float4(1, 1, 1, 1) - saturate((vX*vX) + (vY*vY)));

	half3 vBump = float3(vX.x, vY.x, vZ.x);
	vBump = lerp(vBump, float3(vX.y, vY.y, vZ.y), Xi_BumpBlend.y);
	vBump = lerp(vBump, float3(vX.z, vY.z, vZ.z), Xi_BumpBlend.z);
	vBump = lerp(vBump, float3(vX.w, vY.w, vZ.w), Xi_BumpBlend.w);

	// On Tangents space, z is up.
	vBump = lerp(half3(0, 0, 1), vBump, Xi_BumpBlend.x);
	Xio_Surface.Normal = vBump;
}
// -----------------------------------------------------------------------------
inline void BumpRoadFunc_RNM(in float2 Xi_Bump0, in float2 Xi_Bump1, in float2 Xi_Bump2, in float2 Xi_Bump3, in float4 Xi_BumpBlend, inout GSSurfaceOutput Xio_Surface)
{
	const half4 vX = half4(2, -2, -2, -2) * half4(Xi_Bump0.x, Xi_Bump1.x, Xi_Bump2.x, Xi_Bump3.x) + float4(-1, 1, 1, 1);
	const half4 vY = half4(2, -2, -2, -2) * half4(Xi_Bump0.y, Xi_Bump1.y, Xi_Bump2.y, Xi_Bump3.y) + float4(-1, 1, 1, 1);
	const half4 vZ = sqrt(1 - saturate(dot(vX, vX) + dot(vY, vY)));

	half3 vBump = half3(vX.x, vY.x, vZ.x + 1);
	half3 vDetail = half3(0, 0, 1);
	vDetail = lerp(vDetail, half3(vX.y, vY.y, vZ.y), Xi_BumpBlend.y);
	vDetail = lerp(vDetail, half3(vX.z, vY.z, vZ.z), Xi_BumpBlend.z);
	vDetail = lerp(vDetail, half3(vX.w, vY.w, vZ.w), Xi_BumpBlend.w);

	vBump = vBump * dot(vBump, vDetail) - vDetail * vBump.z;

	// On Tangents space, z is up.
	vBump = lerp(half3(0, 0, 1), vBump, Xi_BumpBlend.x);
	Xio_Surface.Normal = vBump;
}

// -----------------------------------------------------------------------------
inline void MaskFunc(in half2 Xi_Texcoord, in sampler2D Xi_MaskMap, out half4 Xio_Mask)
{
	Xio_Mask = tex2D(Xi_MaskMap, Xi_Texcoord);
}
// -----------------------------------------------------------------------------
inline void SpecularFunc(in half4 Xi_SpecColor, in half4 Xi_Mask, inout GSSurfaceOutput Xio_Surface)
{
	Xio_Surface.Specular = cPack0.y;
	Xio_Surface.GlossColor = Xi_SpecColor.rgb*Xi_Mask.rgb;
	Xio_Surface.Glossiness = cPack0.z*Xi_Mask.a;//   *Xi_Mask.g; -- Geosim pipeline still does not support gloss maps. When it does, uncomment the multiplier
}
// -----------------------------------------------------------------------------
inline void SpecularSimpleFunc(in half3 Xi_SpecColor, inout GSSurfaceOutput Xio_Surface)
{
	Xio_Surface.Specular = cPack0.y;
	Xio_Surface.GlossColor = Xi_SpecColor.rgb;
}
#ifndef IGNORE_SURFACE_FUNCTIONS
// -----------------------------------------------------------------------------
inline void ReflectionFunc(in half3 Xi_WorldNormal, in half3 tbnNormal, in half3 Xi_WorldView, in samplerCUBE Xi_CubeMap, in half3 Xi_Mask, inout GSSurfaceOutput Xio_Surface)
{
	half3 worldNormal = lerp(Xi_WorldNormal, tbnNormal, cPack1.y);
	half3 l_ReflColor = cPack1.x * texCUBE(Xi_CubeMap, reflect(-Xi_WorldView, worldNormal)).rgb * (Xi_Mask.g);
	//Xio_Surface.Emission = l_ReflColor;
	Xio_Surface.Albedo += l_ReflColor;
}
// -----------------------------------------------------------------------------
inline void ReflectionFunc(in half3 Xi_WorldNormal, in half3 tbnNormal, in half3 Xi_WorldView, in samplerCUBE Xi_CubeMap, in half3 Xi_Mask, in half Xi_Rim, inout GSSurfaceOutput Xio_Surface)
{
	half3 worldNormal = lerp(Xi_WorldNormal, tbnNormal, cPack1.y);
	half3 l_ReflColor = cPack1.x * texCUBE(Xi_CubeMap, reflect(-Xi_WorldView, worldNormal)).rgb * (Xi_Mask.g) * Xi_Rim;
	//Xio_Surface.Emission = l_ReflColor;
	Xio_Surface.Albedo += l_ReflColor;
}
#endif

// -----------------------------------------------------------------------------
inline void ReflectionFunc(inout GSSurfaceOutput Xio_Surface, in samplerCUBE Xi_CubeMap, in half3 Xi_wView, in half3 Xi_wNormal, in fixed Xi_RefFade)
{
#define fRefAmount cPack1.x 
#define fPerturb cPack1.y

	half3 R = reflect(-Xi_wView, lerp(Xi_wNormal, Xio_Surface.Normal, fPerturb));
	Xio_Surface.Albedo += texCUBE(Xi_CubeMap, R).rgb*Xi_RefFade*fRefAmount;
	//Xio_Surface.Albedo = lerp (Xio_Surface.Albedo,texCUBE(Xi_CubeMap,R).rgb,Xi_RefFade*fRefAmount);

#undef fRefAmount
#undef fPerturb
}

// -----------------------------------------------------------------------------
inline void RefractionFunc(in half4 Xi_ScreenPos, in sampler2D Xi_RefrMap, in half Xi_NdV, inout GSSurfaceOutput Xio_Surface)
{
	half l_Refraction = tex2D(Xi_RefrMap, (Xi_ScreenPos.xy / Xi_ScreenPos.w)).r;
	Xio_Surface.Alpha = saturate(Xio_Surface.Alpha + lerp(0, l_Refraction, Xi_NdV));
}
// -----------------------------------------------------------------------------
inline void DetailUVFunc(in half2 Xi_Texcoord, in sampler2D Xi_DetailMap, inout half4 Xio_Color)
{
	Xio_Color = tex2D(Xi_DetailMap, Xi_Texcoord);
}

// -----------------------------------------------------------------------------
inline void DetailTriPlanerFunc(in half3 Xi_DetailTexCoord, in half3 Xi_ObjNormal, in sampler2D Xi_DetailMap, inout GSSurfaceOutput Xio_Surface, inout half4 Xio_Color)
{
	half3 blend = abs(Xi_ObjNormal);

	blend /= dot(blend, 1.0);

	half4 cx = tex2D(Xi_DetailMap, Xi_DetailTexCoord.zy);
	half4 cy = tex2D(Xi_DetailMap, Xi_DetailTexCoord.zx);
	half4 cz = tex2D(Xi_DetailMap, Xi_DetailTexCoord.xy);

	Xio_Color = (cx * blend.x + cy * blend.y + cz * blend.z);
}
//// -----------------------------------------------------------------------------
//inline void DetailFunc(in half2 Xi_Texcoord1, in half3 Xi_ObjNormal, in half4 Xi_DetailColor, in float Xi_VertexAlpha, in sampler2D Xi_DetailMap, inout GSSurfaceOutput Xio_Surface)
//{
//	half4 l_Detail;
//	half  l_DetailBlend;
//
//	DetailUVFunc(Xi_Texcoord1, Xi_DetailMap, l_Detail);
//	DetailBlendOp(cPack1.z, half2(Xio_Surface.Alpha, l_Detail.a*Xi_VertexAlpha), l_DetailBlend);
//	Xio_Surface.Albedo = lerp(Xio_Surface.Albedo, l_Detail.rgb*Xi_DetailColor.rgb, l_DetailBlend);
//	Xio_Surface.Alpha = lerp(Xio_Surface.Alpha, l_Detail.a, l_DetailBlend); ;
//}


// -----------------------------------------------------------------------------
inline void DetailFunc(in half2 Xi_Texcoord1, in half4 Xi_DetailColor, in float Xi_VertexAlpha, in sampler2D Xi_DetailMap, inout GSSurfaceOutput Xio_Surface)
{
	half4 l_Detail;
	half  l_DetailBlend;

	DetailUVFunc(Xi_Texcoord1, Xi_DetailMap, l_Detail);
	l_Detail *= Xi_DetailColor;
	DetailBlendOp(cPack1.z, half2(Xio_Surface.Alpha, l_Detail.a*Xi_VertexAlpha), l_DetailBlend);
	Xio_Surface.Albedo = lerp(Xio_Surface.Albedo, l_Detail.rgb, l_DetailBlend);
	Xio_Surface.Alpha = lerp(Xio_Surface.Alpha, l_Detail.a, l_DetailBlend);
}


// -----------------------------------------------------------------------------
inline void Lightmaps(in float2 Xi_UVS, in sampler2D Xi_Lightmap, inout GSSurfaceOutput Xio_Surface)
{
	half4 vLightmap = tex2D(Xi_Lightmap, Xi_UVS);
	// For RT lighting we use NdL * Albedo where for lightmaps the lighting is scale received from the map
	//Xio_Surface.Emission = 0.5 * Xio_Surface.Albedo * vLightmap.rgb*vLightmap.a;
	Xio_Surface.Albedo *= vLightmap.rgb*vLightmap.a;
}

// -----------------------------------------------------------------------------
inline half4 SampleCube(UNITY_ARGS_TEXCUBE(tex), float3 Xi_Coords, float Xi_Smoothness)
{
	half perceptualRoughness = SmoothnessToRoughness(Xi_Smoothness);
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);
	half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
	half4 rgba = UNITY_SAMPLE_TEXCUBE_LOD(tex, Xi_Coords, mip);
	return rgba;
}

// -----------------------------------------------------------------------------
inline half4 SkyColor(float3 Xi_Coords, float Xi_Smoothness)
{
	return SampleCube(UNITY_PASS_TEXCUBE(Geosim_Sky), Xi_Coords, Xi_Smoothness);
}

// -----------------------------------------------------------------------------
inline half4 PhongLambert(GSSurfaceOutput s, half3 Xi_vLightDir, half3 Xi_vViewDir, half Xi_fAtten, half Xi_fLambert)
{
	half3 vHalfVec = normalize(Xi_vLightDir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_vLightDir));
	fNdL = fNdL * Xi_fLambert + 1 - Xi_fLambert;
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vSpecCol = pow(fNdH, cPack0.z * 128.0)* s.Specular* s.GlossColor;
	return half4(((s.Albedo + s.Emission) * fNdL + vSpecCol + s.Ambient) * (_LightColor0.rgb * Xi_fAtten), s.Alpha);
}
// -----------------------------------------------------------------------------
// Specular makes the surface opaque
inline half4 PhongLambertTransparent(GSSurfaceOutput s, half3 Xi_vLightDir, half3 Xi_vViewDir, half Xi_fAtten, half Xi_fLambert)
{
	half3 vHalfVec = normalize(Xi_vLightDir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_vLightDir));
	fNdL = fNdL * Xi_fLambert + 1 - Xi_fLambert;
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half fSpec = pow(fNdH, cPack0.z * 128.0)* s.Specular;
	return half4(((s.Albedo + s.Emission) * fNdL + (fSpec* s.GlossColor) + s.Ambient) * (_LightColor0.rgb * Xi_fAtten), (s.Alpha + fSpec));
}
// -----------------------------------------------------------------------------
inline half4 PhongShadingLightMap(GSSurfaceOutput s, half3 Xi_LightDir, half3 Xi_ViewDir)
{
	float3 vHalfVec = normalize(Xi_LightDir + Xi_ViewDir);
	float fNdH = max(0, dot(s.Normal, vHalfVec));
	float3 vSpecCol = pow(fNdH, cPack0.z * 128.0) * s.Specular* s.GlossColor;
	return float4(s.Albedo + vSpecCol, s.Alpha);
}

// Phong lighting model
// -----------------------------------------------------------------------------
inline half4 PhongGeosim(GSSurfaceOutput s, half3 Xi_vViewDir, UnityLight Xi_Light)
{
	half3 vHalfVec = normalize(Xi_Light.dir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_Light.dir));
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vSpecCol = pow(fNdH, cPack0.z * 128.0)* s.Specular* s.GlossColor;
	return half4((s.Albedo * fNdL + vSpecCol)*Xi_Light.color, s.Alpha);
}
// Phong lighting model
// -----------------------------------------------------------------------------
inline half4 PhongGeosim(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	//Xi_GI.indirect.diffuse = Xi_GI.indirect.specular*0.25;
	// Direct
	half3 vHalfVec = normalize(Xi_GI.light.dir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_GI.light.dir));
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vGloss = s.Specular* s.GlossColor;
	half3 vSpecCol = pow(fNdH, s.Glossiness * 128.0)*vGloss;
	half4 vColor = half4((s.Albedo * fNdL + vSpecCol)*Xi_GI.light.color, s.Alpha);

#if defined (UNITY_LIGHT_FUNCTION_APPLY_INDIRECT) && GEOSIM_USE_REFLECTIONS

	// InDirect
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;

	half oneMinusReflectivity = 1 - SpecularStrength(vGloss);
	half fGrazingTerm = saturate(s.Glossiness + (1 - oneMinusReflectivity));
	half fNV = saturate(dot(s.Normal, Xi_vViewDir));
	half fSurfaceReduction = 1 / (s.Glossiness*s.Glossiness + 1);
	vColor.rgb += fSurfaceReduction * Xi_GI.indirect.specular *FresnelLerp(vGloss, fGrazingTerm, fNV);

#endif

	return vColor;

}
// -----------------------------------------------------------------------------
inline half4 PhongGeosimFakeInterior(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	//Xi_GI.indirect.diffuse = Xi_GI.indirect.specular*0.25;
	// Direct
	half3 vHalfVec = normalize(Xi_GI.light.dir + Xi_vViewDir);
	Xi_GI.light.dir = Xi_vViewDir;
	half fNdL = max(0, dot(s.Normal, Xi_GI.light.dir));
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vGloss = s.Specular* s.GlossColor;
	half3 vSpecCol = pow(fNdH, s.Glossiness * 128.0)*vGloss;
	half4 vColor = half4((s.Albedo + vSpecCol), s.Alpha);

#if defined (UNITY_LIGHT_FUNCTION_APPLY_INDIRECT) && GEOSIM_USE_REFLECTIONS

	// InDirect
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;

	half oneMinusReflectivity = 1 - SpecularStrength(vGloss);
	half fGrazingTerm = saturate(s.Glossiness + (1 - oneMinusReflectivity));
	half fNV = saturate(dot(s.Normal, Xi_vViewDir));
	half fSurfaceReduction = 1 / (s.Glossiness*s.Glossiness + 1);
	vColor.rgb += fSurfaceReduction * Xi_GI.indirect.specular *FresnelLerp(vGloss, fGrazingTerm, fNV);

#endif

	return vColor;

}
// Phong lighting model
// -----------------------------------------------------------------------------
inline half4 LambertGeosim(GSSurfaceOutput s, UnityLight Xi_Light)
{
	half fNdL = max(0, dot(s.Normal, Xi_Light.dir));
	//fNdL = fNdL * 0.5 + 0.5; // To overcome missing GI

	return half4((s.Albedo * fNdL)*Xi_Light.color, s.Alpha);
}
// -----------------------------------------------------------------------------
inline half4 PhongGeosimTransparent(GSSurfaceOutput s, half3 Xi_vViewDir, UnityLight Xi_Light)
{
	half3 vHalfVec = normalize(Xi_Light.dir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_Light.dir));
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vSpecCol = pow(fNdH, s.Glossiness * 128.0)* s.Specular * s.GlossColor;
	half4 vColor = half4((s.Albedo * fNdL + vSpecCol)* Xi_Light.color, s.Alpha);

	return vColor;
}

// In-case transparent receive reflections probes, use this function.
// -----------------------------------------------------------------------------
inline half4 PhongGeosimTransparent(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	// Direct
	half3 vHalfVec = normalize(Xi_GI.light.dir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_GI.light.dir));
	fNdL += s.Ambient.r * (1 - s.Alpha);
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vGloss = s.Specular* s.GlossColor;
	half3 vSpecCol = pow(fNdH, s.Glossiness * 128.0)* vGloss;
	half4 vColor = half4((s.Albedo * fNdL + vSpecCol)* Xi_GI.light.color, s.Alpha);

#if defined (UNITY_LIGHT_FUNCTION_APPLY_INDIRECT) && GEOSIM_USE_REFLECTIONS

	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;

	// InDirect
	half oneMinusReflectivity = 1 - SpecularStrength(vGloss);
	half fGrazingTerm = saturate(s.Glossiness + (1 - oneMinusReflectivity));

	half fNV = saturate(dot(s.Normal, Xi_vViewDir));
	half fSurfaceReduction = 1 / (s.Glossiness*s.Glossiness + 1);
	vColor.rgb += fSurfaceReduction * Xi_GI.indirect.specular *FresnelLerp(vGloss, fGrazingTerm, fNV);
#endif

	return vColor;
}

// In-case transparent receive reflections probes, use this function.
// -----------------------------------------------------------------------------
inline half4 PhongGeosimTransparentCutout(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	half3 vHalfVec = normalize(Xi_GI.light.dir + Xi_vViewDir);
	half fNdL = max(0, dot(s.Normal, Xi_GI.light.dir));
	half fNdH = max(0, dot(s.Normal, vHalfVec));
	half3 vGloss = s.Specular* s.GlossColor;
	half3 vSpecCol = pow(fNdH, s.Glossiness * 128.0)*vGloss;
	half4 vColor = half4((s.Albedo * fNdL + vSpecCol)*Xi_GI.light.color, s.Alpha);
#if defined (UNITY_LIGHT_FUNCTION_APPLY_INDIRECT) && GEOSIM_USE_REFLECTIONS
	// InDirect
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;

	half oneMinusReflectivity = 1 - SpecularStrength(vGloss);
	half fGrazingTerm = saturate(s.Glossiness + (1 - oneMinusReflectivity));
	half fNV = saturate(dot(s.Normal, Xi_vViewDir));
	half fSurfaceReduction = 1 / (s.Glossiness*s.Glossiness + 1);
	vColor.rgb += fSurfaceReduction * Xi_GI.indirect.specular *FresnelLerp(vGloss, fGrazingTerm, fNV);
#endif
	return vColor;
}
// -----------------------------------------------------------------------------
inline half4 PhongGeosimTranslucent(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
#define fPower 			0.1
#define fNdLRange 		0.75
#define fMask  			s.Alpha
#define fSubSurfaceScale 	s.Ambient.r

	float3 vSpecCol = lerp(fSubSurfaceScale, s.Specular, fMask) *s.GlossColor;

	// For translucent pixels, use fixed gloss
	half3 vGloss = lerp(half3(s.Specular, s.Specular, s.Specular), vSpecCol, fMask);
	half3 vSSSColor = lerp(vSpecCol, half3(0, 0, 0), fMask);

	half fNdL = max(0, dot(s.Normal, Xi_GI.light.dir));
	fNdL = lerp(fNdL * fNdLRange + 1.0f - fNdLRange, fNdL, fMask);

	half3 l_HalfVec = normalize(Xi_GI.light.dir + Xi_vViewDir);
	half fNdH = max(0, dot(s.Normal, l_HalfVec));
	vSpecCol = pow(fNdH, s.Glossiness * 128)* vGloss;
	half4 vOpaque = half4(((s.Albedo * fNdL + vSpecCol)), 1);

	// Translucent.
	half3 vTransLightDir = normalize(Xi_GI.light.dir + s.Normal * 0.5);
	half fVdL = pow(abs(dot(Xi_vViewDir, -vTransLightDir)), fPower * 128);
	half3 vTransAlbedo = vSSSColor * fVdL;

	// InDirect
	half oneMinusReflectivity = 1 - SpecularStrength(vGloss);
	half fGrazingTerm = saturate(s.Glossiness + (1 - oneMinusReflectivity));

	half fNV = saturate(dot(s.Normal, Xi_vViewDir));
	half fSurfaceReduction = 1 / (s.Glossiness*s.Glossiness + 1);


	half4 vColor = vOpaque;
	vColor.rgb += (1 - fMask)*vTransAlbedo;
	vColor.rgb *= Xi_GI.light.color;
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;
	vColor.rgb += fSurfaceReduction * Xi_GI.indirect.specular *FresnelLerp(vGloss, fGrazingTerm, fNV);

	return vColor;

#undef fPower 					
#undef fNdLRange 	
#undef fMask
#undef fSubSurfaceScale
}
// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosim(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	vColor = PhongGeosim(s, Xi_vViewDir, Xi_GI);

	return vColor;
}

// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosimInterior(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	//vColor = PhongGeosim(s, Xi_vViewDir, Xi_GI.light); calls to none GI function
	vColor = PhongGeosim(s, Xi_vViewDir, Xi_GI);
	return vColor;
}
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosimFakeInterior(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	//vColor = PhongGeosim(s, Xi_vViewDir, Xi_GI.light); calls to none GI function
	vColor = PhongGeosimFakeInterior(s, Xi_vViewDir, Xi_GI);
	return vColor;
}

// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingLambertGeosim(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	vColor = LambertGeosim(s, Xi_GI.light);

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;
#endif

	return vColor;
}
// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosimTranslucent(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	vColor = PhongGeosimTranslucent(s, Xi_vViewDir, Xi_GI);

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;
#endif

	return vColor;
}
// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosimTransparent(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	vColor = PhongGeosimTransparent(s, Xi_vViewDir, Xi_GI);//PhongGeosimTransparent(s, Xi_vViewDir, Xi_GI.light);
	//vColor.rgb *= Xi_GI.indirect.diffuse; gives sky bluies color but works wrong for indoors.
#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	//vColor.rgb += s.Albedo * Xi_GI.indirect.diffuse;
#endif
	return vColor;
}
// For forward rendering
// -----------------------------------------------------------------------------
inline fixed4 LightingPhongGeosimTransparentCutout(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor;
	vColor = PhongGeosimTransparentCutout(s, Xi_vViewDir, Xi_GI);//PhongGeosimTransparent(s, Xi_vViewDir, Xi_GI.light);

	return vColor;
}

// For Deferred rendering
// -----------------------------------------------------------------------------
inline half4 LightingPhongGeosim_Deferred(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI, out half4 Xo_vGBuffer0, out half4 Xo_vGBuffer1, out half4 Xo_vGBuffer2)
{
	UnityStandardData data;
	data.diffuseColor = s.Albedo;

	data.occlusion = 0.55; // --> Goes to 	Xo_vGBuffer0.w
	// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
	data.specularColor = s.Specular* s.GlossColor;// * (1/UNITY_PI);
	data.smoothness = s.Glossiness;
	data.normalWorld = s.Normal;

	UnityStandardDataToGbuffer(data, Xo_vGBuffer0, Xo_vGBuffer1, Xo_vGBuffer2);

	half4 emission = half4(s.Emission, 1);

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	emission.rgb += s.Albedo *Xi_GI.indirect.diffuse;
#endif

	return emission;
}

// For Deferred rendering
// -----------------------------------------------------------------------------
inline half4 LightingPhongGeosimInterior_Deferred(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI, out half4 Xo_vGBuffer0, out half4 Xo_vGBuffer1, out half4 Xo_vGBuffer2)
{
	UnityStandardData data;


	data.diffuseColor = s.Albedo;
	data.occlusion = 0.55; // --> Goes to 	Xo_vGBuffer0.w ( For some reason 0.5 is not working --> 0.5 >= gbuffer.w returns false )
	// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
	data.specularColor = s.Specular* s.GlossColor;// * (1/UNITY_PI);
	data.smoothness = s.Glossiness;
	data.normalWorld = s.Normal;

	UnityStandardDataToGbuffer(data, Xo_vGBuffer0, Xo_vGBuffer1, Xo_vGBuffer2);

	half4 emission = half4(s.Emission, 1);


	return emission;
}

// For Deferred rendering
// -----------------------------------------------------------------------------
inline half4 LightingLambertGeosim_Deferred(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI, out half4 Xo_vGBuffer0, out half4 Xo_vGBuffer1, out half4 Xo_vGBuffer2)
{
	UnityStandardData data;
	data.diffuseColor = s.Albedo;
	data.occlusion = 0.55; // --> Goes to 	Xo_vGBuffer0.w
	// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
	data.specularColor = float3(0.0, 0.0, 0.0);// * (1/UNITY_PI);
	data.smoothness = 0.1;
	data.normalWorld = s.Normal;

	UnityStandardDataToGbuffer(data, Xo_vGBuffer0, Xo_vGBuffer1, Xo_vGBuffer2);

	half4 emission = half4(s.Emission, 1);

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	emission.rgb += s.Albedo * Xi_GI.indirect.diffuse;
#endif 
	return emission;
}


// -----------------------------------------------------------------------------
inline half4 LightingPhongGeosimTranslucent_Deferred(GSSurfaceOutput s, half3 Xi_vViewDir, UnityGI Xi_GI, out half4 Xo_vGBuffer0, out half4 Xo_vGBuffer1, out half4 Xo_vGBuffer2)
{
#define fShadingTec s.Alpha
#define fSubSurfaceScale s.Ambient.r
	UnityStandardData data;
	data.diffuseColor = s.Albedo;
	// s.Ambient.r is SSS for translucent and reflection amount for standard. s.Alpha is the mask sss/standard

	data.occlusion = s.Specular*0.5 + 0.505*fShadingTec; // --> Goes to 	Xo_vGBuffer0.w
	// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
	data.specularColor = lerp(fSubSurfaceScale, s.Specular, fShadingTec) * s.GlossColor;// * (1/UNITY_PI);
	data.smoothness = s.Glossiness;
	data.normalWorld = s.Normal;

	UnityStandardDataToGbuffer(data, Xo_vGBuffer0, Xo_vGBuffer1, Xo_vGBuffer2);

	half4 emission = half4(s.Emission, 1);

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	emission.rgb += s.Albedo * Xi_GI.indirect.diffuse;
#endif

	return emission;

#undef fShadingTec
#undef fSubSurfaceScale
}
// Note: data.atten is the shadow factor
// For forward rendering, No lighting on fragment program
// -----------------------------------------------------------------------------
inline fixed4 LightingNoLightingGeosim(GSSurfaceOutputNoLight s, half3 Xi_vViewDir, UnityGI Xi_GI)
{
	fixed4 vColor = fixed4(s.Albedo, s.Alpha);
	return vColor;
}
//

// -----------------------------------------------------------------------------
inline UnityGI _UnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld)
{
	UnityGI o_gi;
	ResetUnityGI(o_gi);

	// Base pass with Light-map support is responsible for handling ShadowMask / blending here for performance reason
#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
	half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
	float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
	float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
	data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
#endif

	o_gi.light = data.light;
	o_gi.light.color *= data.atten;

#if UNITY_SHOULD_SAMPLE_SH
	o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
#endif

	o_gi.indirect.diffuse *= occlusion;
	return o_gi;
}
// -----------------------------------------------------------------------------
inline UnityGI _UnityGlobalIllumination(UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{
	UnityGI o_gi = _UnityGI_Base(data, occlusion, normalWorld);
	o_gi.indirect.specular = UnityGI_IndirectSpecular(data, occlusion, glossIn);
	return o_gi;
}
// -----------------------------------------------------------------------------
inline UnityGI _UnityGlobalIllumination(UnityGIInput data, half occlusion, half3 normalWorld)
{
	UnityGI o_gi = _UnityGI_Base(data, occlusion, normalWorld);
	o_gi.indirect.specular = 0;
	return o_gi;
}
// -----------------------------------------------------------------------------
inline void LightingPhongGeosim_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	// Found out this is not defined at GI callback. I'll need to use GSSurfaceOutput data instead.
	//#define fGlossiness cPack1.z 

	Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Glossiness, data.worldViewDir, s.Normal, s.Specular);
#if (!USE_UNITY_GI)
	// Fill the specular
	gi = _UnityGlobalIllumination(data, 1, s.Normal, g);
	// Fill the diffuse


	// Texture is very small scale texture. Xi_Coords are the surface normal where if bump is used
	// caused ddx,ddy issues. Mipmap is calculated based on the Smoothness of the surface.
	// If the surface is to glossy ddx,ddy issues will be noticeable. Scaling the gloss valid by the specular 
	// to get subtle results. ( P.S, can use const value (0) to sample the same mip, instead ). 
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.diffuse = data.ambient + sky;

#else
	// If LM Static, sample lightmaps. Else use SH
	gi = UnityGlobalIllumination(data, 1, s.Normal, g);
#endif

}

// -----------------------------------------------------------------------------
inline void LightingPhongGeosimInterior_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.specular = sky;
}
// -----------------------------------------------------------------------------
inline void LightingPhongGeosimFakeInterior_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.specular = sky;
}

// -----------------------------------------------------------------------------
inline void LightingPhongGeosimTransparent_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Glossiness, data.worldViewDir, s.Normal, s.Specular);
#if (!USE_UNITY_GI)
	// Fill the specular
	gi = _UnityGlobalIllumination(data, 1, s.Normal, g);
	// Fill the diffuse

	gi.indirect.diffuse = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
#else
	// If LM Static, sample lightmaps. Else use SH
	gi = UnityGlobalIllumination(data, 1, s.Normal, g);
#endif
}

// -----------------------------------------------------------------------------
inline void LightingPhongGeosimTransparentCutout_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Glossiness, data.worldViewDir, s.Normal, s.Specular);
#if (!USE_UNITY_GI)
	// Fill the specular
	gi = _UnityGlobalIllumination(data, 1, s.Normal, g);
	// Fill the diffuse


	// Texture is very small scale texture. Xi_Coords are the surface normal where if bump is used
	// caused ddx,ddy issues. Mipmap is calculated based on the Smoothness of the surface.
	// If the surface is to glossy ddx,ddy issues will be noticeable. Scaling the gloss valid by the specular 
	// to get subtle results. ( P.S, can use const value (0) to sample the same mip, instead ). 
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.diffuse = data.ambient + sky;

#else
	// If LM Static, sample lightmaps. Else use SH
	gi = UnityGlobalIllumination(data, 1, s.Normal, g);
#endif
}

// -----------------------------------------------------------------------------
inline void LightingPhongGeosimTranslucent_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	// (Occlusion = 1 default, on Unity standard it comes from occlusion map.
#if (!USE_UNITY_GI)
	// For forward shadows stores data.atten
	gi = _UnityGlobalIllumination(data, 1, s.Normal);
	// Fill the diffuse


	// Texture is very small scale texture. Xi_Coords are the surface normal where if bump is used
	// caused ddx,ddy issues. Mipmap is calculated based on the Smoothness of the surface.
	// If the surface is to glossy ddx,ddy issues will be noticeable. Scaling the gloss valid by the specular 
	// to get subtle results. ( P.S, can use const value (0) to sample the same mip, instead ). 
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.diffuse = data.ambient + sky;
#else
	// If LM Static, sample lightmaps. Else use SH
	gi = UnityGlobalIllumination(data, 1, s.Normal);
#endif
}

// must be implemented inorder to receive shadows.
// -----------------------------------------------------------------------------
inline void LightingLambertGeosim_GI(GSSurfaceOutput s, UnityGIInput data, inout UnityGI gi)
{
	// (Occlusion = 1 default, on Unity standard it comes from occlusion map.
#if (!USE_UNITY_GI)
	// For forward shadows stores data.atten
	gi = _UnityGlobalIllumination(data, 1, s.Normal);
	// Fill the diffuse


	// Texture is very small scale texture. Xi_Coords are the surface normal where if bump is used
	// caused ddx,ddy issues. Mipmap is calculated based on the Smoothness of the surface.
	// If the surface is to glossy ddx,ddy issues will be noticeable. Scaling the gloss valid by the specular 
	// to get subtle results. ( P.S, can use const value (0) to sample the same mip, instead ). 
	float3 sky = SkyColor(s.Normal, s.Glossiness*s.Specular).rgb;
	gi.indirect.diffuse = data.ambient + sky;
#else
	// If LM Static, sample lightmaps. Else use SH
	gi = UnityGlobalIllumination(data, 1, s.Normal);
#endif
}
// No lighting on fragment program
// -----------------------------------------------------------------------------
inline void LightingNoLightingGeosim_GI(GSSurfaceOutputNoLight s, UnityGIInput data, inout UnityGI gi)
{
}

#endif
