Shader "NPR/ToonShader02"
{
	Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _Amount ("Extrusion Amount", Range(-1,1)) = 0.5
      _RampTex ("Texture", 2D) = "white" {}
      _RampR ("Ramp Red Factor", Range(0,1)) = 0.5
	  _RimColor("Rim Color", Color) = (1,1,1,1)
      _RimPower ("Rim power",range(0,5)) = 2//边缘强度
    }
    SubShader {
     

	  
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Ramp vertex:vert
	 //lighting model
      half _RampR;
      sampler2D _RampTex;
      half4 LightingRamp (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
        float difLight = max(0, dot (s.Normal, lightDir));  
        float dif_hLambert = difLight * 0.5 + 0.5;   
        
              
        float rimLight = max(0, dot (s.Normal, viewDir));    
        float rim_hLambert = rimLight * 0.5 + 0.5;   
              
        float3 ramp = tex2D(_RampTex, float2(dif_hLambert, dif_hLambert)).rgb;     
        ramp.r = ramp.r+_RampR;

		float4 col;
		col.rgb = s.Albedo * _LightColor0.rgb * ramp;
		col.a = s.Alpha;
		return col;
      }

      //vert shader
      float _Amount;
      void vert (inout appdata_full v) {
          //v.vertex.xyz += v.normal * _Amount;
      }

      //surf shader
      sampler2D _MainTex;
      struct Input {
          float2 uv_MainTex;
      };

      void surf (Input IN, inout SurfaceOutput o) {
          o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
      }
      ENDCG
	  
	  
    } 



    Fallback "Diffuse"
}
