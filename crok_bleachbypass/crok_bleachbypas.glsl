uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Source;
uniform float Exposure;
uniform float Amount;
const vec4 one = vec4(1.0);	
const vec4 two = vec4(2.0);
const vec4 lumcoeff = vec4(0.2125,0.7154,0.0721,0.0);

vec4 overlay(vec4 source, vec4 src, vec4 amount)

{
	float luminance = dot(src,lumcoeff);
	float mixamount = clamp((luminance - 0.45) * 10., 0., 1.);
	vec4 branch1 = two * src * source;
	vec4 branch2 = one - (two * (one - src) * (one - source));
	vec4 result = mix(branch1, branch2, vec4(mixamount) );
	return mix(src, result, amount);
}

void main (void) 
{ 		
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec4 tc = texture2D(Source, uv);
	vec4 luma = vec4(dot(tc,lumcoeff));
	luma = clamp(luma, 0.0, 1.0);
	vec4 col = overlay(luma, tc, vec4(Amount)) * Exposure;
	gl_FragColor = col;
		
} 
