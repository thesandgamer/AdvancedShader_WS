Shader "Unlit/Sh_VertAnimNormals" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Texture",2D) = "white"{}
        _Frequency("Frequence",float) = 0
        _Amplitude("Amplitude",float) = 0

        _Speed("Vitesse",float) = 0.5


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

            CGPROGRAM
            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            uniform float _Speed;

            uniform float _Frequency;
            uniform float _Amplitude;


            float4 vertexAnimNormal(float4 vertPos, float4 vertNormal,float2 uv)
            {
                vertPos += sin((vertNormal - _Time.y  * _Speed))*  _Frequency* _Amplitude* vertNormal;
                return vertPos;
            }

            struct VertexInput
            {
                float4 vertex : POSITION;
				float4 normal : NORMAL;
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
                v.vertex = vertexAnimNormal(v.vertex, v.normal ,v.texcoord);
            

                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw =0;
                o.texcoord.xy = (v.texcoord*_MainTex_ST.xy + _MainTex_ST.zw) ;
                return o; 
            }


            half4 frag(VertexOutput i) : COLOR //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                float4 color = tex2D(_MainTex,i.texcoord)*_Color;
                //color.a = drawCircle(i.texcoord.xy,_Center,_Radius,_Feather);
                return color;
            }
            ENDCG
        }
    }
}
