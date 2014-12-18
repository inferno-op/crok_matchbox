#version 120
// based on http://glslsandbox.com/e#21575.0

uniform float offset, zoom;
uniform int iterations;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

#define formuparam 0.6
#define time 0.0
#define volsteps 7
#define stepsize 1.
#define tile   02.400
#define speed  0.00025 
#define brightness 1.5/pow(float(iterations), 2.60)
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850


void main(void)
{
	vec2 uv=gl_FragCoord.xy/resolution.xy-.5 + vec2(0.5,0.2);
	uv.y*=resolution.y/resolution.x;
	vec3 dir=vec3(uv*zoom,1.);

	float a1= offset/resolution.x;
	float a2= offset/resolution.y;
	mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
	mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
	dir.xz*=rot1;
	dir.xy*=rot2;
	vec3 from=vec3(1.,.5,0.5);
	from+=vec3(time*0.,2.,1.1*1.);
	from.xz*=rot1;
	from.xy*=rot2;
	
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.)));
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam;
			a+=abs(length(p)-pa);
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001);
		a*=a*a;
		if (r>6) fade*=1.-dm; 
		v+=fade;
		v+=pow(vec3(s,s,s), vec3(0., 0.6, 0.8)*-0.3)*a*brightness*pow(fade, 4.);
		fade*=distfading;
		s+=stepsize;
	}

	// gl_FragColor = vec4(v*.005,1.);	
	vec4 col = vec4(v*.005,1.);
	col = clamp (col, 0.0, 1.0);
	gl_FragColor = col;
	
	
}