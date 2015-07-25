#version 120
// front
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D front;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 source = texture2D(front, uv);
	gl_FragColor = source;
}
