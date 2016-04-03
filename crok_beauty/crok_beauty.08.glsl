#version 120
// comp first step

// load Front
uniform sampler2D adsk_results_pass1;
// load Blurred ChromaKey Matte
uniform sampler2D adsk_results_pass5;
// load DollFace Result
uniform sampler2D adsk_results_pass7;
uniform float adsk_result_w, adsk_result_h;
uniform float r_spots_blend;
uniform float r_h_blend;

const vec3 lumc = vec3(0.2125, 0.7154, 0.0721);

vec3 lighten( vec3 s, vec3 d )
{
	return max(s,d);
}

vec3 difference( vec3 s, vec3 d )
{
	return abs(d - s);
}

vec3 darkerColor( vec3 s, vec3 d )
{
	return (s.x + s.y + s.z < d.x + d.y + d.z) ? s : d;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 c = vec3(0.0);
	vec3 diff = vec3(0.0);
	vec3 avg_lum = vec3(0.5, 0.5, 0.5);

	// Dollface
	vec3 s = texture2D(adsk_results_pass7, uv).rgb;
	// Original Front
	vec3 d = texture2D(adsk_results_pass1, uv).rgb;
	// Blurred ChromaKey Matte
  vec3 matte =  vec3( texture2D(adsk_results_pass5, uv).rgb);

	// Remove Dark Spots
	c += lighten(s,d);
    // mix processed source with original
	c = mix(d, c, r_spots_blend);
	// comp result with the chromakey matte over original
	c = vec3(matte * c + (1.0 - matte) * d);

	// difference betweeen Dollface and Original
	diff = difference(s,d);
	// convert to black and white
	diff = vec3(dot(diff, lumc));
	diff = mix(avg_lum, diff, 1.0);
	// clamp diff matte;
	diff = clamp(diff, 0.0, 1.0);
	// invert diff matte
    diff = (1.0 - diff) * matte;


	// Remove Highlights
	vec3 d_c = darkerColor(s,c);
    // mix processed clip with darkendclip
	d_c = mix(c, d_c, r_h_blend);
	// comp Remove Highlights with the difference matte
	d_c = vec3(diff * d_c + (1.0 - diff) * c);

	gl_FragColor = vec4(d_c, matte);
}
