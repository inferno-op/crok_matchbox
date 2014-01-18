uniform sampler2D FG;
uniform sampler2D BG;
uniform vec3 colour;
uniform float p1;
uniform float p2;
uniform float p3;


uniform float adsk_result_w, adsk_result_h;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

// a very rough chroma key 
// created by Zavie in 2013-May-28
// https://www.shadertoy.com/view/4dX3WN


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
	vec3 weights = vec3(p1, p2, p3);

	vec3 hsv = rgb2hsv(color);
	vec3 target = rgb2hsv(backgroundColor);
	float dist = length(weights * (target - hsv));
	return 1. - clamp(3. * dist - 1.5, 0., 1.);
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	
	vec3 color = texture2D(FG, uv).rgb;
	vec3 bg = texture2D(BG, -uv).rgb;
	
	float incrustation = chromaKey(color);
	
	color = mix(color, bg, incrustation);

	gl_FragColor = vec4(color, incrustation);
}
