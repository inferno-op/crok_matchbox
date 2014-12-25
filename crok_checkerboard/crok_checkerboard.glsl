#version 120
// based on https://www.shadertoy.com/view/Md2XWt

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio, Zoom, Aspect;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float rot;
uniform float zoom;
uniform float blur;
uniform vec3 color1, color2;

    
void main(void)
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - 0.5;
	uv.x /= Aspect;
	vec2 div = vec2( zoom, zoom * resolution.y/resolution.x );
	float bl = 0.0;

	if ( rot != 0.0 )
		bl += blur; 

	float b = bl * zoom / resolution.x;
    float st = sin(rot);
    float ct = cos(rot);
    vec2 xy0 = div* uv;
    vec2 xy;
    xy.x =  ct*xy0.x + st*xy0.y;
    xy.y = -st*xy0.x + ct*xy0.y;
    vec2 sxy = sin(3.14159*xy);
	vec2 square = smoothstep( -b, b, sxy );
	square = 2.0 * square - 1.0;						
    float a = 0.5 * (square.x * square.y) + 0.5;
	vec3 aa = vec3(a) * color1;
	vec3 c = mix(color1, color2, a); 
	gl_FragColor = vec4(c, a);
}