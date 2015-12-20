#version 120

uniform sampler2D adsk_results_pass6;


uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

float Exposure = 0.55;
float amount = 1.0;

float brightness = 1.05;
float contrast = 1.0;
float saturation = 0.4;

float Red = 10.0;
float Green = 1.0;
float Blue = -10.0;

vec3 tint = vec3(0.4,0.7,0.78);


vec3 RGB_lum = vec3(Red, Green, Blue);
const vec3 lumcoeff = vec3(0.2126,0.7152,0.0722);

void main (void) 
{ 		
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 avg_lum = vec3(0.5, 0.5, 0.5);
	vec4 tc = texture2D(adsk_results_pass6, uv);
	
	vec4 tc_new = tc * (exp2(tc)*vec4(Exposure));
	vec4 RGB_lum = vec4(lumcoeff * RGB_lum, 0.0 );
	float lum = dot(tc_new,RGB_lum);
	vec4 luma = vec4(lum);
	//vec4 col = mix(tc, luma, amount);
	vec3 col = luma.rgb * tint;


	vec3 intensity = vec3(dot(col.rgb, lumcoeff));
	vec3 sat_color = mix(intensity, col.rgb, saturation);
	vec3 con_color = mix(avg_lum, sat_color, contrast);
	vec3 fin_col = con_color - 1.0 + brightness;
	col = mix(tc.rgb, fin_col, amount);
	
	gl_FragColor.rgb = col;
} 
