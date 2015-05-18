#version 120

// Original shader by Xavier Benech
// www.shadertoy.com/view/XsXSWS
// License Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
// creativecommons.org/licenses/by-sa/4.0/

//////////////////////
// Fire Flame shader
// procedural noise from IQ

uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform float Speed;
uniform float Offset;
uniform float flame_noise;
vec3 adsk_getComputedDiffuse();
vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor ); 

float time = adsk_time *.03 * Speed + Offset;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

vec2 hash( vec2 p )
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			 dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor( p + (p.x+p.y)*K1 );
	vec2 a = p - i + (i.x+i.y)*K2;
	vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
	vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
	return dot( n, vec3(70.0) );
}

float fbm(vec2 uv)
{
	float f;
	//mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
	mat2 m = mat2( 1.7, 1.10,  -1.3, 1.5);
	f += 0.5000*noise( uv ); uv = m*uv*1.01;
	f += 0.3500*noise( uv ); uv = m*uv*1.04;
	f += 0.2500*noise( uv ); uv = m*uv*1.04;
	f += 0.1250*noise( uv ); uv = m*uv*1.03;
	f += 0.0625*noise( uv ); uv = m*uv*1.10;
	f = 0.5 + 0.5*f;
	return f;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec2 q = uv;
	q.x *= 5.;
	q.y *= 2.;
	float T3 = max(3.,1.25*flame_noise)*time;
	q.x -= 2.5;
	q.y -= .18;
	float n = fbm(flame_noise * q - vec2(0,T3));
	float c = 1. - 16. * pow( max( 0., length(q*vec2(1.8+q.y*1.5,.75) ) - n * max( 0., q.y+.25 ) ),1.2 );
	float c1 = n * c * (1.5-pow(1.3 *uv.y,4.));
	vec3 col = clamp(vec3(1.5*c1, 1.5*c1*c1*c1, c1*c1*c1*c1*c1), 0.0, 1.0);
	float a = clamp(c * (1.-pow(uv.y,3.)), 0.0, 1.0);
	gl_FragColor = vec4(mix(vec3(0.),col,a), 1.0);
}