uniform sampler2D adsk_results_pass3;
uniform float adsk_image_w, adsk_image_h;
uniform float adsk_result_w, adsk_result_h;
float chromatic_abb = 0.3;
int num_iter = 24;
uniform float d_amount, ca_amt, off_chroma;
vec2 center = vec2(0.5, 0.5);
uniform bool warp_m;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

vec2 barrelDistortion(vec2 coord, float amt) {
	
	vec2 cc = (((gl_FragCoord.xy/iResolution.xy) - center ));
	float distortion = dot(cc * d_amount * .3, cc);
	return coord + cc * amt * -.05;
}

float sat( float t )
{
	return clamp( t, 0.0, 1.0 );
}

float linterp( float t ) {
	return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

float remap( float t, float a, float b ) {
	return sat( (t - a) / (b - a) );
}

vec4 spectrum_offset( float t ) {
	vec3 tmp;
	vec4 ret;
	float lo = step(t,0.5);
	float hi = 1.0-lo;
	float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
	tmp = vec3(lo,1.0,hi) * vec3(1.0-w, w, 1.0-w);
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 lum = vec3(dot(tmp, W));
	ret = vec4(tmp, lum.r);
	return pow( ret, vec4(1.0/2.2) );
}

void main()
{	
	vec2 uv=(gl_FragCoord.xy/iResolution.xy);
	vec4 sumcol = vec4(0.0);
	vec3 sumalpha = vec3(0.0);
	vec4 sumw = vec4(0.0);
		
	for ( int i=0; i<num_iter;++i )
	{
		float t = float(i) * (1.0 / float(num_iter));
		vec4 w_off = spectrum_offset( t );
		vec4 w = mix(w_off, vec4(1.0), off_chroma);
		sumw += w;

		sumcol += w * texture2D( adsk_results_pass3, barrelDistortion(uv, chromatic_abb * t ) );
	}
	
	vec4 col = vec4(sumcol / sumw);

			
	gl_FragColor = col;
}
