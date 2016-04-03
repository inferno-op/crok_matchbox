#version 120
// load Front
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D front;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 f = texture2D(front, uv).rgb;
	gl_FragColor = vec4(f, 1.0);
}
