#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform float blur_amount;
uniform vec2 blur_xy_amount;
uniform bool proportinal;

const float pi = 3.141592653589793238462643383279502884197969;

vec4 gblur(sampler2D source, float b_amount, int direction)
{
	vec2 xy = gl_FragCoord.xy;
  	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	float sigma = b_amount + .001;
   
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
		if (direction == 1) {
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
	vec4 blur = vec4(0.0);
	
	if ( proportinal )
		blur = gblur(Front, blur_amount * 0.1 * 4.0, 0 );
	
	else
	{
		// vertical only
		blur = gblur(Front, blur_xy_amount.y * 0.1 * 4.0, 0 );
	}

	gl_FragColor = blur;
}
