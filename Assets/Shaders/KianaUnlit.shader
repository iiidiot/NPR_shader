Shader "NPR/KianaUnlit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

   	 	_Outline("Thick of Outline",range(0,0.1))=0.02
   	 	_Factor("Factor",range(0,1))=0.5
    	_ToonEffect("Toon Effect",range(0,1))=0.5
    	_Steps("Steps of toon",range(0,9))=3
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			// indicate that our pass is the "base" pass in forward
            // rendering pipeline. It gets ambient and main directional
            // light data set up; light direction in _WorldSpaceLightPos0
            // and color in _LightColor0
            Tags {"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			//appdata_base: position, normal and one texture coordinate.

			#include "UnityLightingCommon.cginc" // for _LightColor0

        	float4 _Color;  
        	float _Steps;  
        	float _ToonEffect;  

			 struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 diff : COLOR0; // diffuse lighting color
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                // get vertex normal in world space
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));

                nl=nl/2 + 0.5;//lighten
                float toon=floor(nl*_Steps)/_Steps;
                nl=lerp(nl,toon,_ToonEffect);

                o.diff = nl * _LightColor0;
                return o;
            }
            
            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // multiply by lighting
                col *= i.diff;
                return col;
            }
			ENDCG
		}
	}
}
