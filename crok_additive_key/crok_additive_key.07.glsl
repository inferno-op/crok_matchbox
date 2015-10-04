#version 120
// processing holdout matte

uniform sampler2D holdout;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec3 col = texture2D(holdout, uv).rgb;
	gl_FragColor = vec4(col, 0.0);
}
