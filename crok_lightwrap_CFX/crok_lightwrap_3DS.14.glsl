#version 120
// creating colour noise for grain
vec2 center = vec2(.5);

uniform float adsk_time, adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

uniform float amount_r, amount_g, amount_b, overall;

float rand2(vec2 co) 
{
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 noise(vec2 uv) 
{
	vec2 c = res.x*vec2(1.,(res.y/res.x));
	vec3 col = vec3(0.0);

   	float r = rand2(vec2((2.+time) * floor(uv.x*c.x)/c.x, (2.+time) * floor(uv.y*c.y)/c.y));
   	float g = rand2(vec2((5.+time) * floor(uv.x*c.x)/c.x, (5.+time) * floor(uv.y*c.y)/c.y));
   	float b = rand2(vec2((9.+time) * floor(uv.x*c.x)/c.x, (9.+time) * floor(uv.y*c.y)/c.y));

	col = vec3(r,g,b);

	return col;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 grain = noise(uv);
	vec3 grau = vec3 (0.5);
	vec3 c = vec3(0.0);

	grain.r = mix(grau.r, grain.r, amount_r * .05 * overall);
	grain.g = mix(grau.g, grain.g, amount_g * .05 * overall);
	grain.b = mix(grau.b, grain.b, amount_b * .05 * overall);
	
	gl_FragColor = vec4(grain, 1.0);
}
