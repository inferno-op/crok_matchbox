#version 120
// back
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D back;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 source = texture2D(back, uv);
	gl_FragColor = source;
}
