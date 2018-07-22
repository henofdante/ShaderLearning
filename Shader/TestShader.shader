// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TestShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	// SubShader {
	// 	Tags { "RenderType"="Opaque" }
	// 	LOD 200

	// 	CGPROGRAM
	// 	// Physically based Standard lighting model, and enable shadows on all light types
	// 	#pragma surface surf Standard fullforwardshadows

	// 	// Use shader model 3.0 target, to get nicer looking lighting
	// 	#pragma target 3.0

	// 	sampler2D _MainTex;

	// 	struct Input {
	// 		float2 uv_MainTex;
	// 	};

	// 	half _Glossiness;
	// 	half _Metallic;
	// 	fixed4 _Color;

	// 	// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// 	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// 	// #pragma instancing_options assumeuniformscaling
	// 	UNITY_INSTANCING_BUFFER_START(Props)
	// 		// put more per-instance properties here
	// 	UNITY_INSTANCING_BUFFER_END(Props)

	// 	void surf (Input IN, inout SurfaceOutputStandard o) {
	// 		// Albedo comes from a texture tinted by color
	// 		fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
	// 		o.Albedo = 0;
	// 		//o.Albedo = c.rgb;
	// 		// Metallic and smoothness come from slider variables
	// 		o.Metallic = _Metallic;
	// 		o.Smoothness = _Glossiness;
	// 		o.Alpha = c.a;
	// 		//ABCDEFG
	// 		//abcdefg
	// 	}
	// 	ENDCG
	// }
	SubShader {
		Pass {

			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 

			#include "Lighting.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				//float3 wnormal : TEXCOORD0;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				float3 worldnormal = mul(v.normal, unity_WorldToObject);
				float3 worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldlightdir = _WorldSpaceLightPos0.xyz;
				float3 ambient = 0.4;
				float3 lightdir = normalize(float3(1.0, 1.0, 1.0));
				
				// diffuse in half-lambert
				fixed3 diffuse = 0.5 * dot(worldnormal, worldlightdir) + 0.5;

				// specular
				
				fixed3 reflectdir = normalize(reflect(-worldlightdir, worldnormal));
				fixed3 viewdir = normalize(_WorldSpaceCameraPos.xyz - worldpos);
				fixed3 specular = pow(saturate(dot(reflectdir, viewdir)), 7);
				o.color = 0.1 * diffuse + 0.1 * ambient + 1.0 * specular;
				// mul(v.normal, )
				return o;
			}

			fixed3 frag(v2f f) : SV_TARGET {
				return f.color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
