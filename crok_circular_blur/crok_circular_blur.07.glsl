#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass6;
uniform int result;
uniform bool keep_inside;

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 blurred = texture2D(adsk_results_pass6, uv);

	vec4 matte = vec4(blurred.a);

	blurred.rgb /= vec3(matte.aaa);

	if (keep_inside) 
	{
		matte = texture2D(adsk_results_pass3, uv);
	}

	blurred = clamp(blurred, 0.0, 1.0);

	vec4 result_image = vec4(0.0);

	if (result == 0) {
		vec4 front = texture2D(adsk_results_pass1, uv);
		result_image = mix(front, blurred, matte);
	} else if (result == 1) {
		vec4 back = texture2D(adsk_results_pass2, uv);
		result_image = mix(back, blurred, matte);
	} else if (result == 2) {
		result_image = blurred * matte;
	}

	gl_FragColor = vec4(result_image.rgb, blurred.a);
}
