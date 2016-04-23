#version 120
// adding grain to the edge blur
uniform float adsk_result_w, adsk_result_h, adsk_time, grain_size, high, b_cc;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass4, adsk_results_pass8, adsk_results_pass10, adsk_results_pass6, matte, adsk_results_pass13, adsk_results_pass16, gmask;
uniform bool gmaskInput;
uniform bool auto_cc;

vec3 spotlight( vec3 s, vec3 d )
{
	vec3 c = 2.0 * d * s;
	return c;
}

float softLight( float s, float d )
{
	return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d) 
		: (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0) 
					 : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}

vec3 softLight( vec3 s, vec3 d )
{
	vec3 c;
	c.x = softLight(s.x,d.x);
	c.y = softLight(s.y,d.y);
	c.z = softLight(s.z,d.z);
	return c;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec2 n_uv = (uv-0.5) / grain_size;
	
	// Gmask Input
	float sel = texture2D(gmask, uv).r;
	sel = gmaskInput ? sel : 1.0;
	
	vec3 blured_bg = texture2D(adsk_results_pass4, uv).rgb;
	vec3 normal_comp = texture2D(adsk_results_pass8, uv).rgb;
	vec3 blured_comp = texture2D(adsk_results_pass10, uv).rgb;
	vec3 back = texture2D(adsk_results_pass6, uv).rgb;
    vec3 edge_matte = texture2D(adsk_results_pass13, uv).rgb;
	vec3 grain = texture2D(adsk_results_pass16, n_uv).rgb;
	vec3 mask = texture2D(matte, uv).rgb;
	
	float matte_out = 1.0;
	
    //levels input range
    vec3 g_matte = min(max(normal_comp - vec3(0.0), vec3(0.0)) / (vec3(1.0 - high) - vec3(0.0)), vec3(1.0));
	vec3 inv_matte = 1.0 - g_matte;

   	vec3 comp = mix(normal_comp, blured_comp, edge_matte * sel);
	vec3 grain_c = spotlight(grain, comp);
	grain_c = vec3(inv_matte * grain_c + (g_matte) * comp);

	// auto cc
	if ( auto_cc )
	{
			comp = softLight(blured_bg, comp);
			comp = mix(normal_comp, comp, mask * b_cc * 0.3 * sel);
	}

	comp = mix(comp, grain_c, edge_matte  * sel);
	

	
	gl_FragColor = vec4(comp, 1.0);
}