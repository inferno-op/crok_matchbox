#version 120

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass5;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float sharpness, som_sharpness;
uniform bool sommer;

vec4 normal( vec4 s, vec4 d )
{
	return s;
}

void main()                                            
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy);
	vec3 col = vec3(0.0);
	vec3 skin_c = texture2D( adsk_results_pass1, uv ).rgb;
	vec3 som_c = texture2D( adsk_results_pass2, uv ).rgb;
	vec3 matte = texture2D( adsk_results_pass5, uv ).rgb;
	skin_c -= texture2D( adsk_results_pass1, uv.xy+0.0001).rgb*sharpness*15.;
	skin_c += texture2D( adsk_results_pass1, uv.xy-0.0001).rgb*sharpness*15.;
	
	col = skin_c;
	
	
	if ( sommer )
	{
		som_c -= texture2D( adsk_results_pass2, uv.xy+0.0001).rgb * som_sharpness*15.;
		som_c += texture2D( adsk_results_pass2, uv.xy-0.0001).rgb * som_sharpness*15.;

		col = vec3(matte * som_c + (1.0 - matte) * skin_c);
	}
	

	
	
	gl_FragColor = vec4(col, matte);
}