uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Mix;
uniform float Noise, Amplitude;
uniform bool Dissolve, Invert, Horizontal;
 
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

// http://glsl.heroku.com/e#17891.7

float Hash( vec2 p)
{
	vec3 p2 = vec3(p.xy,1.0);
    return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*3758.5453123);
}

float noise(in vec2 p)
{
    vec2 i = floor(p);
	vec2 f = fract(p); 
	f *= f * (3.0-2.0*f);

    return mix(mix(Hash(i + vec2(0.,0.)), Hash(i + vec2(1.,0.)),f.x),
			mix(Hash(i + vec2(0.,1.)), Hash(i + vec2(1.,1.)),f.x),
			f.y);
		}

float fbm(vec2 p) {
	float v = 0.0;
	v += noise(p*1.)*.5;
	v += noise(p*2.)*.25;
	v += noise(p*4.)*.125;
	return v;
}

void main(void) {

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 pos = uv;
	vec3 color = vec3(0.0);
	float dis = 0.0;
	float amp = Amplitude;
	float mult = 1.0;
	float mixmult = 1.0;


    if (Dissolve) {
        mult = 0.0;
        mixmult = .5;
        amp = mix(Amplitude, Mix, Mix);
    }
   
    dis = pos.x * mult;

    if (Horizontal) {
        dis = pos.y * mult;
    }

    dis+= fbm(pos * Noise) * amp ;
    dis-=  Mix * (1.0 + amp * .85) * mixmult;

	dis = 1.0 - dis;
	color = clamp(color + dis / 0.0 ,0.0,1.0);

	float alpha = color.r;

	if (Invert) {
		alpha = 1.0 - alpha;
	}

	gl_FragColor = vec4(alpha);
}
