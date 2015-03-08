uniform float adsk_time, adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


float hash(vec2 uv)
{
    float r;
    uv = abs(mod(adsk_time*fract((uv+1.1312)*31.),uv+2.));
	uv = floor(uv.x*fract((uv+.721711) ));
	return r = fract(3.34234* (.0452*uv.y + 1.5245*uv.x));
}

void main(void)
{
	vec3 grain = vec3(0.0);
	vec2 uv = (fract(sin(adsk_time)*(gl_FragCoord.xy * res.y)) * 500.) +0.5;
	grain.r = fract(hash(vec2(hash(uv),1.0)));

	gl_FragColor = vec4(grain.rrr * 3.0, 1.0);
}