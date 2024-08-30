// ****************************************************************************
//<copyright file=Geosim_AnimatedVertices_Opaque company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
// I decided to use surface shaders as they handle many things I would not want to
// handle manually ( Like instancing, Stereo rendering ... ). 

// This shdaer was made to :
// 1. Faster rendering.
// 2. Smoother Lod

// We want to allow lower Lods to be seen closer to the viewer. For that reason
// this shader supports shadows and lighting. The lighing used in here is Lambert pre pixel.

Shader "Geosim/x/Animated/Geosim_AnimatedVertices_Opaque"
{
	Properties
	{
		[NoScanleOffst]	cDiffuseMap("Diffuse", 2D) = "white" {}
						cSpecColor("Specular Color", Color) = (1,1,1,1)
						cBlendColor1("Blending Color 1", Color) = (1,1,1,1)

						cPack0("-Empty-,cSpecularLevel,cSpecGlossiness,-Empty-", Vector) = (1,0.33,1,1)
						cPack1("WavesPhasesX,WavesPhasesY,WavesPhasesZ,DetailX", Vector) = (0,0,0,0)
						cPack2("WavesFreqX,WavesFreqY,WavesFreqZ,DetailY", Vector) = (0,0,0,0)
						cPack3("WavesAmpX,WavesAmpY,WavesAmpZ,DetailX", Vector) = (0,0,0,0)
						cPack4("WavesLevelX,WavesLevelY,WavesLevelZ,DetailSpeed", Vector) = (0,0,0,0)
						cPack5("WindX,WindY,WindZ,-Empty-", Vector) = (0,0,0,0)
	}


		SubShader
						{
							Tags {"Queue" = "Geometry+2" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
							Pass
							{
								Tags{ "LightMode" = "ShadowCaster" }
								cull off
								ztest LEqual
								colormask 0
								CGPROGRAM
									#pragma target 3.0 
									#pragma vertex vert
									#pragma fragment frag 
									#pragma multi_compile_shadowcaster
									#pragma multi_compile_instancing
									#define IGNORE_SURFACE_FUNCTIONS 1
									#include "../../Common/Functions.cginc"  

									struct v2f
									{
										V2F_SHADOW_CASTER;
										half2 uv : TEXCOORD1;
										UNITY_VERTEX_INPUT_INSTANCE_ID
										UNITY_VERTEX_OUTPUT_STEREO
									};

									sampler2D 	cDiffuseMap;
									half4		cPack2;
									half4		cPack3;
									half4		cPack4;
									half4		cPack5;

									v2f vert(VertexSimple v)
									{
										v2f o;
										UNITY_SETUP_INSTANCE_ID(v);
										UNITY_TRANSFER_INSTANCE_ID(v, o);
										UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					#define vWavesPhases cPack1 
					#define vWaveFreq	 cPack2
					#define vWaveAmp 	 cPack3
					#define vWaveLevels	 cPack4 
					#define vWind 		 cPack5
					#define vDetailParams half4(cPack1.w,cPack2.w,cPack3.w,cPack4.w)

											float4 oPos = v.vertex;
											float3 wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

											GeneralMovment(oPos.xyz, v.normal, v.color, vWavesPhases, vWaveFreq, vWaveAmp, vWaveLevels);
											DetailBending(wPos, oPos.xyz, v.normal, v.color.rgb, vDetailParams);
											MainBending(oPos.xyz, vWind.xyz);
											v.vertex = oPos;
											o.uv = v.texcoord;
											TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
											return o;
										}

										float4 frag(v2f i) : SV_Target
										{
											UNITY_SETUP_INSTANCE_ID(i);
											fixed4 col = tex2D(cDiffuseMap,i.uv);
											SHADOW_CASTER_FRAGMENT(i)
										}
								ENDCG
							}

							cull off
							ztest lequal
							zwrite on
							CGPROGRAM
							#pragma target 3.0 
							#pragma surface Surf PhongGeosim vertex:Vert dithercrossfade


							#define GEOSIM_SURFACE_SHADERS 1 
							#define SURFACE_VERTEX_INPUT_BASIC_TAN 1 //Unity's directional lightmaps uses the tangets.
							#define SURFACE_INPUT_UV 1 
							#define GEOSIM_USE_REFLECTIONS 1  
							#pragma shader_feature __ USE_UNITY_GI

							#include "../../Common/Functions.cginc"      

							sampler2D 	cDiffuseMap;
							half4 		cBlendColor1;
							half4	  	cSpecColor;
							half4		cPack2;
							half4		cPack3;
							half4		cPack4;
							half4		cPack5;

							void Vert(inout appdata v, out Input o)
							{
					#define vWavesPhases cPack1 
					#define vWaveFreq	 cPack2
					#define vWaveAmp 	 cPack3
					#define vWaveLevels	 cPack4 
					#define vWind 		 cPack5
					#define vDetailParams half4(cPack1.w,cPack2.w,cPack3.w,cPack4.w)

								// Animated need one normal --> double side is not supported by this shader.
								// The back face culling is off, and the normals are set properly.

											half3 vView = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld,v.vertex));
											half fDot = dot(v.normal,vView) > 0 ? 0 : 1;

											o.uvcDiffuseMap = v.texcoord;

											half3 vObjPos = v.vertex.xyz;
											half3 vWorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
											GeneralMovment(vObjPos.xyz, v.normal, v.color, vWavesPhases, vWaveFreq, vWaveAmp, vWaveLevels);
											DetailBending(vWorldPos, vObjPos.xyz, v.normal, v.color.rgb, vDetailParams);
											MainBending(vObjPos.xyz, vWind);

											v.vertex.xyz = vObjPos.xyz;
											v.normal = lerp(v.normal,-v.normal,fDot);
										}

							// ----------------------------------------------------------------------------- 
							void Surf(Input IN, inout GSSurfaceOutput o)
							{
								AlbedoFunc(IN.uvcDiffuseMap, cDiffuseMap, cBlendColor1,o);
								o.Specular = cPack0.y;
								o.GlossColor = cSpecColor.rgb;
								o.Glossiness = cPack0.z;
							}
ENDCG
						}
							Fallback "Legacy Shaders/Diffuse"
}
