uniform sampler2D Source;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float radius, softness, blend, aspect;
uniform vec3 v_color;
uniform bool organic;
uniform vec2 center;

void main( void ) 
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 center = (2.0 * ((gl_FragCoord.xy / resolution.xy) - 0.25) - center);
	center.x = center.x  / aspect;
	vec3 original = texture2D(Source, uv).rgb;
	vec3 tint_col = v_color * original;
	
    float length = length(center);
    float vig = smoothstep(radius, radius-softness, length);
	
	vec3 matte = vec3(1.0-vig);

	// simple blend mode 
	vec3 fin_col = mix(original, tint_col, blend);
	fin_col = matte * fin_col + (1.0 - matte) * original;
	
	if ( organic )
	{
		fin_col = tint_col * original;
		fin_col = matte * fin_col + (1.0 - matte) * original;
		fin_col = mix(original, fin_col, blend);
	}

	gl_FragColor = vec4(fin_col, vig);
}
