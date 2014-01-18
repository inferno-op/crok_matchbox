uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time*.05;


float rand(float val, float seed){
	return cos(val*sin(val*seed)*seed);	
}

float distance2( in vec2 a, in vec2 b ) { return dot(a-b,a-b); }

mat2 rr = mat2( cos(1.0), -sin(1.0), sin(1.0), cos(1.0) );

vec3 drawParticles(vec2 pos, vec3 particolor, float time, vec2 cpos, float gravity, float seed, float timelength){
    vec3 col= vec3(0.0);
    vec2 pp = vec2(1.0,0.0);
    for(float i=1.0;i<=128.0;i++){
        float d=rand(i, seed);
        float fade=(i/128.0)*time;
        vec2 particpos = cpos + time*pp*d;
        pp = rr*pp;
        col = mix(particolor/fade, col, smoothstep(0.0, 0.0001, distance2(particpos, pos)));
    }
    col*=smoothstep(0.0,1.0,(timelength-time)/timelength);
	
    return col;
}
vec3 drawFireworks(float time, vec2 uv, vec3 particolor, float seed){
	
	float timeoffset = 2.0;
	vec3 col=vec3(0.0);
	if(time<=0.){
		return col;	
	}
	if(mod(time, 6.0)>timeoffset){
	col= drawParticles(uv, particolor, mod(time, 6.0)-timeoffset, vec2(rand(ceil(time/6.0),seed),-0.5), 0.1, ceil(time/6.0), seed);
	}else{
		
	}
	return col;	
}

void main(void)
{
	vec2 uv =1.0 -  2.0* gl_FragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	vec3 col=vec3(0.1,0.1,0.2);
	col += 0.1*uv.y;
	
	
	col += drawFireworks(iGlobalTime    , uv,vec3(1.0,0.1,0.1), 1.);
	col += drawFireworks(iGlobalTime-0.3, uv,vec3(0.0,1.0,0.5), 2.);
	col += drawFireworks(iGlobalTime-0.5, uv,vec3(1.0,.20,0.4), 3.);
	col += drawFireworks(iGlobalTime-0.9, uv,vec3(.50,.20,0.1), 4.);
	col += drawFireworks(iGlobalTime-1.5, uv,vec3(.70,0.1,0.1), 5.);
	col += drawFireworks(iGlobalTime-1.9, uv,vec3(0.0,1.0,0.5), 6.);
	col += drawFireworks(iGlobalTime-2.5, uv,vec3(.8,1.0,0.1), 7.);
	col += drawFireworks(iGlobalTime-3.2, uv,vec3(.8,1.0,0.5), 8.);

	
		gl_FragColor = vec4(col,1.0);
}