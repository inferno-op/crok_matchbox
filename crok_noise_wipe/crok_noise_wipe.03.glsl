#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass2;

uniform float Softness;

//uniform float v_bias;
uniform float h_bias; //Blur Horizontal

//float bias = v_bias;
float bias = 1.0; //Blur Horizontal

//const int dir = 0;
const int dir = 1; //Blur Horizontal

const float pi = 3.141592653589793238462643383279502884197969;


vec4 gblur(sampler2D source)
{
	//The blur function is based heavily off of lewis@lewissaunders.com Ls_Ash shader

	vec2 xy = gl_FragCoord.xy;
  	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	//strength = texture2D(source, gl_FragCoord.xy / res).a;

	float sigma = Softness * bias * strength + .001;
   
	int support = int(sigma * 3.0);

	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * pi) * sigma);
	g.y = exp(-0.5 / (sigma * sigma));
	g.z = g.y * g.y;

	vec4 a = g.x * texture2D(source, xy * px);
	float energy = g.x;
	g.xy *= g.yz;

	for(int i = 1; i <= support; i++) {
		vec2 tmp = vec2(0.0, float(i));
		if (dir == 1) {
			tmp = vec2(float(i), 0.0);
		}

		a += g.x * texture2D(source, (xy - tmp) * px);
		a += g.x * texture2D(source, (xy + tmp) * px);
		energy += 2.0 * g.x;
		g.xy *= g.yz;
	}
	a /= energy;

	return vec4(a);
}

void main(void)
{
    gl_FragColor = gblur(adsk_results_pass2);
}
