Shader "Unlit/LavaWater"
{
	Properties
	{
		_Tint("Tint", Color) = (1, 1, 1, .5) 
		_MainTex ("Main Texture", 2D) = "white" {}
		_NoiseTex("Extra Wave Noise", 2D) = "white" {}
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_ScrollSpd("Tiling Speed", Vector) = (1,1,0,0)
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Foam("Foamline Thickness", Range(0,3)) = 0.5
		_AlphaVal ("AlphaVal", Range (0,1) ) = 1.0
		_Emission("Emission", float) = 0
        [HDR] _EmissionColor("Color", Color) = (0,0,0)
 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
 
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uvA : TEXCOORD1;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvA : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
				//float4 scrPos : TEXCOORD1;//
			};
 
			float4 _Tint;
			uniform sampler2D _CameraDepthTexture; //Depth Texture
			sampler2D _MainTex, _NoiseTex;//
			float4 _MainTex_ST, _NoiseTex_ST, _ScrollSpd;;
			float _Speed, _Amount, _Height, _Foam;//
			fixed4 _EmissionColor;
			float _alphaVal;
 
			v2f vert (appdata v)
			{
				v2f o;
				//float4 tex = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));//extra noise tex
				//v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount * tex)) * _Height; //movement
				
				v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount)) * _Height; //movement
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex).xy + frac(_Time.y * float2(_ScrollSpd.x, _ScrollSpd.y));
				o.uvA = TRANSFORM_TEX(v.uvA, _NoiseTex).xy + frac(_Time.y * float2(-_ScrollSpd.x/1.5, -_ScrollSpd.y/1.5));
				//o.uv += TRANSFORM_TEX(v.uv, _NoiseTex).xy + frac(_Time.y* float2(_ScrollSpd.x*2, _ScrollSpd.y*2));
				//o.Emission = tex.rgb * tex2D(_MainTex, IN.uv_MainTex).a * _EmissionColor;
				//o.scrPos = ComputeScreenPos(o.vertex); // grab position on screen
				UNITY_TRANSFER_FOG(o,o.vertex);
 
				return o;
			}
 
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 main = tex2D(_MainTex, i.uv);
				fixed4 tex2 = tex2D(_NoiseTex, i.uvA);
				tex2.a /= 4;
				half4 col = tex2D(_MainTex, i.uv) * _Tint;// texture times tint;
				col.rgb = lerp(col.rgb, tex2.rgb, tex2.a);
				//
				//col = lerp(col, tex2, tex2.a);
				//half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos))); // depth
				//half4 foamLine =1 - saturate(_Foam * (depth - i.scrPos.w));// foam line by comparing depth and screenposition
				//col += foamLine * _Tint; // add the foam line and tint to the texture
				//tex2.a = 0.25;
				//return main*=tex2;
				//return fixed4(main.r, main.g, main.b, (main.a*tex2.r));
				return col ;
			}
			ENDCG
		}
	}
}