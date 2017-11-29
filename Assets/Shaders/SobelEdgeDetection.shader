﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/sobel" {  
    Properties {  
        _MainTex ("MainTex", 2D) = "white" {}  
        _Size("Size", range(1,2048)) = 256//size  
        _Threshold("Threshold", range(0,2)) = 0.5
          
    }  
    SubShader {  
        pass{  
        Tags{"LightMode"="ForwardBase" }  
        Cull off  
        CGPROGRAM  
        #pragma vertex vert  
        #pragma fragment frag  
        #include "UnityCG.cginc"  
  
        float _Size;  
        sampler2D _MainTex;  
        float4 _MainTex_ST;  
        struct v2f {  
            float4 pos:SV_POSITION;  
            float2 uv_MainTex:TEXCOORD0;  
              
        };  
  
        v2f vert (appdata_full v) {  
            v2f o;  
            o.pos=UnityObjectToClipPos(v.vertex);  
            o.uv_MainTex = TRANSFORM_TEX(v.texcoord,_MainTex);  
            return o;  
        }  
        float _Threshold;
        float4 frag(v2f i):COLOR  
        {  
            float3 lum = float3(0.2125,0.7154,0.0721);//转化为luminance亮度值  
            float4 col = tex2D (_MainTex, i.uv_MainTex);
            //获取当前点的周围的点  
            //并与luminance点积，求出亮度值（黑白图）  
            float mc00 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(1,1)/_Size).rgb, lum);  
            float mc10 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(0,1)/_Size).rgb, lum);  
            float mc20 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(-1,1)/_Size).rgb, lum);  
            float mc01 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(1,0)/_Size).rgb, lum);  
            float mc11mc = dot(tex2D (_MainTex, i.uv_MainTex).rgb, lum);  
            float mc21 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(-1,0)/_Size).rgb, lum);  
            float mc02 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(1,-1)/_Size).rgb, lum);  
            float mc12 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(0,-1)/_Size).rgb, lum);  
            float mc22 = dot(tex2D (_MainTex, i.uv_MainTex-fixed2(-1,-1)/_Size).rgb, lum);  
            //根据过滤器矩阵求出GX水平和GY垂直的灰度值  
            float GX = -1 * mc00 + mc20 + -2 * mc01 + 2 * mc21 - mc02 + mc22;  
            float GY = mc00 + 2 * mc10 + mc20 - mc02 - 2 * mc12 - mc22;  
        //  float G = sqrt(GX*GX+GY*GY);//标准灰度公式  
            float G = abs(GX)+abs(GY);//近似灰度公式  
//          float th = atan(GY/GX);//灰度方向  
            float4 c = 0;  
          	c = G>_Threshold?0:1;  
//          c = G/th*2;  
            col *= c;
  
            return col;  
        }  
        ENDCG  
        }//  
  
    }   
}  