// ****************************************************************************
//<copyright file=Geosim_Uber_Cutout company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Note: Currently (15.6.2016) unity does not support VFACE on a surface shader.
// Few options:
// 1. Implement none surface shader. Will consider that on later stages as there are some fetures from 
//	  the surface shader we still want to preserve.
// 2. Implement a 2-Pass surface shader. It is more costy, but we have surface shader. 
// 3. Update this shader with VFACE when unity adds it to surface shaders.

Shader "Geosim/x/Uber/Geosim_Uber_Cutout"
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
		cPack1("cReflAmount,cReflrPerturb,cDetailFunc,cCullBack", Vector) = (0,0,2,0)
	}

	SubShader
	{
		// Tags {"Queue" = "AlphaTest" "RenderType" = "TransparentCutout"}  Cuase issues with the image effects AO
		Tags{ "Queue" = "AlphaTest" "RenderType" = "Opaque" "ForceNoShadowCasting" = "True" }

		Pass
		{
			Tags {"LightMode" = "ShadowCaster"}

			cull off
			ztest LEqual
			CGPROGRAM
				#pragma target 3.0 
				#pragma vertex vert
				#pragma fragment frag 
				#pragma multi_compile_shadowcaster

				#define IGNORE_SURFACE_FUNCTIONS 1 
				#include "../../Common/Functions.cginc"  

				struct v2f
				{
					V2F_SHADOW_CASTER;
					half2 uv : TEXCOORD1;
				};

				sampler2D 	cDiffuseMap;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.uv = v.texcoord;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}
				
				float4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(cDiffuseMap,i.uv);
					clip(col.a - 0.5);
					SHADOW_CASTER_FRAGMENT(i)
				}
			ENDCG
		}

		cull off
		CGPROGRAM

			#pragma target 3.0            
			#pragma surface SurfaceCutout PhongGeosim vertex:VertCutout dithercrossfade
			#pragma shader_feature __ _GEOSIM_EXTENSIONS
			#pragma shader_feature __ USE_UNITY_GI   
			#define GEOSIM_SURFACE_SHADERS 1                                                           
			#define SURFACE_INPUT_FULL 1                                 
			#define GEOSIM_USE_REFLECTIONS 1 

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
			#define fCullBack cPack1.w
				half3 view = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex));
				half l_Dot = dot(v.normal,view) > 0 ? 0 : 1;
				v.normal = lerp(v.normal,-v.normal,l_Dot);

				VertexFull(v, o);
				v.color.a -= max(0,l_Dot*fCullBack);
				GEOSIM_EXT_VERTEX(v, o);
			#undef fCullBack
			}

			// ----------------------------------------------------------------------------- 
			void SurfaceCutout(Input IN, inout GSSurfaceOutput o)
			{
				half4 vMask;
				AlbedoBlendedFunc(IN.oTexcoord0, cPack0.w, cDiffuseMap, cBlendColor1, cBlendColor2,o);
				DetailFunc(IN.oTexcoord1,cDetailColor,IN.color.a,cDetailMap,o);
				o.Albedo *= IN.color.rgb;
				clip(o.Alpha - 0.5);


				BumpFunc(IN.oTexcoord0, cBumpMap, cPack0.x, o);
				MaskFunc(IN.oTexcoord0, cMaskMap,vMask);
				SpecularFunc(cSpecColor,vMask, o);
				GEOSIM_EXT_FRAGMENT(IN, o);
			}
		ENDCG
	}
	Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
