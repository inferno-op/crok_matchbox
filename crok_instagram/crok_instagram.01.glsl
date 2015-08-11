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
	
		//  Instagram looks
	if ( look == 1 ) 	
	{
		slope = vec3(1.002344, 1.002344, 1.002344);
		offset = vec3(0.177295, 0.102685, 0.124902);
		power = vec3(1.271409, 1.412865, 1.441414);
		sat = 1.0;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 2 ) 	
	{
		slope = vec3(1.027020, 1.019360, 0.997714);
		offset = vec3(-0.012891, 0.139844, 0.139844);
		power = vec3(1.186510, 1.859080, 1.896160);
		sat = 0.600441;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 3 ) 	
	{
		slope = vec3(0.842500, 0.956808, 0.805664);
		offset = vec3(-0.035071, -0.052115, 0.172788);
		power = vec3(0.985901, 1.188610, 2.283580);
		sat = 0.607811;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 4 ) 	
	{
		slope = vec3(1.050910, 0.806908, 0.758130);
		offset = vec3(-0.052488, -0.022408, -0.043116);
		power = vec3(1.294280 , 1.117030, 1.186460);
		sat = 1.019480;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 5 ) 	
	{
		slope = vec3(1.002633, 1.283138, -1.022549);
		offset = vec3(-0.894868, -0.192727, 1.629342);
		power = vec3(0.694179, 1.469600, 0.000000);
		sat = 0.026953;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 6 ) 	
	{
		slope = vec3(1.086620, 1.086620, 1.086620);
		offset = vec3(0.123243, -0.034278, 0.024562);
		power = vec3(1.501950, 1.312590, 2.000000);
		sat = 0.776757;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 7 ) 	
	{
		slope = vec3(-1.956830, 1.401900, 3.810730);
		offset = vec3(0.013761, -0.143172, -21.281799);
		power = vec3(1.497810, 1.277210, 1.985840);
		sat = 0.000000;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 8 ) 	
	{
		slope = vec3(0.723593, 0.715874, 0.6668720);
		offset = vec3(0.094940, 0.141620, 0.097916);
		power = vec3(0.910115, 1.177830, 1.714090);
		sat = 0.754297;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 9 ) 	
	{
		slope = vec3(1.435720, 1.250320, 1.186830);
		offset = vec3(-0.279101, -0.226710, -0.081201);
		power = vec3(1.178660, 0.889618, 1.169710);
		sat = 1.000000;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 10 ) 	
	{
		slope = vec3(0.649603, 0.769153, 0.752337);
		offset = vec3(0.364704, 0.213678, 0.031597);
		power = vec3(1.096905, 1.688936, 1.286792);
		sat = 0.743945;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 11 ) 	
	{
		slope = vec3(1.24203, 0.87111, 0.52847);
		offset = vec3(0.01127, 0.21499, 0.48637);
		power = vec3(1.58391, 1.92828, 2.36919);
		sat = 0.56308;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 12 ) 	
	{
		slope = vec3(0.511196, 0.754472, 1.069880);
		offset = vec3(0.349511, -0.022850, 0.128856);
		power = vec3(0.995112, 1.195600, 1.462390);
		sat = 0.510202;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 13 ) 	
	{
		slope = vec3(1.310010, 1.216570, 1.286590);
		offset = vec3(-0.068845, -0.278657, -0.001999);
		power = vec3(0.507390, 0.963987, 1.188950);
		sat = 0.328368;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 14 ) 	
	{
		slope = vec3(1.077660, 1.197070, 1.15260);
		offset = vec3(-0.087942, -0.051414, 0.026514);
		power = vec3(1.264750, 1.251250, 1.247840);
		sat = 0.547076;
		con = 1.0;
		gam = 1.0;		
		f_con = 0;
	}
	
	if ( look == 15 ) 	
	{
		slope = vec3(1.047730, 1.109550, 1.226080);
		offset = vec3(-0.122850, -0.088573,-0.113134);
		power = vec3(1.214190, 1.361770, 0.992396);
		sat = 1.000000;
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

