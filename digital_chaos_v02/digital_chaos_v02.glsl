uniform float adsk_time, adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


float hash(vec2 uv)
{
    float r;
    uv = abs(mod(adsk_time*fract((uv+1.1312)*31.),uv+2.));
	uv = floor(233.*uv.x*fract((uv+.721711) ));
	return r = fract(4.34234* (3.*uv.y + 1.5245*uv.x));
}

void main(void)
{
	vec3 grain = vec3(0.0);
	vec2 uv = atan(gl_FragCoord.xy+res.xy - vec2(adsk_time + 500. , adsk_time));
	grain.r = hash(uv+130.);
	grain.g = hash(uv-50.);
	grain.b = hash(uv+23.);

	gl_FragColor = vec4(grain, 1.0);
}