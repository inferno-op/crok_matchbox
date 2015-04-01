#version 120

// based on https://www.shadertoy.com/view/ldBGDc by FabriceNeyret2

uniform float adsk_result_w, adsk_result_h, adsk_time, adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float t = adsk_time *.05;

float spiral(vec2 m) {
	float r = length(m);
	float a = atan(m.y, m.x);
	float v = sin(200.*(sqrt(r)-0.02*a-.5*t));
	return clamp(v,0.,1.);

}

void main( )
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - 0.5;
	uv.x *= adsk_result_frameratio;
	float v = spiral(uv);
	vec3 col = vec3(v);
	gl_FragColor = vec4(col,1.);
}