// ****************************************************************************
//<copyright file=Geosim_Glow company="GeoSim Systems Ltd">
// Copyright © 2000-2018 GeoSim Systems Ltd. All rights reserved. 
//</copyright>
// ****************************************************************************
Shader "Geosim/x/Effects/Geosim_Glow"
{
	Properties
	{
		cDiffuseMap("Diffuse", 2D) = "white" {}
		cPack0("cGlow2D,cGlowWavingSpeed,-Empty-,-Empty-", Vector) = (0,0,1,0)
	}
		SubShader
		{
			Tags {"Queue" = "Transparent+9" "RenderType" = "Transparent" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
			Pass
			{
				Cull Off
				ZWrite Off
				Lighting Off
				Blend SrcAlpha One
				offset -1, -1

				CGPROGRAM
				#pragma target 3.0 
				#pragma vertex VertGlow
				#pragma fragment FragGlow
				#pragma multi_compile_fog 
				#pragma multi_compile_instancing
				#pragma shader_feature LOD0
				#pragma shader_feature __ USE_UNITY_GI

				#define IGNORE_SURFACE_FUNCTIONS 1  
				#include "../../Common/Functions.cginc" 

				sampler2D cDiffuseMap;

				V2FSimpleNoLight VertGlow(VertexSimple v)
				{
	#define GlowAxis fixed3(0, 0, 1)


					V2FSimpleNoLight o;

					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					fixed fGlowThickness = frac(v.color.a * 100)*0.1;

					o.oTexcoord0 = v.texcoord;
					fixed3 N = normalize(mul((float3x3)UNITY_MATRIX_MV,v.normal).xyz);
					fixed3 P = UnityObjectToViewPos(v.vertex) + fGlowThickness * N;    // displaced position (view space)


					fixed l_fPower = dot(lerp(N,GlowAxis,cPack0.x), GlowAxis);
					l_fPower *= l_fPower * l_fPower*l_fPower*v.color.a * 10;

					o.pos = mul(UNITY_MATRIX_P, fixed4(P,1));

	#if LOD0  
					fixed fWaveOnOff = step(1e-4f,cPack0.y); // cPack0.y >= epsilon
					fixed fAlpha = lerp(1,frac(_Time.y*cPack0.y),fWaveOnOff);
					o.oColor = saturate(fixed4(v.color.rgb * l_fPower,fAlpha)); //saturate was added to make the effect work properly with HDR.
	#else
					o.oColor = saturate(fixed4(v.color.rgb * l_fPower,1));	//saturate was added to make the effect work properly with HDR.
	#endif

					TRANSFER_VERTEX_TO_FRAGMENT(o);
					UNITY_TRANSFER_FOG(o,o.pos);
					return o;

	#undef GlowAxis
				}

				fixed4 FragGlow(V2FSimpleNoLight i) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(i);
					fixed4 col = tex2D(cDiffuseMap, i.oTexcoord0);
					UNITY_APPLY_FOG(i.fogCoord, col);
					col *= i.oColor;
					return col;
				}
				ENDCG
			}
		}
}
