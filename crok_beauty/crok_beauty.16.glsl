#version 120
// Blur only similar pixels
// Pass 1: horizontal blur
// lewis@lewissaunders.com

// original skin
uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;



float d_sigma = 2.0;
float d_threshold = 100.0;

const float pi = 3.141592653589793238462643383279502884197969;

void main() {
	vec2 xy = gl_FragCoord.xy;
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	float strength_here = 1.0;
	float sigma_here = d_sigma * strength_here;

	int support = int(sigma_here * 3.0);

	float kernelhyp = length(vec2(support, support));
	float rgbhyp = length(vec3(1.0, 1.0, 1.0));

	// Okay.  On to complicated two-pass algorithm
	// Incremental coefficient calculation setup as per GPU Gems 3
	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * pi) * sigma_here);
	g.y = exp(-0.5 / (sigma_here * sigma_here));
	g.z = g.y * g.y;

	if(sigma_here == 0.0) {
		g.x = 1.0;
	}

	vec4 a, b, c;
	a = vec4(0.0);
	float fac, energy = 0.0;

	// Centre sample
	vec4 orig = texture2D(adsk_results_pass1, xy * px);
	a += g.x * orig;
	energy += g.x;
	g.xy *= g.yz;

	int inc = int(pow(2.0, 3.0 - float(3.0)));

	// The rest
	for(int i = 1; i <= support; i += inc) {
		b = texture2D(adsk_results_pass1, (xy - vec2(float(i), 0.0)) * px);
		c = texture2D(adsk_results_pass1, (xy + vec2(float(i), 0.0)) * px);

		b.a = 1.0;
		c.a = 1.0;

		fac = 1.0 - (length(b - orig) / rgbhyp);
		fac = pow(fac, d_threshold);
		b *= g.x * clamp(fac, 0.001, 1.0);
		a += b;
		energy += b.a;

		fac = 1.0 - (length(c - orig) / rgbhyp);
		fac = pow(fac, d_threshold);
		c *= g.x * clamp(fac, 0.001, 1.0);
		a += c;
		energy += c.a;

		g.xy *= g.yz;
	}
	a /= energy;

	gl_FragColor = a;
}

