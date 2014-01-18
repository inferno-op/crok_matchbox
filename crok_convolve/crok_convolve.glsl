uniform sampler2D iChannel0;
uniform float adsk_result_w, adsk_result_h;

uniform float pCv;
uniform float pST;

// Just a really quick, simple circular blur. Constants that you can change: CV is the radius of the blur, ST controls the quality (higher is faster but looks worse)
// created by Pitzik4 in 16/5/2013

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);


#define PI 3.141592
#define PI2 6.283184

// #define CV 0.1
// #define ST 0.05

vec4 colorat(vec2 uv) {
	return texture2D(iChannel0, vec2(uv.x, uv.y));
}
vec4 convolve(vec2 uv) {
	vec4 col = vec4(0.0);
	for(float r0 = 0.0; r0 < 1.0; r0 += pST) {
		float r = r0 * pCv;
		for(float a0 = 0.0; a0 < 1.0; a0 += pST) {
			float a = a0 * PI2;
			col += colorat(uv + vec2(cos(a), sin(a)) * r);
		}
	}
	col *= pST * pST;
	return col;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	gl_FragColor = convolve(uv);
}
