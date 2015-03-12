#version 120

// based on: https://www.shadertoy.com/view/4lfGWl

uniform sampler2D Noise;
uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
    uv = mod(uv*0.8,fract(time*4.028));
    
    float t = texture2D(Noise, uv).r;

    vec2 gr = vec2(sin(time+uv.x*0.3),cos(time+uv.y*0.6));
    float r = texture2D(Noise, gr*2.97).r;
    
	vec2 tx = vec2(1.0/resolution.x,1.0/resolution.y);
   
    float vv = fract(sin(time*tan(time)));

    float b = 0.0;
    float c = 0.0;
    for ( int i=0; i<32; i++ )
    {
    	b += texture2D(Noise,vec2(uv.x*vv,uv.y-r)/(tx.xy*float(i)*(cos(time*r)*0.5+0.5)*3.2)).r;
        c += texture2D(Noise,vec2(uv.x-r,uv.y*vv)/(tx.xy*float(i)*(sin(time*r)*0.5+0.5)*7.0)).r;
    }
    b /= 32;
    c /= 32;
    
	float e = smoothstep(-vv,vv+0.4,b-c);
    gl_FragColor = vec4(e,e,e,1.0);  
}
