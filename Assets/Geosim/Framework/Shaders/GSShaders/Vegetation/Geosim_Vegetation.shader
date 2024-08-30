// ****************************************************************************
//<copyright file=Geosim_Vegetation company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
Shader "Geosim/x/Vegetation/Geosim_Vegetation"
{
	Properties
	{
		cDiffuseMap("Diffuse", 2D) = "white" {}
		cMaskMap("Mask", 2D) = "white" {}
		cBlendColor1("Albedo Color", Color) = (1,1,1,1)
		cSSSColor("SubSurface Color", Color) = (1,1,1,1)
		cPack0("-Empty-,cSpecularLevel,cSpecGlossiness,-Empty-", Vector) = (1,1.0,1,1)
		cPack1("WavesPhasesX,WavesFreqX,WavesAmpX,WavesLevelX", Vector) = (0,0,0,0)
		cPack2("WindX,WindY,WindZ,-Empty-", Vector) = (0,0,0,0)
		cPack3("cDetailParamsX,cDetailParamsY,cDetailParamsZ,cDetailParamsW", Vector) = (0,0,0,0)
	}

		SubShader
		{
			//TransparentCutout cause issues with Unity image effects
			//Tags {"Queue" = "AlphaTest+12" "RenderType" = "TransparentCutout"}
			Tags {"Queue" = "AlphaTest+12" "RenderType" = "Opaque"}
			Pass
			{
				Tags {"LightMode" = "ShadowCaster"}
				cull off
				ztest LEqual
				colormask 0
				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma multi_compile_shadowcaster
				#pragma shader_feature ANIMATED
				#pragma shader_feature LOD0
				#pragma multi_compile_instancing
				#pragma target 3.0 
				#define IGNORE_SURFACE_FUNCTIONS 1 
				#include "../../Common/Functions.cginc"  

				struct v2f
				{
					V2F_SHADOW_CASTER;
					half2 uv : TEXCOORD1;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				struct appdata
				{
					float4 vertex 	: POSITION;
					float3 normal 	: NORMAL;
					float4 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				sampler2D 	cDiffuseMap;
				half4		cPack2;
				half4		cPack3;

				v2f vert(appdata v)
				{
					v2f o;

					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					o.uv = v.texcoord;

					#if ANIMATED

						#define vWavesPhases 	float4(cPack1.x,0,0,0)      
						#define vWaveFreq	 	float4(cPack1.y,0,0,0)      
						#define vWaveAmp 	 	float4(cPack1.z,0,0,0)            
						#define vWaveLevels	 	float4(cPack1.w,0,0,0)  
						#define vWind 		 	cPack2.xyz
						#define vDetailParams 	cPack3

						half3 vObjPos = v.vertex.xyz;
						half3 vWorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
						GeneralMovment(vObjPos.xyz, v.normal, v.color, vWavesPhases, vWaveFreq, vWaveAmp, vWaveLevels);

						#if LOD0
							DetailBending(vWorldPos, vObjPos.xyz, v.normal, v.color.rgb, vDetailParams);
							#endif
							MainBending(vObjPos.xyz, vWind);
							v.vertex.xyz = vObjPos.xyz;
						#endif

					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(i);
					fixed4 col = tex2D(cDiffuseMap,i.uv);
					clip(col.a - 0.5);
					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}

			cull off
			ztest lequal
			zwrite on
			CGPROGRAM

			struct appdataVeg
			{
				float4 vertex 	: POSITION;
				float3 normal 	: NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT; // Unity wants it, and in the future it will be in used to create better lighting for the leafs
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			#pragma target 3.0   
			#pragma surface SurfaceVegetation PhongGeosimTranslucent vertex:VertVegetation dithercrossfade
			#pragma shader_feature ANIMATED
			#pragma shader_feature LOD0 

			#define GEOSIM_SURFACE_SHADERS 1 
			#define SURFACE_VERTEX_INPUT_BASIC_TAN 1
			#define SURFACE_INPUT_VEGETATION 1
			#pragma shader_feature __ USE_UNITY_GI

			#include "../../Common/Functions.cginc"      

			sampler2D 	cDiffuseMap;
			sampler2D 	cMaskMap;

			half4 		cSSSColor;
			half4		cPack2;
			half4		cPack3;

	UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(fixed4, cBlendColor1)
					#define cVegProps_arr Props
	UNITY_INSTANCING_BUFFER_END(Props)

	void VertVegetation(inout appdata_full v, out Input o)
	{
		o.vTexcoord0 = v.texcoord.xy;

		#if ANIMATED  

		#define vWavesPhases 	float4(cPack1.x,0,0,0)      
		#define vWaveFreq	 	float4(cPack1.y,0,0,0)      
		#define vWaveAmp 	 	float4(cPack1.z,0,0,0)            
		#define vWaveLevels	 	float4(cPack1.w,0,0,0)   
		#define vWind 		 	cPack2.xyz   
		#define vDetailParams 	cPack3   

			half3 vObjPos = v.vertex.xyz;
			half3 vWorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
			GeneralMovment(vObjPos.xyz, v.normal, v.color, vWavesPhases, vWaveFreq, vWaveAmp, vWaveLevels);

			#if LOD0      
				DetailBending(vWorldPos, vObjPos.xyz, v.normal, v.color.rgb, vDetailParams);
			#endif   
				MainBending(vObjPos.xyz, vWind);
				v.vertex.xyz = vObjPos.xyz;
			#endif    

			float l_Depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;
			half3 vPivot = frac(unity_ObjectToWorld._m03_m13_m23);
			half2 vCheckerPattern = step(vPivot.xz, v.color.aa)*0.5;
			half fChecker = frac(vCheckerPattern.x + vCheckerPattern.y) * 2;

			half fShadingTec = frac(v.color.a * 100) > 0.5; // 0|1 SSS,Standard
			half fMask = 1;//step(v.color.a, fChecker)+fShadingTec;// uncomment this line when data will be ready for that step(v.color.a, fChecker)+fShadingTec;

			o.vElements = saturate(half4(fMask, 0, 1 - l_Depth * 30, fShadingTec)); // Vertex color used for animation.
	}

	// ----------------------------------------------------------------------------- 
	void SurfaceVegetation(Input IN, inout GSSurfaceOutput o)
	{
#define vSSSColor		cSSSColor
#define fShadingTec		IN.vElements.w
		half4 vAlbedo = tex2D(cDiffuseMap, IN.vTexcoord0);
		half4 vMask = tex2D(cMaskMap, IN.vTexcoord0);
		clip(IN.vElements.x*vAlbedo.a - 0.5);
		// Sepc used as inv off sss as light is returned back by sss amount 
		o.Specular = (1 - vMask.r)*cPack0.y* IN.vElements.z;

		o.Glossiness = vMask.b*cPack0.z;



		//	vAlbedo.rgb *= 2.4 * dot(vAlbedo.rgb, float3(0.2126, 0.7152, 0.0722));
			vAlbedo.rgb *= (UNITY_ACCESS_INSTANCED_PROP(cVegProps_arr,cBlendColor1)).rgb;

			o.GlossColor = vSSSColor.rgb;
			o.Albedo = vAlbedo.rgb;

			o.Alpha = fShadingTec;
			o.Ambient = vMask.rrr;
			o.Normal = normalize(UnpackCompNormal(vMask.ag));

#undef vSSSColor
#undef fShadingTec
		}
		ENDCG
		}

			Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
