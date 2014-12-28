// Pass 1: make the  low frequency vectors
// lewis@lewissaunders.com

uniform sampler2D map, adsk_results_pass3;
uniform float adsk_result_w, adsk_result_h;
uniform bool external_matte;

const float ksize = 1.0;

void main() {
	vec2 xy = gl_FragCoord.xy;

	// Factor to convert pixels to [0,1] texture coords
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);
	vec2 d = vec2(0.0);

	if ( external_matte )
	{
		// Convolve by x and y Sobel matrices to get gradient vector
		d.x  =  1.0 * texture2D(map, (xy + ksize * vec2(-1.0, -1.0)) * px).g;
		d.x +=  2.0 * texture2D(map, (xy + ksize * vec2(-1.0,  0.0)) * px).g;
		d.x +=  1.0 * texture2D(map, (xy + ksize * vec2(-1.0, +1.0)) * px).g;
		d.x += -1.0 * texture2D(map, (xy + ksize * vec2(+1.0, -1.0)) * px).g;
		d.x += -2.0 * texture2D(map, (xy + ksize * vec2(+1.0,  0.0)) * px).g;
		d.x += -1.0 * texture2D(map, (xy + ksize * vec2(+1.0, +1.0)) * px).g;
		d.y +=  1.0 * texture2D(map, (xy + ksize * vec2(-1.0, -1.0)) * px).g;
		d.y +=  2.0 * texture2D(map, (xy + ksize * vec2( 0.0, -1.0)) * px).g;
		d.y +=  1.0 * texture2D(map, (xy + ksize * vec2(+1.0, -1.0)) * px).g;
		d.y += -1.0 * texture2D(map, (xy + ksize * vec2(-1.0, +1.0)) * px).g;
		d.y += -2.0 * texture2D(map, (xy + ksize * vec2( 0.0, +1.0)) * px).g;
		d.y += -1.0 * texture2D(map, (xy + ksize * vec2(+1.0, +1.0)) * px).g;
	}	
	else
	{
		d.x  =  1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(-1.0, -1.0)) * px).g;
		d.x +=  2.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(-1.0,  0.0)) * px).g;
		d.x +=  1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(-1.0, +1.0)) * px).g;
		d.x += -1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(+1.0, -1.0)) * px).g;
		d.x += -2.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(+1.0,  0.0)) * px).g;
		d.x += -1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(+1.0, +1.0)) * px).g;
		d.y +=  1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(-1.0, -1.0)) * px).g;
		d.y +=  2.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2( 0.0, -1.0)) * px).g;
		d.y +=  1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(+1.0, -1.0)) * px).g;
		d.y += -1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(-1.0, +1.0)) * px).g;
		d.y += -2.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2( 0.0, +1.0)) * px).g;
		d.y += -1.0 * texture2D(adsk_results_pass3, (xy + ksize * vec2(+1.0, +1.0)) * px).g;
		
	}
		// Convolve by x and y Sobel matrices to get gradient vector
	
	// Bit of a bodge factor right here
	d *= 32.0 / ksize;

	// Output vectors for second pass
	gl_FragColor = vec4(d.x, d.y, 0.0, 1.0);
}
