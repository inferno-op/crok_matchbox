#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float adsk_time;
uniform float Speed;
uniform float Offset;
float time = adsk_time *.05 * Speed + Offset;

uniform int itteration;
uniform float scale;

// based on http://glslsandbox.com/e#23659.0
// by RAZIK anass
// i found noise and hash fonctions in a stack overflow answer
// and i tried to modify it to get this pixel effect
// but the fractional brownian motion function was written by me
// enjoy my pixel world radar :D ^^

mat2 rotation_mat = mat2(cos(time/5.0),-sin(time/5.0),sin(time/5.0),cos(time/5.0));

float hash(vec2 n){
	float dot_prod = dot(n.y, n.y)+dot(n.x, n.x);
	return fract(cos(time+dot_prod));
}

float noise(vec2 intervale){
	vec2 i = floor(intervale);
	vec2 f = fract(intervale);
	vec2 u = f*f*(1.0-2.0*f);
	
	return mix(mix(hash(i+vec2(0.0,0.0)),
		       hash(i+vec2(1.0,.0)), u.x),
		   mix(hash(i+vec2(0.0,1.0)),
		       hash(i+vec2(1.0,1.0)),u.x),
		   u.y);
}

//fractional brownian motion function
float fbm(vec2 p){
	float f = 0.0;
	float octave = 0.5;
	float sum = 0.0;
	
	for(int i=0;i<itteration;i++){
		sum 	+= octave;
		f 	+= octave*noise(p);
		p 	*= 2.;
		octave	*= .5;
	}
	
	f /= sum;
	
	return f;
}

void main( void ) {
	vec2 uv = gl_FragCoord.xy/resolution.xy*2.0-1.0;
	uv.x *= resolution.x/resolution.y;

	float effect = fbm(scale * uv);
	vec3 color = vec3(effect);
	
	gl_FragColor = vec4(color,1.0);
}