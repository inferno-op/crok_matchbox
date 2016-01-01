#version 120
// comp everything

uniform sampler2D adsk_results_pass5;
uniform float adsk_result_w, adsk_result_h;


void main() 
{
    vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 col = texture2D(adsk_results_pass5, uv).rgb;
	float matte = texture2D(adsk_results_pass5, uv).a;
	
	col = col * matte;
	
    gl_FragColor = vec4(col, matte );
 }
	