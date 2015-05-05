#version 120

// toDo:
// adding random positions
// adding Aspect ration slider
// adding different stars Presets

// based on http://glslsandbox.com/e#23725.0
//Galaxy Collision
//By nikoclass

uniform float adsk_result_w, adsk_result_h, adsk_time, adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

uniform int amount, itterations;
uniform float flash_speed, shape, stars_size, rotation, b_diff, aspect;
uniform int blend_function;

#define PI 3.14159265359


float rand(vec2 p) {
	return fract(sin(dot(p ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 pulsar(vec2 p, vec2 pos, float size, float angle) {
	
	float a = 0.30 * shape;
	
	//rotate stars
	p *= adsk_result_frameratio;
	float rad_rot = angle * PI / 180.0; 
	mat2 m = mat2(cos(rad_rot), -sin(rad_rot), sin(rad_rot), cos(rad_rot));
	//p.x *= aspect;
	p = m * p;
	pos = m * pos;
	p /= adsk_result_frameratio;
	
	
	float d = pow(abs(p.x - pos.x), a) + pow(abs(p.y - pos.y), a);
	
	if (d < size) {
		return vec3((size - d) * pow(1.0 - distance(p, pos), 10.0));	
	}
	return vec3(0.0);
	
}

void main( void ) {

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 c = vec3(0.0);
	vec2 position = vec2(0.0);
	float r3 = 0.0;
	for (int i = 0; i < amount; i++)
	{
	
		// stars position
		float r1 = rand(vec2(i, i));
		float r2 = rand(vec2(i+ 100, i));
		
		position = vec2(r1,r2);


		// fade in and out
		if ( blend_function == 0 )
		{
			r3 = sin((time + i) * flash_speed) * stars_size *.8;
		}
		// plop in and fadeout 
		if ( blend_function == 1 )
		{
			r3 = sin(fract( (time + i + 10.) * flash_speed) * -1 + 1) * stars_size;
		}
		
		
		// stars rotation
		float r4 = rotation;
		
		for (int i = 0; i < itterations; i++){
			c += pulsar(uv, position, r3, r4 * i);
			c = mix(c * vec3((0.5 + sin(float(i)))), c, (1. - b_diff) * .185) ;
		}
	}

	
	gl_FragColor = vec4( c * 1., 1.0 );

}