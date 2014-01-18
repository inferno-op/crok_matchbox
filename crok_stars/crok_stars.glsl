uniform float adsk_result_w, adsk_result_h;
uniform float Density;
uniform float Brightness;
uniform float Offset;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

// "Planet K" by Kali
#define PI  3.141592

// Random number implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Formulas stars 
// http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
float Stars(vec3 p) {
	vec3 pos=p;
	p+=vec3(1.35,1.54,1.23);
	p*=.3;
	for (int i=0; i<22; i++) {
		p.xyz=abs(p.xyz);
		p=p/dot(p,p);
		p=p*1.-vec3(.9*Offset*0.1);
	}
	return pow(length(p),1.5*Brightness)*.04*Density;
}
//Main
void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=normalize(vec3(uv*.5,1.));
	vec3 col=vec3(0.);
	col+=vec3(max(0.,.5*Stars(dir*10.)));
	gl_FragColor = vec4(col,1.0);
}