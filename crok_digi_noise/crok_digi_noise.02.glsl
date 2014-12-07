uniform sampler2D adsk_results_pass1;
uniform float adsk_time, scale;
float time = adsk_time;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
vec2 center = vec2(0.34, .63);


float hash2(vec2 uv) 
{
	return fract(sin(uv.x * 15.78 + uv.y * 35.14) * 43758.23);
}

void main( void ) {

	vec2 uv = 1. / scale *hash2(center*time) * (gl_FragCoord.xy / resolution.xy) + hash2(center + time);
	vec4 col = texture2D(adsk_results_pass1, uv);
	
	gl_FragColor = col;
}
