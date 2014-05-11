uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform float Speed;
uniform float Offset;
uniform float seed;
uniform float detail;
uniform float noise;
uniform float zoom;
uniform float rotation;
uniform vec2 center;


uniform vec3 color;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05 * Speed + Offset;


//Wrinkled paper generator
//based off http://www.claudiocc.com/the-1k-notebook-part-iii/
//http://glsl.heroku.com/e#16688.0

float rand(float n)
{
    vec2 co = vec2(n,3.4234324-n);
    return fract(sin(dot(co.xy ,vec2(16.9898,78.233))) * 9958.5453);
}

vec3 LinearGrad(vec2 p1,vec2 p2,vec2 px)
{
	vec2 dir = (normalize(p2-p1)) / noise * 10.;
	float g = dot(px-p1,dir)/length(p1-p2);
	return vec3(clamp(g,0.,1.));
}

vec3 Difference(vec3 c1,vec3 c2)
{
	return abs(c1-c2);
}


vec3 Paper(vec2 p)
{
	vec3 c = vec3(0.0);
	
	for(float i = 0.;i < detail;i++)
	{
		vec2 p1 = vec2(rand(1.+i+seed-6.67)+cos(time*0.43)*0.1,rand(1.1+i+seed-16.68)+sin(time*0.89)*0.1) * resolution;
		vec2 p2 = vec2(rand(0.2+i+seed-6.68)+cos(time*0.456)*0.1,rand(1.3+i+seed-16.68)+sin(time*0.00000033)*0.1) * resolution;

		c = Difference(c,LinearGrad(p1, p2, p));
	}
	return c;
}

vec3 Band(float pc)
{
	vec3 c;
	c = mix(vec3(0),vec3(color.x,color.y,color.z),pc);
	return c;
}

void main( void ) 
{

	vec2 p = ((gl_FragCoord.xy / resolution.xy) - center) * zoom * 500.;

    mat2 rotcalc = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );
	p *= rotcalc;
					   
	vec3 c = Band(1.-Paper(p).x);
		
	gl_FragColor = vec4(c, 1.0 );
}