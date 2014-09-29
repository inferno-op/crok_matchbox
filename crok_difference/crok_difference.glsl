#version 120

uniform sampler2D front, back;
uniform float adsk_result_w, adsk_result_h;
uniform float brightness, contrast, gain, red, green, blue;
uniform bool clamping, invert;


uniform float minInput;
uniform float maxInput;
uniform float gamma;
uniform float minOutput;
uniform float maxOutput;

const vec3 lumc = vec3(0.2125, 0.7154, 0.0721);

vec3 difference( vec3 s, vec3 d )
{
	return abs(d - s);
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 s = texture2D(front, uv).xyz;
	vec3 d = texture2D(back, uv).xyz;

	vec3 avg_lum = vec3(0.5, 0.5, 0.5);
	vec3 c_channels = vec3(red, green, blue);
	vec3 col = vec3(0.0);


	col = col + difference(s,d);

	col = mix(vec3(0.0), col, c_channels);
	
	col = vec3(max(max(col.r, col.g), col.b));
	col = vec3(dot(col.rgb, lumc));
	col = mix(avg_lum, col, contrast);
	col = col - 1.0 + brightness;
	col = col * gain;
	
    col = min(max(col - vec3(minInput), vec3(0.0)) / (vec3(maxInput) - vec3(minInput)), vec3(1.0));
    col = pow(col, vec3(gamma));
    col = mix(vec3(minOutput), vec3(maxOutput), col);
	

	if ( clamping )
		col = clamp(col, 0.0, 1.0);
	if ( invert )
	    col = 1.0 - col;
	
	gl_FragColor = vec4(col, col);
}