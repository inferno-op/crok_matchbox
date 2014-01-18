uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float pZoom;
uniform float pAmplitude;
uniform float pNoise;
uniform float pOffset;
uniform float gGlobalspeed;

float iGlobalTime = adsk_time* 0.01 * gGlobalspeed;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

// by @301z

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 n) {
	const vec2 d = vec2(0.0, 1.0);
	vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
	float total = 0.0, amplitude = 1.0 * pAmplitude;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n += n;
		amplitude *= 0.5 * pNoise;
	}
	return total;
}

void main() {
	const vec3 c1 = vec3(0.1, 0.0, 0.0);
	const vec3 c2 = vec3(0.7, 0.0, 0.0);
	const vec3 c3 = vec3(0.2, 0.0, 0.0);
	const vec3 c4 = vec3(1.0, 0.9, 0.0);
	const vec3 c5 = vec3(0.1);
	const vec3 c6 = vec3(0.9);
	vec2 p = gl_FragCoord.xy * pZoom / iResolution.xx;
	float q = fbm(p - iGlobalTime);
	vec2 r = vec2(fbm(p + q + pOffset - p.x - p.y), fbm(p + q - pOffset * 0.6 ));
	vec3 c = mix(c1, c2, fbm(p + r)) + mix(c3, c4, r.x) - mix(c5, c6, r.y);
	gl_FragColor = vec4(c * cos(1.0 * gl_FragCoord.y / iResolution.y), 1.0);
}
