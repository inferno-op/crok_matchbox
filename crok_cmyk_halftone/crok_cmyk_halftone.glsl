uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D iChannel0;
uniform float pScale;

uniform float pDotsize;
uniform float pMax;
uniform float pMin;

float iGlobalTime = adsk_time*.05;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);


#define D2R(d) radians(d)
#define SST 0.888
#define SSQ 0.288

vec2 ORIGIN = 0.5*iResolution.xy;
float S = pMin+(pMax-pMin)*(0.5-0.5*cos(0.57*iGlobalTime));
float R = 0.57*0.333*iGlobalTime;

vec4 rgb2cmyki(in vec4 c)
{
	float k = max(max(c.r,c.g),c.b);
	return min(vec4(c.rgb/k,k),1.0);
}

vec4 cmyki2rgb(in vec4 c)
{
	return vec4(c.rgb*c.a,1.0);
}

vec2 px2uv(in vec2 px)
{
	return vec2(px/iResolution.xy);
}

vec2 grid(in vec2 px)
{
	//return px-mod(px,S);
	return floor(px/S)*S; // alternate
}

vec4 ss(in vec4 v)
{
	return smoothstep(SST-SSQ,SST+SSQ,v);
}

vec4 halftone(in vec2 fc,in mat2 m)
{
	vec2 smp = (grid(m*fc)+0.5*S)*m;
	float s = min(length(fc-smp)/(pDotsize*0.5*S),1.0);
	vec4 c = rgb2cmyki(texture2D(iChannel0,px2uv(smp+ORIGIN)));
	return c+s;
}

mat2 rotm(in float r)
{
	float cr = cos(r);
	float sr = sin(r);
	return mat2(
		cr,-sr,
		sr,cr
	);
}

void main()
{

	{
		S = pMin+(pMax-pMin)*2.0*abs(pScale-ORIGIN.x)/iResolution.x;
		R = D2R(180.0*(0.0-ORIGIN.y)/iResolution.y);
	}
	
	vec2 fc = gl_FragCoord.xy-ORIGIN;
	
	mat2 mc = rotm(R+D2R(15.0));
	mat2 mm = rotm(R+D2R(75.0));
	mat2 my = rotm(R);
	mat2 mk = rotm(R+D2R(45.0));
	
	float k = halftone(fc,mk).a;
	vec4 c = cmyki2rgb(ss(vec4(
		halftone(fc,mc).r,
		halftone(fc,mm).g,
		halftone(fc,my).b,
		halftone(fc,mk).a
	)));
	gl_FragColor = c;
}
