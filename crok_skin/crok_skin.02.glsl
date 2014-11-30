#version 120

uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float sharpness;

void main()                                            
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy);
	vec4 col = texture2D( adsk_results_pass1, uv );
	col -= texture2D( adsk_results_pass1, uv.xy+0.0001)*sharpness*15.;
	col += texture2D( adsk_results_pass1, uv.xy-0.0001)*sharpness*15.;
	gl_FragColor = col;
}