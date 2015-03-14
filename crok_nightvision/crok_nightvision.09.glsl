#version 120

//loading front

uniform sampler2D adsk_results_pass6, adsk_results_pass8;
uniform float adsk_result_w, adsk_result_h;

vec3 screen( vec3 s, vec3 d )
{
	return s + d - s * d;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 col = texture2D(adsk_results_pass6, uv).rgb;
	vec3 col_glow = texture2D(adsk_results_pass8, uv).rgb;
	
	col = screen(col, col_glow);
	
	gl_FragColor = vec4(col, 1.0);
}