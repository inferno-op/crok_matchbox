#version 120

//combining stars + blurred stars

uniform sampler2D adsk_results_pass1, adsk_results_pass2;
uniform float adsk_result_w, adsk_result_h;
uniform float stars_gain, s_blend;

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 col = vec3(0.0);
	vec3 stars_col = texture2D(adsk_results_pass1, uv).rgb;
	vec3 stars_col_blurred = texture2D(adsk_results_pass2, uv).rgb;
	
	stars_col *= stars_gain; 
	col = mix(stars_col, stars_col +stars_col_blurred, s_blend);
	
	gl_FragColor = vec4(col, 1.0);
}