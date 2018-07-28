// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/BasicLightShaderPhong" {
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
                    float4 worldPos: TEXCOORD0;
                    float3 worldNormal: TEXCOORD1;
            };


                    v2f vert(a2v v) {
                    v2f ret;
                    // 顶点变换到投影空间
                    ret.pos = UnityObjectToClipPos(v.vertex);
                    // 法线变换到世界空间
                    ret.worldNormal = UnityObjectToWorldNormal(v.normal);
                    // 顶点变换到世界空间
                    ret.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    // 环境光
                    return ret;
                }

                fixed3 frag(v2f frag) : SV_TARGET {
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                    // 光线向量
                    float3 worldLight = normalize(UnityWorldSpaceLightDir(frag.worldPos));
                    // diffuse
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(frag.worldNormal, worldLight));
                    // specular Phong模型
                    float3 reflexDir = normalize(reflect(-worldLight, frag.worldNormal));
                    float3 viewDir = normalize(_WorldSpaceCameraPos - (frag.worldPos.xyz)).xyz;
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflexDir, viewDir)), _Gloss);

                    return fixed4(ambient + diffuse + specular, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}