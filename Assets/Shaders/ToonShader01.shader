// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/Toon/Face" {  
    Properties {  
    	_Step ("Color Step", Range(1, 100)) = 10
    	_MainTex ("Texture", 2D) = "white" {}
      	_RampTex ("Texture", 2D) = "white" {}
      	_RampR ("Ramp Red Factor", Range(0,1)) = 0.5

        _Color("Main Color",color)=(1,1,1,1)//物体的颜色  
        _OutlineColor("Outline Color",color)=(1,1,1,1)//物体的颜色 
        _Outline("Thick of Outline",range(0,0.1))=0.0//挤出描边的粗细  
        _Factor("Factor",range(0,1))=0.5//挤出多远  
        _ToonEffect("Toon Effect",range(0,1))=0.5//卡通化程度（二次元与三次元的交界线）  
        _Steps("Steps of toon",range(0,9))=3//色阶层数  

        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim power",range(0,5)) = 2//边缘强度
    }  
    SubShader {
    	//pass1 for outline  
        pass{  
        Tags{"LightMode"="Always"}  
        Cull Front  
        ZWrite On  
        CGPROGRAM  
        #pragma vertex vert  
        #pragma fragment frag  
        #include "UnityCG.cginc"  
        float _Outline;  
        float _Factor;  
        float4 _OutlineColor;
        struct v2f {  
            float4 pos:SV_POSITION;  
        };  
  
        v2f vert (appdata_full v) {  
            v2f o;  
            float3 dir=normalize(v.vertex.xyz);  
            float3 dir2=v.normal;  
            float D=dot(dir,dir2);  
            dir=dir*sign(D);  
            dir=dir*_Factor+dir2*(1-_Factor);  
            v.vertex.xyz+=v.normal*_Outline;  
            o.pos=UnityObjectToClipPos(v.vertex);  
            return o;  
        }  
        float4 frag(v2f i):COLOR  
        {  
            float4 c=_OutlineColor;  
            return c;  
        }  
        ENDCG  
        }//end of pass  

        //pass2 for diffuse
        pass{//平行光的的pass渲染  
        Tags{"LightMode"="ForwardBase"}  
        Cull Back  
        CGPROGRAM  
        #pragma vertex vert  
        #pragma fragment frag  
        #include "UnityCG.cginc"  
  
        float4 _LightColor0;  
        float4 _Color;  
        float _Steps;  
        float _ToonEffect;  
        sampler2D _MainTex;
  
        struct v2f {  
            float4 pos:SV_POSITION;  
            float2 uv : TEXCOORD0;
            float3 lightDir:TEXCOORD1;  
            float3 viewDir:TEXCOORD2;  
            float3 normal:TEXCOORD3;
            float4 diff:COLOR0; // diffuse lighting color  
            float4 rim:COLOR1;
        };  

        half _RampR;
      	sampler2D _RampTex;
      	float4 _RimColor;
        float _RimPower;
        v2f vert (appdata_full v) {  
            v2f o;  
            o.pos=UnityObjectToClipPos(v.vertex);//切换到世界坐标  
            o.normal=normalize(v.normal);  
            o.lightDir=normalize(ObjSpaceLightDir(v.vertex));  
            o.viewDir=normalize(ObjSpaceViewDir(v.vertex));  
  			o.uv = v.texcoord;

            float difLight = max(0, dot (o.normal, o.lightDir));  
        	float dif_hLambert = difLight * 0.5 + 0.5;   
        
              
       		float rimLight = max(0, dot (o.normal, o.viewDir));    
        	float rim_hLambert = rimLight * 0.5 + 0.5;   
              
        	float3 ramp = tex2Dlod(_RampTex, float4(dif_hLambert, dif_hLambert,0,0)).rgb;     
        	ramp.r = ramp.r+_RampR;

			o.diff.rgb = ramp;
			o.diff.a = 1; 

			//rim light
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			float3 viewdir = normalize((_WorldSpaceCameraPos - worldPos));
            float3 normal = normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
            
            o.rim.x = 1-saturate(dot(viewdir,normal));
			return o;
        }  

        float _Step;
        float toon(float col, float n)
        {
        	float t=floor(col*n)/n;
        	return t;
        }
        float4 frag(v2f i):COLOR  
        {  
        	// sample texture
            fixed4 col = tex2D(_MainTex, i.uv);

            float4 c=1;  
            c = col*i.diff*_Color*_LightColor0 + (pow(i.rim.x,2))*_RimColor*_RimPower;//把最终颜色混合  
            c.r = toon(c.r,_Step);
            c.g = toon(c.g,_Step);
            c.b = toon(c.b,_Step);
            return c;  
        }  
        ENDCG  
        }//  

        //pass3 for highlight
       
    }   
}  