#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform float rot;
uniform float zoom;
uniform float blur;
uniform float Aspect;
uniform vec3 color1, color2;
#define PI 3.14159265359

vec2 resolution = vec2(adsk_result_w, adsk_result_h);

    
void main(void)
{
	vec2 uv = ((gl_FragCoord.xy / resolution.xy) - 0.5);
	float bl = 0.0;

	if ( rot != 0.0 )
		bl += blur; 

	float b = bl * zoom / resolution.x;

	uv.x *= adsk_result_frameratio;
	// degrees to radians conversion
	float rad_rot = rot * PI / 180.0; 

	// rotation
	mat2 rotation = mat2( cos(-rad_rot), -sin(-rad_rot), sin(-rad_rot), cos(-rad_rot));
	uv *= rotation;
	
	uv.x *= Aspect;
	uv *= zoom;
	
	
    vec2 anti_a = sin(PI * uv);
	vec2 square = smoothstep( -b, b, anti_a );
	square = 2.0 * square - 1.0;						
    float a = 0.5 * (square.x * square.y) + 0.5;
	vec3 c = mix(color1, color2, a); 
	gl_FragColor = vec4(c, a);
}