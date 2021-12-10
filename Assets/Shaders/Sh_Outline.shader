Shader "Unlit/Sh_Outline" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Texture",2D) = "white"{}
        _Outline("Outline",float) = 0.1
        _OutlineColor("Outline Color",Color) = (1,1,1,1)
       // _Material("Base mat",material) = "noone"{}
        
    }

    SubShader  //Sous shaders
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent" 
            "IgnoreProjector"="True"        
        } 

        //Draw outline
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull front
            Zwrite off

            CGPROGRAM
            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half _Outline;
            uniform half4 _OutlineColor;    

            struct VertexInput
            {
                float4 vertex : POSITION;
            };

            //Informations qui sortent
            struct VertexOutput
            {
                float4 pos : SV_POSITION;
            };

            float4 outline(float4 pos, float outline)
            {
                float4x4 scale = 0.0; //Matrice de scale
                scale[0][0] = 1.0 + outline;
                scale[1][1] = 1.0 + outline;
                scale[2][2] = 1.0 + outline;
                scale[3][3] = 1.0 ;
                return mul(scale,pos); //Retourne la mutliplication de la scale par la position
            }

            VertexOutput vert(VertexInput v) //Vertex Shaders -> prend les coordonnées de vertex puis on les transforme en coordonée écran
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(outline(v.vertex,_Outline));
                return o;

            }


            half4 frag(VertexOutput i) : COLOR //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                return _OutlineColor;
            }
            ENDCG
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;

            };

            //Informations qui sortent
            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            VertexOutput vert(VertexInput v) //Vertex Shaders -> prend les coordonnées de vertex puis on les transforme en coordonée écran
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw =0;
                o.texcoord.xy = (v.texcoord*_MainTex_ST.xy + _MainTex_ST.zw) ;
                return o; 
            }


            half4 frag(VertexOutput i) : COLOR //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                return tex2D(_MainTex,i.texcoord)*_Color;
            }
            ENDCG
        }
    }
}
