uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass5, adsk_results_pass7, matte;

uniform float edge;

// edge detection based on https://www.shadertoy.com/view/Mdf3zr
float lookup(vec2 p, float dx, float dy)
{
    vec2 uv = (p.xy + vec2(dx * edge, dy * edge)) / res.xy;
    vec4 e_matte = texture2D(matte, uv.xy);
    return 0.2126*e_matte.r + 0.7152*e_matte.g + 0.0722*e_matte.b;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 normal_comp = texture2D(adsk_results_pass5, uv).rgb;
	vec3 blured_comp = texture2D(adsk_results_pass7, uv).rgb;
	

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
	
	
	gl_FragColor = vec4(comp, edge_matte );
}