uniform sampler2D Source;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float radius, softness, blend;
uniform vec3 v_color;

void main( void ) 
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 center = 2.0 * ((gl_FragCoord.xy / resolution.xy) - 0.5);
	vec3 original = texture2D(Source, uv).rgb;
	vec3 col = v_color * original;
	
    float length = length(center);
    float vig = smoothstep(radius, radius-softness, length);
	
	vec3 matte = vec3(1.0-vig);
	vec3 fin_col = matte * col + (1.0 - matte) * original;
	fin_col = mix(original, fin_col, blend);
	
	gl_FragColor = vec4(fin_col, vig);
}
