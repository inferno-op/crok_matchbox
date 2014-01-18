uniform sampler2D iChannel0;

//uniform sampler2D iChannel1;

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float pScanline;
uniform float pSlowscan;
uniform float pColorshift;
uniform float pVignettessoftness;
uniform float pVignettescale;
uniform bool pAddGrain;
uniform float pGrainsize;
uniform float pFrequency;
uniform float pDistort;
uniform float timer;
uniform float speed;

// Attempting to make a CRT type effect. Thanks to Jasper for the crt UV distort function https://www.shadertoy.com/view/4sf3Dr
// created by Klowner in 1/6/2013


// Set frequency of global effect to 20 variations per second
float t = float(int(adsk_time * pFrequency));

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand(float c){
	return rand(vec2(c,1.0));
}		

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time*.05;

// Attempting to make a CRT type effect. Thanks to Jasper for the crt UV distort function https://www.shadertoy.com/view/4sf3Dr
// created by by Klowner in 1/6/2013


float scanline(vec2 uv) {
//	return sin(iResolution.y * uv.y * 0.7 - iGlobalTime * 10.0);
	return sin(iResolution.y * uv.y * pScanline - iGlobalTime * 10.0);

}

float slowscan(vec2 uv) {
//	return sin(iResolution.y * uv.y * 0.02 + iGlobalTime * 6.0);
	return sin(iResolution.y * uv.y * pSlowscan + iGlobalTime * 6.0);

}

vec2 colorShift(vec2 uv) {
	return vec2(
		uv.x,
//		uv.y + sin(iGlobalTime)*0.02
		uv.y + sin(iGlobalTime)* pColorshift);
}

//float noise(vec2 uv) {
//	return clamp(texture2D(iChannel1, uv.xy + iGlobalTime*6.0).r +
//		texture2D(iChannel1, uv.xy - iGlobalTime*4.0).g, 0.96, 1.0);
//	return clamp(texture2D(iChannel1, uv.xy + iGlobalTime*6.0).r +
//		texture2D(iChannel1, uv.xy - iGlobalTime*4.0).g, 0.96, 1.0);
//}

// from https://www.shadertoy.com/view/4sf3Dr
// Thanks, Jasper
vec2 crt(vec2 coord, float bend)
{
	// put in symmetrical coords
	coord = (coord - 0.5) * 1.87;

	coord *= 0.5;	
	
	// deform coords
	coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
	coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);

	// transform back to 0.0 - 1.0 space
	coord  = (coord / 1.0) + 0.5;

	return coord;
}

vec2 colorshift(vec2 uv, float amount, float rand) {
	
	return vec2(
		uv.x,
		uv.y + amount * rand * pColorshift);
}

vec2 scandistort(vec2 uv) {
	float scan1 = clamp(cos(uv.y * speed + iGlobalTime*timer), 0.0, 1.0);
	float scan2 = clamp(cos(uv.y * speed + iGlobalTime*timer + 4.0) * 10.0, 0.0, 1.0) ;
	float amount = scan1 * scan2 * uv.x; 

//Distortion 
	uv.x -= pDistort * mix(texture2D(iChannel0, vec2(uv.x, amount)).r * amount, amount, 0.9);

	return uv;
	 
}
        
float vignette(vec2 uv) {
	uv = (uv - 0.5) * 0.98;
//	return clamp(pow(cos(uv.x * 3.1415), 1.2) * pow(cos(uv.y * 3.1415), 1.2) * 50.0, 0.0, 1.0);
	return clamp(pow(cos(uv.x * 3.1415), pVignettescale) * pow(cos(uv.y * 3.1415), pVignettescale) * pVignettessoftness, 0.0, 1.0);

}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 sd_uv = scandistort(uv);
	vec2 crt_uv = crt(sd_uv, 2.0);
	
	vec4 color;
		
	//float rand_r = sin(iGlobalTime * 3.0 + sin(iGlobalTime)) * sin(iGlobalTime * 0.2);
	//float rand_g = clamp(sin(iGlobalTime * 1.52 * uv.y + sin(iGlobalTime)) * sin(iGlobalTime* 1.2), 0.0, 1.0);
	//vec4 rand = texture2D(iChannel1, vec2(iGlobalTime * 0.01, iGlobalTime * 0.02));

	color.r = texture2D(iChannel0, crt(colorshift(sd_uv, 0.025, 1.0), 2.0)).r;
	color.g = texture2D(iChannel0, crt(colorshift(sd_uv, 0.01, 1.0), 2.0)).g;
	color.b = texture2D(iChannel0, crt(colorshift(sd_uv, 0.024, 1.0), 2.0)).b;	
		
	vec4 scanline_color = vec4(scanline(crt_uv));
	vec4 slowscan_color = vec4(slowscan(crt_uv));
	
	gl_FragColor = mix(color, mix(scanline_color, slowscan_color, 0.5), 0.05) *
		vignette(uv) ;
	
	// Add some grain (thanks, Jose!)
    if ( pAddGrain )
            gl_FragColor.xyz *= (1.0+(rand(uv+t*.01)-.2)*.15*pGrainsize);
}