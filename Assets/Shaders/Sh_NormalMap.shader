Shader "Unlit/Sh_NormalMap" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Texture",2D) = "white"{}
        _NormalMap("Normal map",2D) = "white"{}

        [KeywordEnum(Off,On)] _UseNormal("Use Normal Map?",float) = 0
        
    }

    SubShader  //Sous shaders
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent" 
            "IgnoreProjector"="True"        
        } 

        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma shader_feature_USENORMAL_OFF_USENORMAL_ON
            #include "PraticeLighting.cginc"

            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;     
			
			uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;

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
            };


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

                return o; 
            }


            half4 frag(VertexOutput i) : COLOR //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                #if _USENORMAL_ON
                float3 worldNormalAtPixel = WorldNormalFromNormalMap(_NormalMap,i.normalTexcoord.xy,i.tangentWorld.xyz,i.binormalWorld.xyz,i.normalWorld.xyz);
                return float4(worldNormalAtPixel,1);

                #else
                return float4(i.normalWorld.xyz,1);

                #endif
            }
            ENDCG
        }
    }
}
