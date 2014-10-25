#version 120
// based on https://www.shadertoy.com/view/MdXXWr

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float adsk_time, p1, p2;
float time = adsk_time *.05;
uniform sampler2D Source;
float cent = 0.0;

uniform int itteration;
uniform float size;

float rand1(vec2 a, out float r)
{
	vec3 p = vec3(a,1.0);
	r = fract(sin(dot(p,vec3(37.1,61.7, 12.4)))*3758.5453123);
	return r;
}

float rand2(inout float b)
{
	b = fract((134.324324) * b);
	return (b-0.5)*2.0;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float n = size / resolution.x;
	rand1(uv, cent);
	vec4 col = vec4(0.0);
	for(int i=0;i<itteration;i++)
	{
		float noisex = rand2(cent);
		float noisey = rand2(cent);
		col += texture2D(Source, uv - vec2(noisex, noisey) * n) / float(itteration);
	}
	gl_FragColor = col;
}