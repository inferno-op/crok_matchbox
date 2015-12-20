#version 120

//loading front

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass9, adsk_results_pass11;
uniform float adsk_result_w, adsk_result_h;
uniform bool NightVision, Old_TV;
vec3 screen( vec3 s, vec3 d )
{
	return s + d - s * d;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 pure_col = texture2D(adsk_results_pass1, uv).rgb;
	vec3 tv_col = texture2D(adsk_results_pass2, uv).rgb;
	
	vec3 col = texture2D(adsk_results_pass9, uv).rgb;
	vec3 col_glow = texture2D(adsk_results_pass11, uv).rgb;
	
	if ( NightVision )
		col = screen(col, col_glow);
	else if ( Old_TV )
		col = tv_col;
	else
		col = pure_col;
	
	gl_FragColor = vec4(col, 1.0);
}