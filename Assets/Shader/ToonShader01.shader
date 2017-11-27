// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/toon" {  
    Properties {  
    	_MainTex ("Texture", 2D) = "white" {}
    	_RampTex ("RampTexture", 2D) = "white" {}
        _Color("Main Color",color)=(1,1,1,1)//物体的颜色  
        _Outline("Thick of Outline",range(0,0.1))=0.02//挤出描边的粗细  
        _Factor("Factor",range(0,1))=0.5//挤出多远  
        _ToonEffect("Toon Effect",range(0,1))=0.5//卡通化程度（二次元与三次元的交界线）  
        _Steps("Steps of toon",range(0,9))=3//色阶层数  
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
            float4 c=0;  
            return c;  
        }  
        ENDCG  
        }//end of pass  

        //pass2 for diffuse ramp
        pass{//平行光的的pass渲染  
        Tags{"LightMode"="ForwardBase"}  
        Cull Back  
        CGPROGRAM  
        #pragma vertex vert  
        #pragma fragment frag  
        #include "UnityCG.cginc"  

        sampler2D _RampTex;
        float3 DiffuseRampCoeff(in float3 lightDir, in float3 n) {
    		// Map value from [-1, 1] to [0, 1]
    		float rampCoord = dot(lightDir, n) * 0.5 + 0.5;
    		return tex2D(_RampTex, float2(rampCoord, rampCoord)).rgb;
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
        };  
  
        v2f vert (appdata_full v) {  
            v2f o;  
            o.pos=UnityObjectToClipPos(v.vertex);//切换到世界坐标  
            o.normal=normalize(v.normal);  
            o.lightDir=normalize(ObjSpaceLightDir(v.vertex));  
            o.viewDir=normalize(ObjSpaceViewDir(v.vertex));  
  			o.uv = v.texcoord;
            return o;  
        }  
        float4 frag(v2f i):COLOR  
        {  
        	// sample texture
            fixed4 col = tex2D(_MainTex, i.uv);

            float4 c=1;  
            float3 N=i.normal;  
            float3 viewDir=i.viewDir;  
            float3 lightDir=i.lightDir;  

            float3 ramp = DiffuseRampCoeff(lightDir, N);
  
            c.rgb =col.rgb*_Color.rgb*_LightColor0.rgb* ramp;//把最终颜色混合  
            c.a = col.a;
            return c;  
        }  
        ENDCG  
        }//  

        //pass3 for highlight
        pass{ 
        Tags{"LightMode"="ForwardAdd"}  
        Blend One One  
        Cull Back  
        ZWrite Off  
        CGPROGRAM  
        #pragma vertex vert  
        #pragma fragment frag  
        #include "UnityCG.cginc"  
  
        float4 _LightColor0;  
        float4 _Color;  
        float _Steps;  
        float _ToonEffect;  
  
        struct v2f {  
            float4 pos:SV_POSITION;  
            float3 lightDir:TEXCOORD1;  
            float3 viewDir:TEXCOORD2;  
            float3 normal:TEXCOORD3;  
        };  
  
        v2f vert (appdata_full v) {  
            v2f o;  
            o.pos=UnityObjectToClipPos(v.vertex);  
            o.normal=v.normal;  
            o.viewDir=ObjSpaceViewDir(v.vertex);  
            o.lightDir=_WorldSpaceLightPos0-v.vertex;  
            return o;  
        }  
        float4 frag(v2f i):COLOR  
        {  

            float4 c=1;  
            float3 N=normalize(i.normal);  
            float3 viewDir=normalize(i.viewDir);  
            float dist=length(i.lightDir);//求出距离光源的距离  
            float3 lightDir=normalize(i.lightDir);  
            float diff=max(0,dot(N,i.lightDir));  
            diff=(diff+1)/2;  
            diff=smoothstep(0,1,diff);  
            float atten=1/(dist);//根据距光源的距离求出衰减  
            float toon=floor(diff*atten*_Steps)/_Steps;  
            diff=lerp(diff,toon,_ToonEffect);  
  
            half3 h = normalize (lightDir + viewDir);//求出半角向量  
            float nh = max (0, dot (N, h));  
            float spec = pow (nh, 32.0);//求出高光强度  
            float toonSpec=floor(spec*atten*2)/ 2;//把高光也离散化  
            spec=lerp(spec,toonSpec,_ToonEffect);//调节卡通与现实高光的比重  
  
              
            c=_Color*_LightColor0*(diff+spec);//求出最终颜色  
            return c;  
        }  
        ENDCG  
        }//  
    }   
}  