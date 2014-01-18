// http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
// original created by JoshP in 7/5/2013

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform int resolution;
uniform float offsetx;
uniform float offsety;
uniform float p3;
uniform float seed;
uniform float zoom;
uniform float gain;
uniform vec3 color;

float iGlobalTime = adsk_time;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

float field(in vec3 p) {
	float strength = 9. + .00003 * log(1.e-6 + fract(sin(iGlobalTime) * 4373.11));
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < resolution; ++i) {
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.4, -1.5);
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
		tw += w;
		prev = mag;
	}
	return max(0., 4.3 * accum / tw - 0.7);
}

void main() {
	vec2 uv = 2. * gl_FragCoord.xy / iResolution.xy - 1.;
	vec2 uvs = uv * iResolution.xy / max(iResolution.x, iResolution.y);
	vec3 p = vec3(uvs / zoom, 0) + vec3(1., -1.3, 0.);
	p += .2 * vec3(offsetx, offsety, iGlobalTime / seed);
	float t = field(p);
    gl_FragColor = mix(0.1, 1.0, gain) * vec4(color.r * t * t * t, color.g *t * t, color.b * t, 1.0);
}