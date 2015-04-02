#version 120

vec2 center = vec2(.5);

uniform float adsk_time, adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

uniform float amount_r, amount_g, amount_b, overall, r_size, g_size, b_size;

uniform int stock;


float rand2(vec2 co) 
{
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 noise(vec2 uv) {
	vec2 c = res.x*vec2(1.,(res.y/res.x));
	vec3 col = vec3(0.0);

   	float r = rand2(vec2((2.+time) * floor(uv.x*c.x / r_size)/c.x / r_size, (2.+time) * floor(uv.y*c.y / r_size)/c.y / r_size));
   	float g = rand2(vec2((5.+time) * floor(uv.x*c.x / g_size)/c.x / g_size, (5.+time) * floor(uv.y*c.y / g_size)/c.y / g_size));
   	float b = rand2(vec2((9.+time) * floor(uv.x*c.x / b_size)/c.x / b_size, (9.+time) * floor(uv.y*c.y / b_size)/c.y / b_size));

	col = vec3(r,g,b);

	return col;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 grain = noise(uv);
	vec3 grau = vec3 (0.5);
	vec3 c = vec3(0.0);


// Kodak 5245
	if ( stock == 0) 	
	{
		float p_red = 4.16;
		float p_green = 5.31;
		float p_blue = 12.00;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}

// Kodak 5248
	if ( stock == 1) 	
	{
		float p_red = 2.91;
		float p_green = 4.09;
		float p_blue = 7.50;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}

// Kodak 5287
	if ( stock == 2) 	
	{
		float p_red = 1.98;
		float p_green = 2.05;
		float p_blue = 3.64;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}	

// Kodak 5293
	if ( stock == 3) 	
	{
		float p_red = 4.08;
		float p_green = 4.63;
		float p_blue = 5.78;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}	
	
// Kodak 5296
	if ( stock == 4) 	
	{
		float p_red = 3.41;
		float p_green = 4.48;
		float p_blue = 16.43;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}	

// Kodak 5298
	if ( stock == 5) 	
	{
		float p_red = 1.50;
		float p_green = 1.59;
		float p_blue = 1.96;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}	
	
// Kodak 5217
	if ( stock == 6) 	
	{
		float p_red = 3.61;
		float p_green = 4.05;
		float p_blue = 8.09;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}
		
// Kodak 5218
	if ( stock == 7) 	
	{
		float p_red = 2.73;
		float p_green = 2.51;
		float p_blue = 11.60;
		
		grain.r = mix(grau.r, grain.r, p_red * amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, p_green * amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, p_blue * amount_b * .05 * overall);
	}

// Kodak BW
	if ( stock == 8) 	
	{
		grain = mix(grau, grain, overall * .1);
		grain = vec3(grain.r);
	}


// Custom grain stock	
	if (stock == 9 ) 
	{
		grain.r = mix(grau.r, grain.r, amount_r * .05 * overall);
		grain.g = mix(grau.g, grain.g, amount_g * .05 * overall);
		grain.b = mix(grau.b, grain.b, amount_b * .05 * overall);
	}
	
// Alan Skin BW
	if ( stock == 10 ) 	
	{
		grain = mix(grau, grain, overall* 1.5);
		grain = vec3(grain.r);
	}
	
	gl_FragColor = vec4(grain, 1.0);
}
