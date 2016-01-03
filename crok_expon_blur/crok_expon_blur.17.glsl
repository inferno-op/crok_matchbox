#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front, adsk_results_pass2, adsk_results_pass4, adsk_results_pass6, adsk_results_pass8, adsk_results_pass10, adsk_results_pass12, adsk_results_pass14, adsk_results_pass16;
uniform bool clamp_output, ena_multiply;
uniform float gamma, blend;
uniform float blur_amount;
uniform vec2 blur_xy_amount;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec4 org = texture2D(Front, uv);
	vec4 col = texture2D(adsk_results_pass2, uv);

	if ( blur_amount < 0.0 || blur_xy_amount.x < 0.0 || blur_xy_amount.y < 0.0  ) 
	{
		col *= texture2D(adsk_results_pass4, uv);
		col *= texture2D(adsk_results_pass6, uv);
		col *= texture2D(adsk_results_pass8, uv);
		col *= texture2D(adsk_results_pass10, uv);
		col *= texture2D(adsk_results_pass12, uv);
		col *= texture2D(adsk_results_pass14, uv);
		col *= texture2D(adsk_results_pass16, uv);
	}

	else
	{
		col += texture2D(adsk_results_pass4, uv);
		col += texture2D(adsk_results_pass6, uv);
		col += texture2D(adsk_results_pass8, uv);
		col += texture2D(adsk_results_pass10, uv);
		col += texture2D(adsk_results_pass12, uv);
		col += texture2D(adsk_results_pass14, uv);
		col += texture2D(adsk_results_pass16, uv);
	}


	if ( clamp_output )
	{
		col = clamp(col, 0.0, 1.0);
		//col = normalize(col);
	}
	
	//gamma correction
	col = pow(col, vec4(gamma));
	
	// blend between original image and blurred one
	col = mix(org, col, blend);
	
	
	gl_FragColor = col;
}
	