uniform sampler2D source;
uniform float adsk_result_w, adsk_result_h;
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
		slope = vec3(1.05, 1.05, 0.95);
		offset = vec3(0.0);
		power = vec3(0.76, 0.99, 1.31);
		sat = 0.0;
		con = 0.95;
		gam = 0.9;		
		f_con = 1;
	}
	
	if ( look == 5 ) 	
	{
		slope = vec3(0.6, 1.0, 0.7);
		offset = vec3(0.07, 0.0, 0.08);
		power = vec3(1.0);
		sat = 1.5;
		con = 1.0;
		gam = 1.0;
		f_con = 1;		
	}
		
	if ( look == 6 ) 	
	{
		slope = vec3(1.19, 1.1, 0.77);
		offset = vec3(-0.04, -0.08, -0.07);
		power = vec3(0.8);
		sat = 0.8;
		con = 1.0;
		gam = 0.9;
		f_con = 1;		
	}
	if ( look == 7 ) 	
	{
		slope = vec3(1.1, 1.0, 0.8);
		offset = vec3(0.0);
		power = vec3(1.5, 1.0, 1.0);
		sat = 0.6;
		con = 1.0;
		gam = 0.9;
		f_con = 1;
				
	}
	if ( look == 8 ) 	
	{
		slope = vec3(1.12, 1.0, 0.79);
		offset = vec3(0.0);
		power = vec3(1.41, 1.0, 0.80);
		sat = 0.5;
		con = 1.0;
		gam = 0.76;
		f_con = 1;
	}
	if ( look == 9 ) 	
	{
		slope = vec3(1.0);
		offset = vec3(0.0);
		power = vec3(1.0);
		sat = 0.0;
		con = 1.1;
		gam = 0.7;
		f_con = 1;
	}
	
	//apply gamma correction 
	c = pow(c, vec3(gam));
	// apply saturation
	c = saturation(c, (sat));
	// apply CDL values
	c = pow(((c * slope) + offset), power);
	// apply contrast
	c = contrast(c, vec4(con));
	//apply film contrast
	if ( f_con == 0 )
		c;
	else
		c = vec3(sig(c));
	
    gl_FragColor = vec4(c, 1.0);
}