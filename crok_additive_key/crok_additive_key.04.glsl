#version 120
// negate matte and multiply with despilled FG
uniform sampler2D adsk_results_pass1, adsk_results_pass3;
uniform float adsk_result_w, adsk_result_h;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);

vec3 negative(vec3 matte )
{
	return 1.0 - matte;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec3 f = texture2D(adsk_results_pass1, uv).rgb;
	vec3 m = texture2D(adsk_results_pass3, uv).rgb;
	// I assume the reference is the clean FG

	// invert matte
	m = negative ( m ); 
	// multiply fg and negative matte
	f = f * m;

	gl_FragColor = vec4(f, m);
}


