#version 120
// chromatic abberation

uniform sampler2D adsk_results_pass2;
uniform float adsk_result_w, adsk_result_h;
uniform float chromatic_abb;
uniform vec2 center;

int num_iter = 3;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

vec2 barrelDistortion(vec2 coord, float amt) {
	
	vec2 cc = (((gl_FragCoord.xy/iResolution.xy) - center ));
	float distortion = dot(cc * .3, cc);
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

vec3 spectrum_offset( float t ) {
	vec3 ret;
	float lo = step(t,0.5);
	float hi = 1.0-lo;
	float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
	ret = vec3(lo,1.0,hi) * vec3(1.0-w, w, 1.0-w);

	return pow( ret, vec3(1.0/2.2) );
}

void main()
{	
	vec2 uv=(gl_FragCoord.xy/iResolution.xy);
	vec3 sumcol = vec3(0.0);
	vec3 sumw = vec3(0.0);
	vec3 matte = vec3(0.0);	
		
	for ( int i=0; i< num_iter;++i )
	{
		float t = float(i) * (1.0 / float(num_iter));
		vec3 w = spectrum_offset( t );
		sumw += w;
		sumcol += w * texture2D( adsk_results_pass2, barrelDistortion(uv, chromatic_abb * t ) ).rgb;

		matte.r = sumcol.r  / sumw.r;
		matte.g = sumcol.r  / sumw.g;
		matte.b = sumcol.r / sumw.b;
	
		matte.r += sumcol.g  / sumw.r;
		matte.g += sumcol.g  / sumw.g;
		matte.b += sumcol.g / sumw.b;

		matte.r += sumcol.b  / sumw.r;
		matte.g += sumcol.b / sumw.g;
		matte.b += sumcol.b / sumw.b;
	}
		
	gl_FragColor = vec4(sumcol.rgb / sumw,  matte );
}
