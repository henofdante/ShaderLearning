// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'


// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'



Shader "Custom/CompleteLight" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", float) = 20.0
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white"{}
        _BumpTex("Normal map", 2D) = "white"{}
        _BumpScale("Bump scale", float) = 1.0
    }

    SubShader {
        Pass {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase

                #include "Lighting.cginc"

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;
                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _BumpTex;
                float4 _BumpTex_ST;
                float _BumpScale;

                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float3 tangent: TANGENT;
                    float4 texcoord: TEXCOORD0;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float4 worldPos: TEXCOORD0;
                    float4 uv: TEXCOORD1;
                    float3 T2W0: TEXCOORD2;
                    float3 T2W1: TEXCOORD3;
                    float3 T2W2: TEXCOORD4;
                };


                v2f vert(a2v v) {
                    v2f ret;
                    // 顶点变换到投影空间
                    ret.pos = UnityObjectToClipPos(v.vertex);
                    // 法线变换到世界空间
                    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    float3 worldTangent = UnityObjectToWorldNormal(v.tangent);
                    // 顶点变换到世界空间
                    ret.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    // 根据设置变换uv
                    // <=> TRANSFORM_TEX(v.texcoord, _MainTex)
                    ret.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    ret.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                    float3 xa = worldTangent;
                    float3 za = worldNormal;
                    float3 ya = cross(za, xa);
                    ret.T2W0 = float3(xa.x, ya.x, za.x);
                    ret.T2W1 = float3(xa.y, ya.y, za.y);
                    ret.T2W2 = float3(xa.z, ya.z, za.z);
                    
                    return ret;
                }

                fixed3 frag(v2f frag) : SV_TARGET {
                    // 获取贴图颜色
                    fixed3 albedo = tex2D(_MainTex, frag.uv.xy) * _Color;
                    // ambient
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                    // 光线向量
                    float3 worldLight = normalize(UnityWorldSpaceLightDir(frag.worldPos));
                    // 提取法线贴图
                    fixed3 worldNormal = UnpackNormal(tex2D(_BumpTex, frag.uv.zw));
                    worldNormal.xy *= _BumpScale;
                    worldNormal.z = sqrt(1 - saturate(dot(worldNormal.xy, worldNormal.xy)));
                    worldNormal = normalize(fixed3(dot(worldNormal, frag.T2W0), dot(worldNormal, frag.T2W1), dot(worldNormal, frag.T2W2)));
                    // diffuse
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                    // specular Phong模型
                    float3 reflexDir = normalize(reflect(-worldLight, worldNormal));
                    float3 viewDir = normalize(_WorldSpaceCameraPos - (frag.worldPos.xyz)).xyz;
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflexDir, viewDir)), _Gloss);
                    //todo specular blinn模型
                    //float3 h = worldspacev
                    fixed attenuation = 1.0;

                    return fixed4(ambient * albedo + (diffuse * albedo + specular) * attenuation, 1.0);
                }
            ENDCG
        }
        
        Pass {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One

            CGPROGRAM
                #pragma multi_compile_fwdadd
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"
                #include "AutoLight.cginc"

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;
                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _BumpTex;
                float4 _BumpTex_ST;
                float _BumpScale;

                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float3 tangent: TANGENT;
                    float4 texcoord: TEXCOORD0;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float4 worldPos: TEXCOORD0;
                    float4 uv: TEXCOORD1;
                    float3 T2W0: TEXCOORD2;
                    float3 T2W1: TEXCOORD3;
                    float3 T2W2: TEXCOORD4;
                };


                v2f vert(a2v v) {
                    v2f ret;
                    // 顶点变换到投影空间
                    ret.pos = UnityObjectToClipPos(v.vertex);
                    // 法线变换到世界空间
                    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    float3 worldTangent = UnityObjectToWorldNormal(v.tangent);
                    // 顶点变换到世界空间
                    ret.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    // 根据设置变换uv
                    // <=> TRANSFORM_TEX(v.texcoord, _MainTex)
                    ret.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    ret.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                    float3 xa = worldTangent;
                    float3 za = worldNormal;
                    float3 ya = cross(za, xa);
                    ret.T2W0 = float3(xa.x, ya.x, za.x);
                    ret.T2W1 = float3(xa.y, ya.y, za.y);
                    ret.T2W2 = float3(xa.z, ya.z, za.z);
                    
                    return ret;
                }

                fixed3 frag(v2f frag) : SV_TARGET {
                    // 获取贴图颜色
                    fixed3 albedo =  _Color;
                    // ambient
                    // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                    // 光线向量
                    float3 worldLight = normalize(UnityWorldSpaceLightDir(frag.worldPos));
                    // 提取法线贴图
                    fixed3 worldNormal = UnpackNormal(tex2D(_BumpTex, frag.uv.zw));
                    worldNormal.xy *= _BumpScale;
                    worldNormal.z = sqrt(1 - saturate(dot(worldNormal.xy, worldNormal.xy)));
                    worldNormal = normalize(fixed3(dot(worldNormal, frag.T2W0), dot(worldNormal, frag.T2W1), dot(worldNormal, frag.T2W2)));
                    // diffuse
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                    // specular Phong模型
                    float3 reflexDir = normalize(reflect(-worldLight, worldNormal));
                    float3 viewDir = normalize(_WorldSpaceCameraPos - (frag.worldPos.xyz)).xyz;
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflexDir, viewDir)), _Gloss);
                    //todo specular blinn模型
                    //float3 h = worldspacev
                    fixed attenuation = 1.0;

                    #ifndef USING_DIRECTIONAL_LIGHT
                        float3 lightPos = mul(unity_WorldToLight, float4(frag.worldPos));
                        //attenuation = tex2D(_LightTexture0, dot(lightPos, lightPos);
                        attenuation = tex2D(_LightTexture0, dot(lightPos, lightPos).xx).UNITY_ATTEN_CHANNEL;
                    #endif
                    return fixed4((diffuse * albedo + specular) * attenuation, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

