uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass6, adsk_results_pass8, adsk_results_pass3, matte, adsk_results_pass11;
float time = adsk_time *.05;

uniform float grain_amount;
uniform int matte_output;

float overlay( float s, float d )
{
	return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec3 overlay( vec3 s, vec3 d )
{
	vec3 c;
	c.x = overlay(s.x,d.x);
	c.y = overlay(s.y,d.y);
	c.z = overlay(s.z,d.z);
	return c;
}


// regrain
float rand2(vec2 co) 
{
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 noise(vec2 st) {
	vec2 c_noise = (100.*res.x)*vec2(1.,res.y/res.x);
	vec3 noise_col = vec3(0.0);
   	float r = rand2(vec2((2.+time) * floor(st.x*c_noise.x)/c_noise.x, (2.+time) * floor(st.y*c_noise.y)/c_noise.y ));
   	float g = rand2(vec2((5.+time) * floor(st.x*c_noise.x)/c_noise.x, (5.+time) * floor(st.y*c_noise.y)/c_noise.y ));
   	float b = rand2(vec2((9.+time) * floor(st.x*c_noise.x)/c_noise.x, (9.+time) * floor(st.y*c_noise.y)/c_noise.y ));
	noise_col = vec3(r,g,b);
	return noise_col;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 normal_comp = texture2D(adsk_results_pass6, uv).rgb;
	vec3 blured_comp = texture2D(adsk_results_pass8, uv).rgb;
	vec3 back = texture2D(adsk_results_pass3, uv).rgb;
    vec3 edge_matte = texture2D(adsk_results_pass11, uv).rgb;
	
	vec3 bg_histo = back;
	
	float matte_out = 1.0;

// add regrain
	vec3 grain = noise(uv);
	vec3 grau = vec3 (0.5);
	grain = mix(grau, grain, grain_amount * .03);
	grain = vec3(grain.r);

   	vec3 comp = mix(normal_comp, blured_comp, edge_matte);
	vec3 grain_c = overlay(grain, comp);
	comp = mix(comp, grain_c, edge_matte);
	
	if ( matte_output == 0 )
		matte_out = texture2D(adsk_results_pass6, uv).a;
	if ( matte_output == 1 )
		matte_out = edge_matte.r;
	
	gl_FragColor = vec4(comp, matte_out);
}