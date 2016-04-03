#version 120
// chroma key
// a very rough chroma key
// created by Zavie in 2013-May-28
// https://www.shadertoy.com/view/4dX3WN

// load Front
uniform sampler2D adsk_results_pass1, adsk_results_pass2;
uniform vec3 colour;
uniform vec3 weights;
uniform float adsk_result_w, adsk_result_h;
uniform	bool use_external_matte_as_skin;

vec3 rgb2hsv(vec3 rgb)
{
	float Cmax = max(rgb.r, max(rgb.g, rgb.b));
	float Cmin = min(rgb.r, min(rgb.g, rgb.b));
    float delta = Cmax - Cmin;

	vec3 hsv = vec3(0., 0., Cmax);

	if (Cmax > Cmin)
	{
		hsv.y = delta / Cmax;

		if (rgb.r == Cmax)
			hsv.x = (rgb.g - rgb.b) / delta;
		else
		{
			if (rgb.g == Cmax)
				hsv.x = 2. + (rgb.b - rgb.r) / delta;
			else
				hsv.x = 4. + (rgb.r - rgb.g) / delta;
		}
		hsv.x = fract(hsv.x / 6.);
	}
	return hsv;
}

float chromaKey(vec3 color)
{
	vec3 backgroundColor = vec3(colour.r, colour.g, colour.b);
	vec3 hsv = rgb2hsv(color);
	vec3 target = rgb2hsv(backgroundColor);
	//hsv.x = hue_adj * 0.01;
	float dist = length(weights * (target - hsv));
	return 1. - clamp(3. * dist - 1.5, 0., 1.);
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 col = texture2D(adsk_results_pass1, uv).rgb;
	// Incomming external Matte
	float ext_m =  texture2D(adsk_results_pass2, uv).a;
	float matte = chromaKey(col);

	if ( use_external_matte_as_skin )
		matte = ext_m;

	gl_FragColor = vec4(matte);
}
