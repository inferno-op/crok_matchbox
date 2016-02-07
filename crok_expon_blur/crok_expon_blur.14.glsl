#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass13, Strength;
uniform float blur_amount;
uniform vec2 blur_xy_amount;
uniform bool proportinal, ena_proxy;

const float pi = 3.141592653589793238462643383279502884197969;

uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;
float strength = 1.0;
vec2 texel  = vec2(1.0) / res;

vec4 gblur(sampler2D source, float b_amount, vec2 direction)
{
	 //The blur function is the work of Lewis Saunders.
	vec2 xy = gl_FragCoord.xy;
	//Optional texture used to weight amount of blur
	float proxy = 3.0;
	if ( ena_proxy )
		proxy = 2.0;
	strength = texture2D(Strength, gl_FragCoord.xy / res).r;
	float br = blur_red * b_amount * strength;
	float bg = blur_green * b_amount * strength;
	float bb = blur_blue * b_amount * strength;
	float bm = blur_matte * b_amount * strength;
	float support = max(max(max(br, bg), bb), bm) * proxy;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * pi) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(source, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
        a += gx * texture2D(source, (xy - i * direction) * texel);
        a += gx * texture2D(source, (xy + i * direction) * texel);
		energy += 2.0 * gx;
		gx *= gy;
		gy *= gz;
	}
	a /= energy;
	return a;
}

void main(void)
{
	vec4 blur = vec4(0.0);
	float b_amount = abs(blur_amount);
	vec2 b_xy_amount = abs(blur_xy_amount);
	
	if ( proportinal )
		blur = gblur(adsk_results_pass13, b_amount * 0.1 * 128.0, vec2(0.0, 1.0) );
	
	else
	{
		// vertical only
		blur = gblur(adsk_results_pass13, b_xy_amount.x * 0.1 * 128.0, vec2(0.0, 1.0) );
	}

	gl_FragColor = blur;
}