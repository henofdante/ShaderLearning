
Shader "Custom/BasicTexture" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", float) = 20.0
        _MainTex ("Texture", 2D) = "white"{}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
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
                sampler2D _MainTex;
                fixed4 _Color;
                float4 _MainTex_ST;
                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float4 texcoord: TEXCOORD0;
                };
                struct v2f {
                    float4 pos: SV_POSITION;
                    float4 worldPos: TEXCOORD0;
                    float3 worldNormal: TEXCOORD1;
                    float2 uv: TEXCOORD2;
            };


                    v2f vert(a2v v) {
                    v2f ret;
                    // 顶点变换到投影空间
                    ret.pos = UnityObjectToClipPos(v.vertex);
                    // 法线变换到世界空间
                    ret.worldNormal = UnityObjectToWorldNormal(v.normal);
                    // 顶点变换到世界空间
                    ret.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    // 根据设置变换uv
                    // <=> TRANSFORM_TEX(v.texcoord, _MainTex)
                    ret.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    return ret;
                }

                fixed3 frag(v2f frag) : SV_TARGET {
                    fixed3 albedo = tex2D(_MainTex, frag.uv) * _Color;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                    // 光线向量
                    float3 worldLight = normalize(UnityWorldSpaceLightDir(frag.worldPos));
                    // diffuse
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(frag.worldNormal, worldLight));
                    // specular Phong模型
                    float3 reflexDir = normalize(reflect(-worldLight, frag.worldNormal));
                    float3 viewDir = normalize(_WorldSpaceCameraPos - (frag.worldPos.xyz)).xyz;
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflexDir, viewDir)), _Gloss);
                    // specular blinn模型
                    //float3 h = worldspacev

                    return fixed4(ambient * albedo + diffuse * albedo + specular * albedo, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}