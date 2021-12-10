Shader "Unlit/Sh_BasicLighting" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Texture",2D) = "white"{}
        _NormalMap("Normal map",2D) = "white"{}

        [KeywordEnum(Off,On)] _UseNormal("Use Normal Map?",float) = 0

        _Diffuse("Diffuse %",Range(0,1)) = 1
        [KeywordEnum(Off,Vert,Frag)] _Lighting("Ligthing mode",float) = 0

        
    }

    SubShader  //Sous shaders
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent" 
            "IgnoreProjector"="True"        
            
            "LightMode" = "ForwardBase"
        } 

        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma shader_feature_USENORMAL_OFF_USENORMAL_ON
            #pragma shader_feature_LIGHTING_OFF_LIGHTING_VERT_LIGHTING_FRAG

            #include "PraticeLighting.cginc"


            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;     
			
			uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;

            uniform float _Diffuse;
            uniform float4 _LightColor0;

            struct VertexInput
            {
                float4 vertex : POSITION;
				float4 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
    
                #if _USENORMAL_ON
				float4 tangent : TANGENT;
                #endif


            };

            //Informations qui sortent
            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
                float4 normalWorld : TEXCOORD1;

                #if _USENORMAL_ON
                float4 tangentWorld : TEXCOORD2;
                float3 binormalWorld : TEXCOORD3;
                float4 normalTexcoord : TEXCOORD4;

                #endif

                #if _LIGHTING_VERT
                float4 surfaceColor: COLOR0;

                #endif

            };

            float3 LambertDiffuse(float3 normal,float3 lightDir,float3 lightColor, float diffuseFactor,float attenuation)
            {
                return lightColor * diffuseFactor * attenuation * max(0,dot(normal,lightDir));
            }


            VertexOutput vert(VertexInput v) //Vertex Shaders -> prend les coordonnées de vertex puis on les transforme en coordonée écran
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw =0;
                o.texcoord.xy = (v.texcoord*_MainTex_ST.xy + _MainTex_ST.zw) ;


                #if _USENORMAL_ON
                o.normalTexcoord.xy = (v.texcoord*_NormalMap_ST.xy + _NormalMap_ST.zw) ;
                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));//Reverse ordre de multiplication 
                o.tangentWorld = normalize(mul(unity_ObjectToWorld,v.tangent));
                o.binormalWorld = normalize(cross(o.normalWorld,o.tangentWorld)*v.tangent.w);

                #else
                o.normalWorld = float4(UnityObjectToWorldNormal(v.normal),1);//Reverse ordre de multiplication 
                
                #endif

                #if _LIGHTING_VERT
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 lightColor = _LightColor0.xyz;
                float attenuation =1;
                o.surfaceColor = float4(LambertDiffuse(o.normalWorld,lightDir,lightColor,_Diffuse,attenuation),1.0);

                #endif

                return o; 
            }


            half4 frag(VertexOutput i) : COLOR //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                #if _USENORMAL_ON
                float3 worldNormalAtPixel = WorldNormalFromNormalMap(_NormalMap,i.normalTexcoord.xy,i.tangentWorld.xyz,i.binormalWorld.xyz,i.normalWorld.xyz);

                #else
                float3 worldNormalAtPixel = i.normalWorld.xyz;

                #endif
                

                #if _LIGHTING_FRAG
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 lightColor = _LightColor0.xyz;
                float attenuation = 1;
                return float4(LambertDiffuse(worldNormalAtPixel,lightDir,lightColor,_Diffuse,attenuation),1.0);

                #elif _LIGHTING_VERT
                return i.surfaceColor;

                #else
                return float4(worldNormalAtPixel,1);

                #endif



            }
            ENDCG
        }
    }
}
