Shader "Unlit/Sh_Ring" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Texture",2D) = "white"{}
        _Center("Centre",float) = 0.5
        _Radius("Rayon",float) = 0.5
        _Width("Epaisseur",Range(0,1)) = 0.01

        
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
            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Center;
            uniform float _Radius;
            uniform float _Width;


            float drawCircle(float2 uv, float2 center,float radius)
            {
                float circle = pow((uv.y - center.y),2) + pow((uv.x - center.x),2);
                float radiusSquare = pow(radius,2);
                if ((circle < radiusSquare + _Width)&&(circle > radiusSquare - _Width))
                {
                    return 1;
                }
                return 0;

            }

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
                float4 color = tex2D(_MainTex,i.texcoord)*_Color;
                color.a = drawCircle(i.texcoord.xy,_Center,_Radius);
                return color;
            }
            ENDCG
        }
    }
}
