#version 120
// edge detection and edge blur
uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass8, adsk_results_pass5, matte;

uniform float edge, em_threshold, em_gain;
uniform int matte_output;

// edge detection based on https://www.shadertoy.com/view/Mdf3zr
float lookup(vec2 p, float dx, float dy)
{
    vec2 uv = (p.xy + vec2(dx * edge, dy * edge)) / res.xy;
    vec4 e_matte = texture2D(matte, uv.xy);
    return 0.2126*e_matte.r + 0.7152*e_matte.g + 0.0722*e_matte.b;
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 n_matte = texture2D(adsk_results_pass8, uv).rgb;
	vec3 back = texture2D(adsk_results_pass5, uv).rgb;
	
// add edge blur	
    vec2 p = gl_FragCoord.xy;
    float gx = 0.0;
    gx += -1.0 * lookup(p, -1.0, -1.0);
    gx += -2.0 * lookup(p, -1.0,  0.0);
    gx += -1.0 * lookup(p, -1.0,  1.0);
    gx +=  1.0 * lookup(p,  1.0, -1.0);
    gx +=  2.0 * lookup(p,  1.0,  0.0);
    gx +=  1.0 * lookup(p,  1.0,  1.0);
    float gy = 0.0;
    gy += -1.0 * lookup(p, -1.0, -1.0);
    gy += -2.0 * lookup(p,  0.0, -1.0);
    gy += -1.0 * lookup(p,  1.0, -1.0);
    gy +=  1.0 * lookup(p, -1.0,  1.0);
    gy +=  2.0 * lookup(p,  0.0,  1.0);
    gy +=  1.0 * lookup(p,  1.0,  1.0);
    float g = gx*gx + gy*gy;
    
    vec4 edge_matte = texture2D(matte, p / res.xy);
    edge_matte = vec4(g, g, g, 1.0);
	edge_matte = clamp (edge_matte, 0.0, 1.0);
    back = pow(back, vec3(em_threshold));
	back = vec3(max(max(back.r, back.g), back.b));
	back = back * em_gain;
	n_matte = multiply(back, edge_matte.rgb);
	n_matte = clamp (n_matte, 0.0, 1.0);

	gl_FragColor = vec4(n_matte, 1.0);
}