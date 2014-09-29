uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass5, adsk_results_pass7, matte;
float time = adsk_time *.05;

uniform float edge, grain_amount;

// edge detection based on https://www.shadertoy.com/view/Mdf3zr
float lookup(vec2 p, float dx, float dy)
{
    vec2 uv = (p.xy + vec2(dx * edge, dy * edge)) / res.xy;
    vec4 e_matte = texture2D(matte, uv.xy);
    return 0.2126*e_matte.r + 0.7152*e_matte.g + 0.0722*e_matte.b;
}

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
	vec3 normal_comp = texture2D(adsk_results_pass5, uv).rgb;
	vec3 n_matte = texture2D(adsk_results_pass5, uv).rgb;
	vec3 blured_comp = texture2D(adsk_results_pass7, uv).rgb;

// add regrain
	vec3 grain = noise(uv);
	vec3 grau = vec3 (0.5);
	grain = mix(grau, grain, grain_amount * .03);
	grain = vec3(grain.r);

	vec3 p_level = vec3(0.0, 1.0, 1.0);
    n_matte = min(max(n_matte - vec3(p_level.x), vec3(0.0)) / (vec3(p_level.z) - vec3(p_level.x)), vec3(1.0));
    n_matte = pow(n_matte, vec3(p_level.y));

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
	vec3 comp = mix(normal_comp, blured_comp, edge_matte.rgb);
	vec3 grain_c = overlay(grain, comp);
	comp = mix(comp, grain_c, edge_matte.rgb);
	
	gl_FragColor = vec4(comp, edge_matte);
}