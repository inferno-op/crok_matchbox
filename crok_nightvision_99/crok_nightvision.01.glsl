#version 120

//loading front

uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h;

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 col = texture2D(front, uv).rgb;
	
	gl_FragColor = vec4(col, 1.0);
}