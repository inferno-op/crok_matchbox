// Directional blur driven by gradient vectors of front input
// lewis@lewissaunders.com


uniform sampler2D adsk_results_pass3, adsk_results_pass4, strength_map;
uniform float adsk_result_w, adsk_result_h, blur_length;
uniform int samples;
uniform bool radial, normalize, pathy, adsk_degrade;

void main() {
	vec2 xy = gl_FragCoord.xy;
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	
	float strength = texture2D(strength_map, uv).r;

	// Factor to convert [0,1] texture coords to pixels
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	// Get vectors from previous pass
	vec2 d = texture2D(adsk_results_pass3, xy * px).xy;

	if(length(d) == 0.0) {
		// No gradient at this point in the map, early out
		gl_FragColor = texture2D(adsk_results_pass4, xy * px);
		return;
	}

	vec4 a = vec4(0.0);
	float sam = float(samples);
	float steps;
	bool odd = false;

	if(mod(sam, 2.0) == 1.0) {
		odd = true;
	}
	if(odd) {
		// Odd number of samples, start with a sample from the current position
		a = texture2D(adsk_results_pass4, xy * px);
		steps = (sam - 1.0) / 2.0;
	} else {
		// Even number of samples, start with nothing
		a = vec4(0.0);
		steps = (sam / 2.0) - 1.0;
	}

	// Now accumulate along the path forwards...
	if(!odd) {
		// Even number of samples, first step is half length
		xy += 0.5 * d * blur_length * strength / (sam - 1.0);
		a += texture2D(adsk_results_pass4, xy * px);
	}
	for(float i = 0.0; i < steps; i++) {
		d = texture2D(adsk_results_pass3, xy * px).xy;
		xy += d * blur_length * strength / (sam - 1.0);
		a += texture2D(adsk_results_pass4, xy * px);
	}
	
	// ...and backwards
	xy = gl_FragCoord.xy;
	d = texture2D(adsk_results_pass4, xy * px).xy;
	if(!odd) {
		// Even number of samples, first step is half length
		xy -= 0.5 * d * blur_length * strength / (sam - 1.0);
		a += texture2D(adsk_results_pass4, xy * px);
	}
	for(float i = 0.0; i < steps; i++) {
		xy -= d * blur_length * strength / (sam - 1.0);
		a += texture2D(adsk_results_pass4, xy * px);
		d = texture2D(adsk_results_pass3, xy * px).xy;
	}

	a /= sam;
	gl_FragColor = a;
}
