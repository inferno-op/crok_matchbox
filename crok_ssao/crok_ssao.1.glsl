#version 120
// https://github.com/PlumCantaloupe/SSAO-Shader
// original SSAO shader graciously written at: http://www.gamerendering.com/2009/01/14/ssao/

uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time;


uniform sampler2D Front;
uniform sampler2D rnm;
uniform sampler2D normalMap;
uniform float Radius; 
uniform bool static_noise;

const float offset = 15.3434;
const float strength = 0.3;
const float falloff = 0.0;
const int SAMPLES = 10;
float invSamples = -0.5 / SAMPLES;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


// static colour noise
vec3 noise(vec2 st) {
	vec2 c = (resolution.x)*vec2(1.,resolution.y/resolution.x);

	if ( static_noise )
		time = 1.0;
   	float r = rand(vec2((2. + time) * floor(st.x*c.x)/c.x, (2. + time) * floor(st.y*c.y)/c.y ));
   	float g = rand(vec2((5. + time) * floor(st.x*c.x)/c.x, (5. + time) * floor(st.y*c.y)/c.y ));
   	float b = rand(vec2((9. + time) * floor(st.x*c.x)/c.x, (9. + time) * floor(st.y*c.y)/c.y ));

	vec3 col = vec3(r,g,b);

	return col;
}


int randInt(int start, int end)
{
    return int(fract(sin(dot(vec2(start, end),vec2(12.9898,78.233))) * 43758.5453));
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 pSphere[10];
    pSphere[0] = vec3(0.13790712, 0.24864247, 0.44301823);
    pSphere[1] = vec3(0.33715037, 0.56794053, -0.005789503);
    pSphere[2] = vec3(0.06896307, -0.15983082, -0.85477847);
    pSphere[3] = vec3(-0.014653638, 0.14027752, 0.0762037);
    pSphere[4] = vec3(0.010019933, -0.1924225, -0.034443386);
    pSphere[5] = vec3(-0.35775623, -0.5301969, -0.43581226);
    pSphere[6] = vec3(-0.3169221, 0.106360726, 0.015860917);
    pSphere[7] = vec3(0.010350345, -0.58698344, 0.0046293875);
    pSphere[8] = vec3(-0.053382345, 0.059675813, -0.5411899);
    pSphere[9] = vec3(0.035267662, -0.063188605, 0.54602677);

    vec3 fres = noise(uv);
    vec4 currentPixelSample = texture2D(normalMap, uv);
    float currentPixelDepth = currentPixelSample.a;
    vec3 ep = vec3(uv.xy,currentPixelDepth);

    vec3 norm = currentPixelSample.xyz;

    float bl = 0.0;

    float occluderDepth, depthDifference;
    vec4 occluderFragment;
    vec3 ray;

    for(int i=0; i<SAMPLES;++i)
    {
		ray = Radius * 0.01 * reflect(pSphere[i],fres);
		vec2 something = ep.xy + sign(dot(ray,norm) )*ray.xy;
		occluderFragment = texture2D(normalMap, something );
		depthDifference = currentPixelDepth-occluderFragment.a;
		bl += step(falloff,depthDifference)*(1.0-dot(occluderFragment.xyz,norm))*(1.0-smoothstep(falloff,strength,depthDifference));
    }

	vec4 col = vec4(1.0+bl*invSamples);
    gl_FragColor = col;
	
}