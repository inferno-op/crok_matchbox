uniform sampler2D source;
uniform float adsk_result_w, adsk_result_h;
uniform int look;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);

// Algorithm from Chapter 16 of OpenGL Shading Language
vec3 saturation(vec3 rgb, float adjustment)
{
    const vec3 W = vec3(0.2126, 0.7152, 0.0722);
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

vec3 sig (vec3 s) 
{
    return 1.0 / (1.0 + (exp(-(s - 0.5) * 7.0))); 
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec3 org = texture2D(source, uv).rgb;
	vec3 c = org;
	vec3 slope = vec3(1.0);
	vec3 offset = vec3(0.0);
	vec3 power = vec3(1.0);
	float sat = 1.0;
	float con = 1.0;
	float gam = 1.0;
	int f_con = 0;
	
	if ( look == 1 ) 	
	{
		slope = vec3(1.01, 1.0, 1.0);
		offset = vec3(0.0);
		power = vec3(0.95, 1.0, 1.00);
		sat = 1.2;
		con = 1.0;
		gam = 1.0;		
		f_con = 1;
	}
	
	if ( look == 2 ) 	
	{
		slope = vec3(1.08, 1.19, 1.07);
		offset = vec3(0.04, -0.06, 0.02);
		power = vec3(1.07, 1.11, 1.20);
		sat = 1.0;
		con = 1.0;
		gam = 1.0;		
		f_con = 1;
	}
	
	if ( look == 3 ) 	
	{
		slope = vec3(0.98, 1.0, 1.03);
		offset = vec3(0.0);
		power = vec3(0.84, 0.97, 1.10);
		sat = 1.0;
		con = 1.0;
		gam = 1.0;
		f_con = 1;
	}
	
	if ( look == 4 ) 	
	{
		slope = vec3(1.12, 1.42, 1.19);
		offset = vec3(0.04, -0.06, 0.02);
		power = vec3(0.94, 0.81, 0.83);
		sat = 0.7;
		con = 1.06;
		gam = 1.0;		
		f_con = 1;
	}
	
	if ( look == 5 ) 	
	{
		slope = vec3(1.0);
		offset = vec3(-0.05, -0.04, -0.03);
		power = vec3(1.0);
		sat = 0.0;
		con = 1.33;
		gam = 0.6;
		f_con = 0;
	}
	if ( look == 6 ) 	
	{
		slope = vec3(1.33, 1.01, 0.63);
		offset = vec3(0.0);
		power = vec3(1.21, 0.96, 0.74);
		sat = 0.6;
		con = 1.0;
		gam = 0.83;
		f_con = 1;
	}
	
	if ( look == 7 ) 	
	{
		slope = vec3(0.88, 0.96, 1.24);
		offset = vec3(0.0);
		power = vec3(1.45, 1.29, 1.27);
		sat = 1.0;
		con = 0.93;
		gam = 0.9;
		f_con = 1;
	}
	
	if ( look == 8 ) 	
	{
		slope = vec3(1.2, 1.2, 1.2);
		offset = vec3(0.0);
		power = vec3(1.3, 1.3, 1.3);
		sat = 0.0;
		con = 0.8;
		gam = 1.2;
		f_con = 1;
	}
	
	if ( look == 9 ) 	
	{
		slope = vec3(0.93, 0.94, 0.96);
		offset = vec3(0.0);
		power = vec3(1.6, 1.1, 0.95);
		sat = 0.4;
		con = 1.1;
		gam = 0.7;
		f_con = 1;
	}
	
	if ( look == 11 ) 	
	{
		slope = vec3(0.65, 1.0, 0.8);
		offset = vec3(0.07, 0.0, 0.08);
		power = vec3(1.0);
		sat = 1.4;
		con = 1.0;
		gam = 1.0;
		f_con = 1;		
	}
		
	if ( look == 12 ) 	
	{
		slope = vec3(1.19, 1.1, 0.77);
		offset = vec3(-0.04, -0.08, -0.07);
		power = vec3(0.8);
		sat = 0.9;
		con = 1.0;
		gam = 0.9;
		f_con = 1;		
	}
	if ( look == 13 ) 	
	{
		slope = vec3(1.1, 1.0, 0.8);
		offset = vec3(0.0);
		power = vec3(1.5, 1.0, 1.0);
		sat = 0.6;
		con = 1.0;
		gam = 0.9;
		f_con = 1;
				
	}
	if ( look == 14 ) 	
	{
		slope = vec3(1.15, 1.11, 0.86);
		offset = vec3(0.0, 0.01, -0.02);
		power = vec3(1.41, 1.0, 0.74);
		sat = 0.45;
		con = 0.98;
		gam = 0.86;
		f_con = 1;
	}
	if ( look == 15 ) 	
	{
		slope = vec3(1.0);
		offset = vec3(0.0);
		power = vec3(1.0);
		sat = 0.0;
		con = 1.1;
		gam = 0.7;
		f_con = 1;
	}
	
	if ( look == 16 ) 	
	{
		slope = vec3(1.02, 1.32, 1.09);
		offset = vec3(0.04, -0.06, 0.02);
		power = vec3(0.70, 0.44, 0.51);
		sat = 0.8;
		con = 1.00;
		gam = 1.30;		
		f_con = 1;
	}
	
	if ( look == 17 ) 	
	{
		slope = vec3(1.297496, 0.943091, 0.501793);
		offset = vec3(-0.132450, 0.036699, 0.147457);
		power = vec3(1.180667, 1.032265, 1.215274);
		sat = 1.0;
		con = 1.00;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 18 ) 	
	{
		slope = vec3(1.616452, 1.331932, 0.842867);
		offset = vec3(-0.152205, 0.079621, 0.197558);
		power = vec3(1.650251, 1.536614, 1.553357);
		sat = 0.7;
		con = 1.0;
		gam = 1.1;		
		f_con = 0;
	}
	
	if ( look == 19 ) 	
	{
		slope = vec3(1.671897, 1.274243, 0.994490);
		offset = vec3(-0.052148, -0.026815, 0.483182);
		power = vec3(1.650251, 1.536614, 1.553357);
		sat = 0.282609;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	//apply gamma correction 
	c = pow(c, vec3(gam));
	// apply CDL values
	c = pow(clamp(((c * slope) + offset), 0.0, 1.0), power);
	// apply saturation
	c = saturation(c, (sat));
	// apply contrast
	c = contrast(c, vec4(con));
	
	//apply film contrast
	if ( f_con == 0 )
		c;
	else
		c = vec3(sig(c));

	c = clamp(c, 0.0, 1.0);

    gl_FragColor = vec4(c, 1.0);
}

