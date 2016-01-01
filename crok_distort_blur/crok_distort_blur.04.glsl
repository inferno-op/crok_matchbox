// Pass 2: do the displace
// lewis@lewissaunders.com

uniform sampler2D front, adsk_results_pass3, strength_map, matte;
uniform float adsk_result_w, adsk_result_h, blength;

int oversamples = 3;
float spacing = 0.0;

const float sidestep = 0.0;


void main() {
	vec2 xy = gl_FragCoord.xy;
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	
	float strength = texture2D(strength_map, uv).r;

	// Factor to convert pixels to [0,1] texture coords
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	// Get vectors from previous pass
	vec2 d = texture2D(adsk_results_pass3, xy * px).xy;

	vec4 acc = vec4(0.0);
	for(int j = 0; j < oversamples; j++) {
		for(int k = 0; k < oversamples; k++) {
			// Starting point for this sample
			xy = gl_FragCoord.xy + spacing * vec2(float(j) / (float(oversamples) + 1.0), float(k) / (float(oversamples) + 1.0));
			float dist = 0.0;
			// Walk along path by sampling vector image, moving, sampling, moving...
			for(float i = 0.0; i < 1.0; i++) {
				d = texture2D(adsk_results_pass3, xy * px).xy;
				if(length(d) == 0.0) {
					// No gradient at this point in the map, early out
					break;
				}
				xy += d * (blength * strength) + blength * strength * sidestep/1000.0 * vec2(-d.y, d.x) + (blength * strength /32.0);
				dist += length(d * (blength * strength));
			}
			// Sample front image where our walk ended up
			acc.rgb += texture2D(front, xy * px).rgb;

			// Sample matte image where our walk ended up
			acc.a += texture2D(matte, xy * px).r;	
		}
	}
	acc /= float(oversamples * oversamples);

	gl_FragColor = acc; 
}
