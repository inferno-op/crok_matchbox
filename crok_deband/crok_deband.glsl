#version 120

// based on: http://media.steampowered.com/apps/valve/2015/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf

uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

uniform float amount, size;

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec4 image = texture2D(front, uv);
	
    vec3 dither = vec3(dot(vec2( 171.0, 231.0 ), gl_FragCoord.xy + vec2(time)));
    dither.rgb = fract( dither.rgb / vec3(103.0,71.0,97.0)) - vec3(0.5);
	vec4 col = vec4(( dither.rgb / 255.0 * amount ), 1.0 ) + image;
	
	gl_FragColor = col;
}



