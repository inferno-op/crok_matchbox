uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time*.05;

uniform sampler2D u_texture;

uniform float sphsize; 
uniform float dist;
uniform float perturb;
uniform float stepsize;
uniform float brightness;
uniform vec3 tint;
uniform vec3 Speed;
uniform float fade;
uniform float glow;
uniform int iterations;
uniform vec2 center;
uniform float size;
uniform float fractparam;

const vec3 offset=vec3(20.54,142.,-1.55);
const float steps = 16.0;
const float displacement = 1.0;


float wind(vec3 p) {
	float d=max(0.,dist-max(0.,length(p)-sphsize)/sphsize)/dist;
	float x=max(0.2,p.x*2.);
	p.y*=1.+max(0.,-p.x-sphsize*.25)*1.5;
	p-=d*normalize(p)*perturb;
	p+=vec3(time*Speed.x,time*Speed.y,time*Speed.z);
	p=abs(fract((p+offset)*.1)-.5);
	for (int i=0; i<iterations; i++) {  
		p=abs(p)/dot(p,p)-fractparam;
	}
	return length(p)*(1.2+d*glow*x)+d*glow*x;
}

void main(void)
{
	vec2 uv = 0.15 * size * ( 2.0 * gl_FragCoord.xy - resolution.xy ) / (0.5 * (resolution.x + resolution.y)) - center;
	vec3 dir=vec3(uv,1.);
	dir.x*=resolution.x/resolution.y;
	vec3 from=vec3(0.,0.,-2.+texture2D(u_texture,uv*.5+time).x*0.07*stepsize); //from+dither
	float v=0., l=-0.0001, t=time*Speed.x*.2;
    vec3 p;
    float tx;
	for (float r=10.;r<steps;r++) {
		p=from+r*dir*0.07*stepsize;
		tx=texture2D(u_texture,uv*.2+vec2(t,0.)).x*displacement;
		
        v+=min(50.,wind(p))*max(0.,1. - 0.7 - r*0.015*fade); 
	}
	
    v/=steps; v*=brightness;
	vec3 col=vec3(v*tint.r,v*tint.g,v*tint.b);

	col *= (0.75-length(sqrt(3.0 * uv*uv)));
	col *= length(col) * 50.0;
	gl_FragColor = vec4(col,1.0);
}