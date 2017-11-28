// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/toonHair" {  
    Properties {  
    	_MainTex ("Texture", 2D) = "white" {}
      	_RampTex ("RampTex", 2D) = "white" {}
      	_SpecRampTex ("SpecRampTex", 2D) = "white" {}
      	_JitterMap ("JitterMap", 2D) = "white" {}

        _Color("Main Color",color)=(1,1,1,1)//物体的颜色  
        _OutlineColor("Outline Color",color)=(1,1,1,1)//物体的颜色 
        _Outline("Thick of Outline",range(0,0.1))=0.02//挤出描边的粗细  
        _Factor("Factor",range(0,1))=0.5//挤出多远  

        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim power",range(0,5)) = 2//边缘强度

        _SpecColor("Spec Color",color)=(1,1,1,1)
        _SpecPower("Spec Power", range(0,1000)) = 100
        _SpecStr("Spec Strength", range(0,100)) = 1
        _JitterPower("Jitter power",range(0,10)) = 2
        _SpecAddFactor("SpecAddFactor",range(0,1)) = 0.5
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

        float _SpecPower;
        float _SpecStr;
        float specCoef(float3 lightDir, float3 viewDir, float3 t)
        {
        	float3 H = normalize(lightDir+viewDir);
        	float dotTH = dot(t, H);
        	float sqrTH = sqrt(1 - dotTH*dotTH); 
        	float atten = smoothstep(-1, 0, dotTH);
        	return atten*pow(sqrTH, _SpecPower)*_SpecStr;
        }
  
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
            float spec:COLOR2;
        };  

        half _RampR;
      	sampler2D _RampTex;
      	float4 _RimColor;
        float4 _SpecColor; 
        float _RimPower;
        sampler2D _SpecRampTex;
        sampler2D _JitterMap;
        float _JitterPower;
        float _SpecAddFactor;

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

            //hightlight
            float3 Kcoord = tex2Dlod(_JitterMap, float4(dif_hLambert,dif_hLambert,0,0)).rgb;
            float K = Kcoord.r + Kcoord.g + Kcoord.b; 
            if(Kcoord.r<=0.5)
            {
            	K = 0;
            }
            float3 T1 = normalize(v.tangent.xyz + o.normal*K*_JitterPower);
            float3 T2 = normalize(v.tangent.xyz + o.normal*K);
            o.spec = specCoef(o.lightDir,o.viewDir,T1) + _SpecAddFactor*specCoef(o.lightDir,o.viewDir,T2);
			return o;
        }  
        float4 frag(v2f i):COLOR  
        {  
        	// sample texture
            fixed4 col = tex2D(_MainTex, i.uv);

            float4 c=1;  
            c = col*i.diff*_Color*_LightColor0 + 
            i.spec*_SpecColor;

            return c;  
        }  
        ENDCG  
        }//  

        //pass3 for highlight
       
    }   
}  