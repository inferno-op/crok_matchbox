uniform sampler2D source, adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;
uniform float m_gam, blend, m_sat, m_con;
uniform float m_slope_r, m_slope_g, m_slope_b;
uniform float m_offset_r, m_offset_g, m_offset_b;
uniform float m_power_r, m_power_g, m_power_b;

uniform int look;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);

// Algorithm from Chapter 16 of OpenGL Shading Language
vec3 saturation(vec3 rgb, float adjustment)
{
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

// Real contrast adjustments by  Miles
vec3 contrast(vec3 col, vec4 con)
{
	vec3 c = con.rgb * vec3(con.a);
	vec3 t = (vec3(1.0) - c) / vec3(2.0);
	t = vec3(.5);
	col = (1.0 - c.rgb) * t + c.rgb * col;
return col;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec3 org = texture2D(source, uv).rgb;
    vec3 res1 = texture2D(adsk_results_pass1, uv).rgb;
	
	vec3 c = res1;
	vec3 slope = vec3(1.0);
	vec3 offset = vec3(0.0);
	vec3 power = vec3(1.0);
	float sat = 1.0;
	float con = 1.0;
	float gam = 1.0;
	
	slope = vec3(m_slope_r, m_slope_g, m_slope_b);
	offset = vec3(m_offset_r, m_offset_g, m_offset_b);
	power = vec3(m_power_r, m_power_g, m_power_b);
	sat = m_sat;
	con = m_con;
	gam = m_gam;		

	//apply gamma correction 
	c = pow(c, vec3(gam));
	// apply CDL values
	c = pow(clamp(((c * slope) + offset), 0.0, 1.0), power);
	// apply saturation
	c = saturation(c, (sat));
	// apply contrast
	c = contrast(c, vec4(con));
	// blend original in/out
	c = mix(org, c, blend);
	
    gl_FragColor = vec4(c, 1.0);
}