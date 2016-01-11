#version 120
// processing despilled front input

uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec3 col = texture2D(front, uv).rgb;
	gl_FragColor = vec4(col, 0.0);
}
