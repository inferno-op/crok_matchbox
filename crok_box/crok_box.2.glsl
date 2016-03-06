#version 120
// based on https://www.shadertoy.com/view/Xs33DN

uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float scale, center;
uniform vec2 offset;

void main(void)
{
	vec2 sq = vec2(0.);
	vec2 uv = vec2(0.0);
	uv = (((gl_FragCoord.xy / resolution.xy) - offset + 0.5));
	uv -= 0.5;
	uv /= scale;
	uv += 0.5;
	
	float mask = texture2D( adsk_results_pass1, uv).r;
	vec4 col = vec4(clamp(mask, 0.0, 1.0));
    gl_FragColor = col;
}


