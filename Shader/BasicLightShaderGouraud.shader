Shader "Custom/BasicLightShaderGouraud" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", float) = 4.0
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;
				struct a2v {
					float4 vertex: POSITION;
					float3 normal: NORMAL;
				};
				struct v2f {
					float4 pos: SV_POSITION;
					fixed3 color: COLOR;
				};

				v2f vert(a2v v) {
					v2f ret;
					// 顶点变换到投影空间
					ret.pos = UnityObjectToClipPos(v.vertex);
					// 法线变换到世界空间
					float3 worldNormal = UnityObjectToWorldNormal(v.normal);
					// 环境光
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
					// 光线向量
					float3 worldLight = normalize(UnityWorldSpaceLightDir(v.vertex));
					// diffuse
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
					// specular
					float3 reflexDir = normalize(reflect(-worldLight, worldNormal));
					float3 viewDir = normalize(_WorldSpaceCameraPos - UnityObjectToWorldDir(v.vertex.xyz)).xyz;
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflexDir, viewDir)), _Gloss);
					
					ret.color = ambient + diffuse + specular;
					return ret;
				}

				fixed3 frag(v2f frag) : SV_TARGET {
					return fixed4(frag.color, 1.0);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
