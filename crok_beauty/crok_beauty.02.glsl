#version 120
// load Matte
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D matte;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	float m = texture2D(matte, uv).r;
	gl_FragColor = vec4(m);
}