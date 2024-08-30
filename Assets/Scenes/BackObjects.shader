Shader "Custom/BackObjects"
{
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		//_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainTex("Texture", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_RefNumber("Reference number", Int) = 255

		_OutlineColor("Outline Color", Color) = (0, 0, 0, 0)
		_OutlineWidth("Outline Width", Range(1.0,1.5)) = 1.1

	}
		SubShader
		{
			Tags {
				"RenderType" = "Transparent"
				"Queue" = "Transparent+1"
				"ForceNoShadowCasting" = "True"
			}
			
			//ZTest[unity_GUIZTestMode] // can only see thru portal & shader ZTest mode : unity_GUIZTestMode
			ZTest Always // can only see thru portal & always show on the bottom 
			Blend SrcAlpha OneMinusSrcAlpha
			//ZWrite Off
			LOD 200
			Cull Off // for two-sides rendering


			Stencil {
				Ref[_RefNumber]
				Comp equal
			}



			//ADD for highlighting https://www.codinblack.com/shader-pass-and-multi-pass-shader/

			Pass
			{
				Cull Front
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				fixed4 _OutlineColor;
				float _OutlineWidth;
				struct appdata
				{
					float4 vertex:POSITION;

					UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
				};
				struct v2f
				{
					float4 clipPos:SV_POSITION;

					UNITY_VERTEX_OUTPUT_STEREO //Insert
				};
				v2f vert(appdata v)
				{
					v2f o;

					UNITY_SETUP_INSTANCE_ID(v); //Insert
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);  //Insert

					o.clipPos = UnityObjectToClipPos(v.vertex * _OutlineWidth);
					return o;
				}
				fixed4 frag(v2f i) : SV_Target
				{
					return _OutlineColor;
				}
				ENDCG
			}
			//ADD

			Pass{
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
					sampler2D _MainTex;
					float4 _MainTex_ST;

					fixed4 _Color;

					struct appdata {
						float4 vertex : POSITION;
						float2 uv : TEXCOORD0;

						UNITY_VERTEX_INPUT_INSTANCE_ID //Insert the stereo instancing parameter
					};

					struct v2f {
						float4 position : SV_POSITION;
						float2 uv : TEXCOORD0;

						UNITY_VERTEX_OUTPUT_STEREO //Insert stereo instancing parameter // https://www.reddit.com/r/vive_vr/comments/p9jkyg/unity_a_gameobject_is_only_being_rendered_in_one/
					};

					v2f vert(appdata v) {
						v2f o;

						UNITY_SETUP_INSTANCE_ID(v); //Insert stereo instancing parameter
						UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);  //Insert stereo instancing parameter

						o.position = UnityObjectToClipPos(v.vertex);
						o.uv = TRANSFORM_TEX(v.uv, _MainTex);
						return o;
					}

					fixed4 frag(v2f i) : SV_TARGET{
						fixed4 col = tex2D(_MainTex, i.uv);
						col *= _Color;
						return col;
					}

					ENDCG
			}





					//CGPROGRAM
					//		// Physically based Standard lighting model, and enable shadows on all light types
					//		 #pragma surface surf Standard fullforwardshadows
					//		 //#pragma surface surf Lambert alpha

					//		// Use shader model 3.0 target, to get nicer looking lighting
					//		#pragma target 3.0

					//		sampler2D _MainTex;

					//		struct Input {
					//			float2 uv_MainTex;
					//		};

					//		half _Glossiness;
					//		half _Metallic;
					//		fixed4 _Color;

					//		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
					//		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
					//		// #pragma instancing_options assumeuniformscaling
					//		UNITY_INSTANCING_BUFFER_START(Props)
					//			// put more per-instance properties here
					//		UNITY_INSTANCING_BUFFER_END(Props)

					//		void surf(Input IN, inout SurfaceOutputStandard o) {
					//			// Albedo comes from a texture tinted by color
					//			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					//			o.Albedo = c.rgb;
					//			// Metallic and smoothness come from slider variables
					//			o.Metallic = _Metallic;
					//			o.Smoothness = _Glossiness;
					//			o.Alpha = c.a;
					//		}

					//		ENDCG

		}

			//FallBack "Diffuse"
}
