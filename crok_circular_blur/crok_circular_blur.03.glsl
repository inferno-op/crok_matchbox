#version 120
// matte
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D matte;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 mat = texture2D(matte, uv);
	gl_FragColor = vec4(mat.rgb, mat.r);
}
