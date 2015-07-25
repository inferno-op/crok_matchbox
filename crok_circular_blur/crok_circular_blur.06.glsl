//based on https://www.shadertoy.com/view/4df3R7 by hornet

uniform sampler2D adsk_results_pass4, adsk_results_pass5;
uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform float adsk_time, amount;
uniform int detail;

float time = adsk_time *.05;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

const int NUM_SAMPLES = 64;
const int NUM_SAMPLES2 = NUM_SAMPLES/2;
const float NUM_SAMPLES_F = float(NUM_SAMPLES);
const float anglestep = 6.28 / NUM_SAMPLES_F;
const float MIPBIAS = -8.0; //note: make sure we always pick mip0

float nrand( vec2 n ) {
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;

	float strength = texture2D(adsk_results_pass5, uv).r;
    
    float ctrdist = length(vec2(0.5,0.5)-uv);
	float rnd = nrand( 0.01*gl_FragCoord.xy + fract(time) );

	vec2 ofs[NUM_SAMPLES];
	{
		vec2 c1 = vec2(amount * strength +0.001) / resolution.xy;
		float angle = 3.1416*rnd;
		for( int i=0;i<NUM_SAMPLES2;++i )
		{
			ofs[i] = c1 * vec2( cos(angle), sin(angle) );
			angle += anglestep;
		}
	}
	
	vec4 sum = vec4(0.0);
	//note: sample positive half-circle
	for( int i=0;i<NUM_SAMPLES2;++i )
		sum += texture2D( adsk_results_pass4, uv+ofs[i], MIPBIAS );

	//note: sample negative half-circle
	for( int i=0;i<NUM_SAMPLES2;++i )
		sum += texture2D( adsk_results_pass4, uv-ofs[i], MIPBIAS );

	gl_FragColor = sum / NUM_SAMPLES_F;
}
