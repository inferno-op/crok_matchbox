#version 120
// premultiply
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass3;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = texture2D(adsk_results_pass1, uv).rgb;
	float matte = texture2D(adsk_results_pass3, uv).r;
	vec3 premult = front * matte;
	gl_FragColor = vec4(premult, matte);
}
