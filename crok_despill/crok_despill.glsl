#version 120

uniform sampler2D front, back, matte, f_despilled;
uniform float adsk_result_w, adsk_result_h, minInput, maxInput;


vec3 saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
}

vec3 difference( vec3 s, vec3 d )
{
	return abs(d - s);
}

vec3 linearDodge( vec3 s, vec3 d )
{
	return s + d;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 c = vec3(0.0);
	
	// front 
	vec3 f = texture2D(front, uv).rgb;
	// back
	vec3 b = texture2D(back, uv).rgb;
	// matte
	float m = texture2D(matte, uv).r;
	// despilled front
	vec3 d = texture2D(f_despilled, uv).rgb;
	// difference despilled FG and FG
	c = difference(d,f);
	
	
	// do some 2D Histogramm adjustments
	c = min(max(c - vec3(minInput), vec3(0.0)) / (vec3(maxInput) - vec3(minInput)), vec3(1.0));
	// desaturate the image
	c = saturation(c, 0.0);
	
	// multiply Result and BG
    c = multiply(c,b);
	
	// add despilled FG on top of Result
   	c =  linearDodge(d,c);
	
	// add beautiful despilled result ontop of the BG with a Matte
    c = vec3(m * c + (1.0 - m) * b);
	
	
	gl_FragColor = vec4(c, m);
}