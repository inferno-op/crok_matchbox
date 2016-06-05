#version 120

uniform sampler2D front, back, matte;
uniform float adsk_result_w, adsk_result_h;
uniform bool exclude_bg;


void main()
{
	vec4 col = vec4(0.0);
	vec2 uv = gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);
	col.rgb = texture2D(front, gl_TexCoord[0].xy).rgb;
	col.a = texture2D(matte, gl_TexCoord[0].xy).r;
	vec3 bg = texture2D(back, gl_TexCoord[0].xy).rgb;

	if ( exclude_bg )
	{
		// Uncomposite the FG from the BG, output just FG on black
		col.rgb = col.rgb - ((1.0 - col.a) * bg.rgb);
	}


	gl_FragColor = col;
}
