uniform sampler2D source;
uniform float Amount, Exposure;
uniform float dark_low, dark_high, light_low, light_high;
uniform float adsk_result_w, adsk_result_h;
uniform float brightness, contrast, saturation;
uniform vec3 light_tint, dark_tint;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
const vec3 lumc = vec3(0.2125, 0.7154, 0.0721);


void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	
	vec3 original = texture2D(source, uv).rgb;
	vec3 col = original;

	float bri = (col.x+col.y+col.z)/3.0;
	float v = smoothstep(dark_low, dark_high, bri);
	col = mix(dark_tint * bri, col, v);
	
	v = smoothstep(light_low, light_high, bri);
	col = mix(col, min(light_tint * col, 1.0), v);
	col = mix(original, col, Amount);
	
	vec3 avg_lum = vec3(0.5, 0.5, 0.5);
	vec3 intensity = vec3(dot(col.rgb, lumc));
	vec3 sat_color = mix(intensity, col.rgb, saturation);
	vec3 con_color = mix(avg_lum, sat_color, contrast);
	vec3 fin_col = con_color - 1.0 + brightness;
	
	
	gl_FragColor = vec4(fin_col, 1.0) * Exposure;
}