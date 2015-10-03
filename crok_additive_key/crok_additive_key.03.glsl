#version 120
// processing matte input
// denoise based on https://www.shadertoy.com/view/4tfSDr by gongenhao

uniform sampler2D matte;

uniform float sigma_color;
uniform float filter_window;
uniform bool denoise;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

float sigma_spatial = 1.0;

// start denoise part
float random(vec3 scale, float seed) 
{
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec3 NLFilter(vec2 uv, float sigma_spatial,float sigma_color)
{
	float wsize = filter_window * 0.00214285714286;
    vec3 res_color = vec3(0.0,0.0,0.0);
    float res_weight = 0.0;
    vec3 center_color=texture2D(matte,uv).rgb;
    float sigma_i=0.5*wsize*wsize/sigma_spatial/sigma_spatial;
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    float offset2 = random(vec3(112.9898, 178.233, 51.7182), 0.0);    
    for (float i = -7.0; i <= 7.0; i++) {
        for (float j= -7.0; j<= 7.0; j++) {
            vec2 uv_sample = uv+vec2(float(i+offset-0.5)*wsize,float(j+offset-0.5)*wsize);
        	vec3 tmp_color = texture2D(matte,uv_sample).rgb;   
            vec3 diff_color = (tmp_color-center_color);
            float tmp_weight = exp(-(i*i+j*j)*sigma_i);
            tmp_weight *= exp(-(dot(diff_color,diff_color)/2.0/sigma_color/sigma_color));
            res_color += tmp_color * tmp_weight;
            res_weight += tmp_weight;   
        }
    }
    vec3 res = res_color/res_weight;
    return res;
}
// end denoise part

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec3 col = texture2D(matte, uv).rgb;
	
	if ( denoise )
	{
	    vec3 d_col = NLFilter(uv*vec2(1.0,1.0),sigma_spatial * 0.01,sigma_color * 0.04);    
	    vec3 base = texture2D(matte,uv*vec2(1.0,-1.0)).rgb;   
	    col = mix(base,d_col,1.0);
	}
	else
		col;
	gl_FragColor = vec4(col, 0.0);
}