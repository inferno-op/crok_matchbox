uniform sampler2D iChannel0;
uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float pScanline;
uniform float pSlowscan;
uniform float pColorshift_x;
uniform float pColorshift_y;
uniform float pVignettessoftness;
uniform float pVignettescale;
uniform bool pAddGrain;
uniform float pGrainsize;
uniform float pFrequency;
uniform float pDistort;
uniform float timer;
uniform float speed;
uniform float Distort;
uniform float Scale;
uniform float stripes_count;
uniform float Opacity;
uniform float bars_count;
uniform float opacity_moire;
uniform float moire_scale;
uniform bool vhs_bars;
uniform bool vhs_stripes;
uniform bool moire;
uniform bool add_vignette;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time*.05;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p)
{
	float sample = texture2D(iChannel0,vec2(1.,2.*cos(iGlobalTime))*iGlobalTime*8. + p*1.).x;
	sample *= sample;
	return sample;
}

float rand(float c){
	return rand(vec2(c,1.0));
}		


float ramp(float y, float start, float end)
{
	float inside = step(start,y) - step(end,y);
	float fact = (y-start)/(end-start)*inside;
	return (1.-fact) * inside;
	
}

// Attempting to make a CRT type effect. Thanks to Jasper for the crt UV distort function https://www.shadertoy.com/view/4sf3Dr
// created by by Klowner in 1/6/2013



float scanline(vec2 uv) {
	return sin(iResolution.y * uv.y * pScanline - iGlobalTime * 10.0);

}

float slowscan(vec2 uv) {
	return sin(iResolution.y * uv.y * pSlowscan + iGlobalTime * 6.0);

}

// from https://www.shadertoy.com/view/4sf3Dr
// Thanks, Jasper
vec2 crt(vec2 coord, float bend)
{
	// put in symmetrical coords
	coord = (coord - 0.5) * 2. / Scale;

	coord *= 0.5;	
	
	// deform coords
	coord.x *= 1.0 + pow((abs(coord.y) / bend * Distort), 2.0);
	coord.y *= 1.0 + pow((abs(coord.x) / bend * Distort), 2.0);

	// transform back to 0.0 - 1.0 space
	coord  = (coord / 1.0) + 0.5;

	return coord;
}

vec2 colorshift(vec2 uv, float amount, float rand) {
	
	return vec2(uv.x + amount * rand * pColorshift_x, uv.y + amount * rand * pColorshift_y);
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
	return clamp(pow(cos(uv.x * 3.1415), pVignettescale) * pow(cos(uv.y * 3.1415), pVignettescale) * pVignettessoftness, 0.0, 1.0);

}

float stripes(vec2 uv)
{
	float noi = rand(uv*vec2(0.5,1.) + vec2(1.,3.)) * Opacity;
	return ramp(mod(uv.y* stripes_count + iGlobalTime/2.+sin(iGlobalTime + sin(iGlobalTime* 2.)),1.),0.5,0.6)*noi;
}


// horizontal shifting
float onOff(float a, float b, float c)
{
	return step(c, sin(iGlobalTime + a*cos(iGlobalTime*b)));
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 sd_uv = scandistort(uv);
	vec2 crt_uv = crt(sd_uv, 2.0);
	
	vec4 color;

	color.r = texture2D(iChannel0, crt(colorshift(sd_uv, 0.025, 1.0), 2.0)).r;
	color.g = texture2D(iChannel0, crt(colorshift(sd_uv, 0.01, 1.0), 2.0)).g;
	color.b = texture2D(iChannel0, crt(colorshift(sd_uv, 0.024, 1.0), 2.0)).b;	
		
	vec4 scanline_color = vec4(scanline(crt_uv));
	vec4 slowscan_color = vec4(slowscan(crt_uv));

	if ( vhs_stripes )
		color *= (1.0 + stripes(uv));
	
	if ( vhs_bars)
		color *= (12.+mod(uv.y * bars_count + iGlobalTime,1.))/13.;

	if ( moire )
		color *= (1.0+(rand(uv * .01 * moire_scale)) * opacity_moire);

    if ( pAddGrain )
        color *= (1.0+(rand(uv * iGlobalTime)-.2)*.15*pGrainsize);
	
	if ( add_vignette )
		color *= vignette(uv);
	
	gl_FragColor = mix(color, mix(scanline_color, slowscan_color, 0.5), 0.05);

	
//    if ( pAddGrain )
 //           gl_FragColor.xyz *= (1.0+(rand(uv * iGlobalTime)-.2)*.15*pGrainsize);

}