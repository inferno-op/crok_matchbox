#version 120

uniform sampler2D back, adsk_results_pass4;
uniform bool exclude_bg;


void main()
{
	vec4 col = vec4(0.0);
	col.rgb = texture2D(adsk_results_pass4, gl_TexCoord[0].xy).rgb;
	col.a = texture2D(adsk_results_pass4, gl_TexCoord[0].xy).a;
	vec3 bg = texture2D(back, gl_TexCoord[0].xy).rgb;

	if ( exclude_bg )
	{
		// Comp premultiplied blur pass over back
		col.rgb = col.rgb + ((1.0 - col.a) * bg);
	}

	gl_FragColor = col;
}
