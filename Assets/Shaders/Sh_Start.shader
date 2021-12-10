Shader "Unlit/Sh_Start" // où est rangé le shader dans le projet
{

    Properties
    {
        _Color("Color",Color) = (1,0,0,1)
    }

    SubShader  //Sous shaders
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "RenderType"="Transparent" 
            "IgnoreProjector"="True"        
        } //Informations: rending queue

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert  //Init le vertex shader
            #pragma fragment frag //Init le fragment shader

            #include "UnityCG.cginc"



            //Fait passer des informations
            struct appdata
            {
                float4 vertex : POSITION;
            };

            //Informations qui sortent
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) //Vertex Shaders -> prend les coordonnées de vertex puis on les transforme en coordonée écran
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o; //Sort un v2f
            }

            fixed4 _Color;

            fixed4 frag (v2f i) : SV_Target //Fragment shader -> prend un v2f et sort une couleur
            {
                // sample the texture
                return _Color;
            }
            ENDCG
        }
    }
}
