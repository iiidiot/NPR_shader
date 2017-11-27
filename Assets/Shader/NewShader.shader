// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewShader" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim power",range(0,5)) = 2//边缘强度
    }
    SubShader {
        Pass
        {
        
        CGPROGRAM

        #include "UnityCG.cginc"

        struct v2f
        {
            float4 vertex:POSITION;
            float2 uv:TEXCOORD0;
            float4 rim:COLOR;
        };

        sampler2D _MainTex;
        float4 _RimColor;
        float _RimPower;

        v2f vert(appdata_base  v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 viewdir = normalize((_WorldSpaceCameraPos - worldPos));
            float3 normal = normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
            
            o.rim.x = 1-saturate(dot(viewdir,normal));

            return o;
        }

        fixed4 frag (v2f IN):COLOR
        {
            fixed4  c = tex2D(_MainTex, IN.uv);
            c.rgb+= pow(IN.rim.x,2)*_RimColor*_RimPower;
            return c;
        }

        #pragma vertex vert
        #pragma fragment frag

        ENDCG
        }
    } 
    FallBack "Diffuse"
}