uniform sampler2D adsk_results_pass3, Front, Back, Matte;
uniform float adsk_result_w, adsk_result_h;
uniform float Gamma;
uniform bool ssao_matte_switch;

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
    vec3 org_color = texture2D(Front, gl_TexCoord[0].st).rgb;
    vec3 bg_color = texture2D(Back, gl_TexCoord[0].st).rgb;
    vec3 Matte_col = texture2D(Matte, gl_TexCoord[0].st).rgb;
	vec3 color = texture2D(adsk_results_pass3, uv).rgb;

	vec3 gamma_col = pow(color, vec3(1.0 / Gamma));
	vec3 ssao_col = org_color * gamma_col;

	vec3 fin_col = vec3((ssao_col + (1.0 - Matte_col) * bg_color));
	
	if ( ssao_matte_switch )
		fin_col = gamma_col + (1.0 - Matte_col) * 1.0;

	gl_FragColor = vec4(fin_col, Matte_col);
}
