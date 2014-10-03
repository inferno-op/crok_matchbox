uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_results_pass2, adsk_results_pass4, compo, matte;

uniform float blend, low, threshold, high, gain;
uniform int LogicOp;
uniform int result;

vec3 normal( vec3 s, vec3 d )
{
	return s;
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
}

vec3 screen( vec3 s, vec3 d )
{
	return s + d - s * d;
}

vec3 linearDodge( vec3 s, vec3 d )
{
	return s + d;
}

vec3 lighten( vec3 s, vec3 d )
{
	return max(s,d);
}

vec3 lighterColor( vec3 s, vec3 d )
{
	return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
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

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 lightwrap_matte = vec3(0.0);
	vec3 comp = vec3(0.0);
	vec3 black = vec3(0.0); 
	vec3 p_level = vec3(low, threshold, high);
	vec3 front = texture2D(compo, uv).rgb;
	vec3 back = texture2D(adsk_results_pass2, uv).rgb;
	vec3 bg_histo = back;
//	vec3 bg_histo = texture2D(bg, uv).rgb;
    vec3 alpha = texture2D(matte, uv).rgb;
	vec3 blurred_matte = texture2D(adsk_results_pass4, uv).rgb;
	vec3 inv_matte = 1.0 - blurred_matte;
	
    bg_histo = pow(back, vec3(p_level.y));
	bg_histo = vec3(max(max(bg_histo.r, bg_histo.g), bg_histo.b));
	bg_histo = bg_histo * gain;
	
	lightwrap_matte = multiply(alpha, inv_matte);
	lightwrap_matte = multiply(bg_histo, lightwrap_matte);
	
	lightwrap_matte = clamp (lightwrap_matte, 0.0, 1.0);
	

    if( LogicOp ==0)
		comp = screen(back, front);
    else if ( LogicOp == 1)
		comp = linearDodge(back, front);
	else if ( LogicOp == 2)
		comp = lighten(back, front);
    else if ( LogicOp == 3)
		comp = lighterColor(back, front);
    else if ( LogicOp == 4)
		comp = overlay(back, front);
    else
		comp = normal(back, front);

	if ( result == 1)
		comp = mix(black, comp, lightwrap_matte * blend);
	else
		comp = mix(front, comp, lightwrap_matte * blend);
		
	gl_FragColor = vec4(comp, lightwrap_matte );
}