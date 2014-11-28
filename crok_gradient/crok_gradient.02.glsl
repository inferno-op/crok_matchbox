#version 120

uniform sampler2D source, adsk_results_pass1;
uniform int LogicOp, direction;

uniform float rot;
//float rot = 50.0;
uniform float adsk_result_w, adsk_result_h, blend;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);


vec3 normal( vec3 s, vec3 d )
{
	return s;
}

vec3 screen( vec3 s, vec3 d )
{
	return s + d - s * d;
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
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

vec3 linearDodge( vec3 s, vec3 d )
{
	return s + d;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
    vec3 img = texture2D(source, uv).rgb;

	// rotate the uv with time		
	float c_uv=cos(rot*0.01),s_uv=sin(rot*0.01);
	uv= (uv - 0.5)*mat2(c_uv,s_uv,-s_uv,c_uv);
	uv= uv + 0.5;

	vec3 d = texture2D(adsk_results_pass1, uv).rgb;
	vec3 c = vec3(0.0);


	

    if ( LogicOp == 0)
		c = d;
    if ( LogicOp == 1)
 	    c =  c + multiply(img,d);
    else if ( LogicOp == 2)
 	   c =  c + linearDodge(img,d);
    else if ( LogicOp == 3)
 	   c =  c +   screen(img,d);
    else if ( LogicOp == 4)
 	   c =  c + overlay(img,d);
	
	c = mix(img, c, blend);
	
	
		
	gl_FragColor = vec4(c, 1.0);
}