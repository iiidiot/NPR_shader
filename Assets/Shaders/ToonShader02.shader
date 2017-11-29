// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/Toon/Hair" {  
    Properties {  
    	_MainTex ("Texture", 2D) = "white" {}
      	_RampTex ("Ramp Texture", 2D) = "white" {}

        _Color("Main Color",color)=(1,1,1,1)//物体的颜色  
        _OutlineColor("Outline Color",color)=(1,1,1,1)//物体的颜色 
        _Outline("Thick of Outline",range(0,0.1))=0.0//挤出描边的粗细  
        _Factor("Factor",range(0,1))=0.5//挤出多远  

        _SpecularColor ("Specular Color", Color) = (1,1,1,1)//高光颜色  
        _SpecPower ("Specular Power", Range(0,30)) = 2//高光强度  
        _Specular ("Specular Amount", Range(0, 1)) = 0.5  
        _AnisoDir ("Anisotropic Direction", 2D) = ""{}//各向异性方向法线贴图  
        _AnisoOffset("Anisotropic Offset", Range(-1,1)) = -0.2//_AnisoOffset的作用偏移  
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

			o.diff.rgb = ramp;
			o.diff.a = 1; 

			return o;
        }  

        sampler2D _AnisoDir;//各向异性的  
        float4 _SpecularColor;  
        float _AnisoOffset;  
        float _Specular;  
        float _SpecPower;  
        float4 frag(v2f i):COLOR  
        {  
        	// sample texture
            fixed4 col = tex2D(_MainTex, i.uv);
            float3 AnisoDirection = UnpackNormal(tex2D(_AnisoDir, i.uv));  

            fixed3 halfVector = normalize(i.lightDir + i.viewDir);//normalize()函数把向量转化成单位向量  
  
            float NdotL = saturate(dot(i.normal, i.lightDir));  
  
            fixed HdotA = dot(normalize(i.normal + AnisoDirection), halfVector);  
            float aniso = max(0, sin(radians((HdotA + _AnisoOffset) * 180.0)));//radians()函数将角度值转换为弧度值   
  
            float spec = saturate(pow(aniso, _SpecPower * 128) * _Specular);//saturate(x）函数   如果x小于0返回 0;如果x大于1返回1;否则返回x;把x限制在0-1  
  
  
            fixed4 c;  
            c.rgb = ((col*i.diff*_Color*_LightColor0).rgb + (_LightColor0.rgb * _SpecularColor.rgb * spec));  
            c.a = 1.0;  
            return c;  
        }  
        ENDCG  
        }//  

        //pass3 for highlight
       
    }   
}  