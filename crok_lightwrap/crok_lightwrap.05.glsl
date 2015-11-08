// based on https://www.shadertoy.com/view/XdlGz8 P_Malin
// Using a sobel filter to create a normal map and then applying simple lighting.

uniform sampler2D, adsk_results_pass4;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform vec3 LightBulb;
uniform bool relight;

// This makes the darker areas less bumpy but I like it
//#define USE_LINEAR_FOR_BUMPMAP

struct C_Sample
{
	vec3 vAlbedo;
	vec3 vNormal;
};
	
C_Sample SampleMaterial(const in vec2 vUV, sampler2D sampler,  const in vec2 vTextureSize, const in float fNormalScale)
{
	C_Sample result;
	
	vec2 vInvTextureSize = vec2(1.0) / vTextureSize;
	
	vec3 cSampleNegXNegY = texture2D(sampler, vUV + (vec2(-1.0, -1.0)) * vInvTextureSize.xy).rgb;
	vec3 cSampleZerXNegY = texture2D(sampler, vUV + (vec2( 0.0, -1.0)) * vInvTextureSize.xy).rgb;
	vec3 cSamplePosXNegY = texture2D(sampler, vUV + (vec2( 1.0, -1.0)) * vInvTextureSize.xy).rgb;
	
	vec3 cSampleNegXZerY = texture2D(sampler, vUV + (vec2(-1.0, 0.0)) * vInvTextureSize.xy).rgb;
	vec3 cSampleZerXZerY = texture2D(sampler, vUV + (vec2( 0.0, 0.0)) * vInvTextureSize.xy).rgb;
	vec3 cSamplePosXZerY = texture2D(sampler, vUV + (vec2( 1.0, 0.0)) * vInvTextureSize.xy).rgb;
	
	vec3 cSampleNegXPosY = texture2D(sampler, vUV + (vec2(-1.0,  1.0)) * vInvTextureSize.xy).rgb;
	vec3 cSampleZerXPosY = texture2D(sampler, vUV + (vec2( 0.0,  1.0)) * vInvTextureSize.xy).rgb;
	vec3 cSamplePosXPosY = texture2D(sampler, vUV + (vec2( 1.0,  1.0)) * vInvTextureSize.xy).rgb;

	// convert to linear	
	vec3 cLSampleNegXNegY = cSampleNegXNegY * cSampleNegXNegY;
	vec3 cLSampleZerXNegY = cSampleZerXNegY * cSampleZerXNegY;
	vec3 cLSamplePosXNegY = cSamplePosXNegY * cSamplePosXNegY;

	vec3 cLSampleNegXZerY = cSampleNegXZerY * cSampleNegXZerY;
	vec3 cLSampleZerXZerY = cSampleZerXZerY * cSampleZerXZerY;
	vec3 cLSamplePosXZerY = cSamplePosXZerY * cSamplePosXZerY;

	vec3 cLSampleNegXPosY = cSampleNegXPosY * cSampleNegXPosY;
	vec3 cLSampleZerXPosY = cSampleZerXPosY * cSampleZerXPosY;
	vec3 cLSamplePosXPosY = cSamplePosXPosY * cSamplePosXPosY;

	// Average samples to get albdeo colour
	result.vAlbedo = ( cLSampleNegXNegY + cLSampleZerXNegY + cLSamplePosXNegY 
		    	     + cLSampleNegXZerY + cLSampleZerXZerY + cLSamplePosXZerY
		    	     + cLSampleNegXPosY + cLSampleZerXPosY + cLSamplePosXPosY ) / 9.0;	
	
	vec3 vScale = vec3(0.3333);
	float fSampleNegXNegY = dot(cSampleNegXNegY, vScale);
	float fSampleZerXNegY = dot(cSampleZerXNegY, vScale);
	float fSamplePosXNegY = dot(cSamplePosXNegY, vScale);
	
	float fSampleNegXZerY = dot(cSampleNegXZerY, vScale);
	float fSampleZerXZerY = dot(cSampleZerXZerY, vScale);
	float fSamplePosXZerY = dot(cSamplePosXZerY, vScale);
		
	float fSampleNegXPosY = dot(cSampleNegXPosY, vScale);
	float fSampleZerXPosY = dot(cSampleZerXPosY, vScale);
	float fSamplePosXPosY = dot(cSamplePosXPosY, vScale);	

	
	// Sobel operator - http://en.wikipedia.org/wiki/Sobel_operator
	
	vec2 vEdge;
	vEdge.x = (fSampleNegXNegY - fSamplePosXNegY) * 0.25 
			+ (fSampleNegXZerY - fSamplePosXZerY) * 0.5
			+ (fSampleNegXPosY - fSamplePosXPosY) * 0.25;

	vEdge.y = (fSampleNegXNegY - fSampleNegXPosY) * 0.25 
			+ (fSampleZerXNegY - fSampleZerXPosY) * 0.5
			+ (fSamplePosXNegY - fSamplePosXPosY) * 0.25;

	result.vNormal = normalize(vec3(vEdge * fNormalScale, 1.0));	
	
	return result;
}

void main()
{	
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	
	C_Sample materialSample;
		
	float fNormalScale = 10.0;
	materialSample = SampleMaterial( uv, adsk_results_pass4, resolution.xy, fNormalScale );
    vec3 alpha = texture2D(adsk_results_pass4, uv).rgb;
	
	
	float fLightHeight = 0.2;
	float fViewHeight = 2.0;
	
	vec3 vSurfacePos = vec3(uv, 0.0);
	vec3 vViewPos = vec3(0.5, 0.5, fViewHeight);
	vec3 vLightPos = vec3(LightBulb.xy, LightBulb.z - 0.01);
	
	vec3 vDirToView = normalize( vViewPos - vSurfacePos );
	vec3 vDirToLight = normalize( vLightPos - vSurfacePos );
		
	float fNDotL = clamp( dot(materialSample.vNormal, vDirToLight), 0.0, 1.0);
	float fDiffuse = fNDotL;
	
	vec3 vHalf = normalize( vDirToView + vDirToLight );
	float fNDotH = clamp( dot(materialSample.vNormal, vHalf), 0.0, 1.0);
	float fSpec = pow(fNDotH, 10.0) * fNDotL * 0.5;
	
	vec3 vResult = materialSample.vAlbedo * fDiffuse + fSpec;
	
	vResult = sqrt(vResult);

	gl_FragColor = vec4(vResult, alpha);
}