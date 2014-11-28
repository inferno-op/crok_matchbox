#version 120

uniform sampler2D iChannel1;
uniform float adsk_time, Speed, rot, intensity, layers, spacing;
float time = adsk_time *.05 * Speed;

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 center;


void main(void)
{
	vec2 uv = (gl_FragCoord.xy / res.xy) - center;
	vec3 col = vec3(0.0);
	vec3 matte = vec3(1.0);
	
	// rotatation
	float c=cos(rot*0.01),si=sin(rot*0.01);
	uv *=mat2(c,si,-si,c);	

    
    for(float i=0.0; i<layers; i+=1.0) 
	{
    	float s=texture2D(iChannel1,uv*(1.0/i*spacing)+vec2(time)*vec2(0.02,0.501)+vec2(i, i/2.3)).r;
    	col=mix(col,vec3(1.0),smoothstep(0.9,1.0, s * intensity));
		matte=mix(matte,vec3(1.0 / i),smoothstep(0.9, 0.91, s * intensity));
	}

	gl_FragColor = vec4(col,matte);
}