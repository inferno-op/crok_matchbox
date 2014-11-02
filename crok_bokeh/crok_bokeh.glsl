// Bokeh disc.
// by David Hoskins.
// https://www.shadertoy.com/view/4d2Xzw#
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

uniform sampler2D source;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float adsk_time, blur, gain, p1, p2;
float time = adsk_time;
uniform float NUMBER;

#define ONEOVER_ITR  1.0 / ITERATIONS
#define PI 3.141596

// This is (3.-sqrt(5.0))*PI radians, which doesn't precompiled for some reason.
// The compiler is a dunce I tells-ya!!
#define GOLDEN_ANGLE 2.39996323
// #define NUMBER 150.0

#define ITERATIONS (GOLDEN_ANGLE * NUMBER)

// This creates the 2D offset for the next point.
// (r-1.0) is the equivalent to sqrt(0, 1, 2, 3...)
vec2 Sample(in float theta, inout float r)
{
    r += 1.0 / r;
	return (r-1.0) * vec2(cos(theta), sin(theta)) * .06;
}

vec3 Bokeh(sampler2D tex, vec2 uv, float radius, float amount)
{
	vec3 acc = vec3(0.0);
	vec3 div = vec3(0.0);
    vec2 pixel = vec2(resolution.y/resolution.x, 1.0) * radius * .025;
    float r = 1.0;
	for (float j = 0.0; j < ITERATIONS; j += GOLDEN_ANGLE)
    {
		vec3 col = texture2D(tex, uv + pixel * Sample(j, r)).xyz;
		vec3 bokeh = vec3(5.0) + pow(col, vec3(9.0)) * amount;
		acc += col * bokeh;
		div += bokeh;
	}
	return acc / div;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
    gl_FragColor = vec4(Bokeh(source, uv, blur * .4, gain * .0003), 1.0);
}
    
