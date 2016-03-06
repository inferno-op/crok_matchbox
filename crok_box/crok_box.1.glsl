#version 120
// based on https://www.shadertoy.com/view/Xs33DN

uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio, adsk_result_pixelratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform float corner, scale;
uniform bool square;

float udRoundBox( vec2 p, vec2 b, float r )
{
	return length(max(abs(p)-b+r,0.0))-r;
}

void main(void)
{
    vec2 coord = gl_FragCoord.xy;
	if ( square )
	{
	    coord.x -=  (adsk_result_w - adsk_result_h) / 2.0;
		res.x /= adsk_result_frameratio / adsk_result_pixelratio;
	}
    float f = udRoundBox( coord.xy-(res.xy - 1500.0)/2.0, (res.xy - 1500.0)/2.0, corner + 1.0);
	float s = udRoundBox( (coord.xy-res.xy/2.0), res.xy/2.0, corner + 1.0);
    f = (f>0.0) ? 0.0 : 1.0;
    gl_FragColor = vec4(s * -1.);
}