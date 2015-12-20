#version 120
//  based on http://glslsandbox.com/e#29134.0
//inspired by: https://www.shadertoy.com/view/MtX3Ws
//Robert 28.11.2015

uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.1;

vec3 roty(vec3 p,float a)
	{
		return p*mat3(cos(a),0,-sin(a),0,1,0,sin(a),0,cos(a));
	}
 
float map(in vec3 p, vec2 offs) 
{
	float res;
	vec3 c = p;
	for (int i = 0; i < 2; i++) 
	{
		p =0.8*abs(p)/dot(p,p)-offs.y+0.05;
	    p.x *= fract( sin( floor( time ) * 2.0 ) * 99999.0 ) * 2.0;
		p.yz= vec2(p.y*p.y-p.z*p.z,2.*p.y*p.z)*(offs.x+0.1)*4.0;
		res += exp(-25.0 * abs(dot(p,c*30.0)));
	}
	return res;
}
 
vec3 raymarch(vec3 ro, vec3 rd, vec2 offset)
{
	float t = abs(sin(time*.05))+4.0;
	vec3 col=vec3(0.);float c=0.;
	for( int i=0; i< 60; i++ ){
		t+=0.02*exp(-2.0*c);
		c = map(ro+t*rd, offset);               
		col += vec3(c*3.0,c*c*c,c/3.0)/20.0;}    
	return col;
}
 
float rand(vec2 p) 
{
	return fract(sin(dot(p ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 p = gl_FragCoord.xy/resolution.y - 0.5;
	vec3 ro = roty(vec3(3.0),time*0.3);
    vec3 uu = normalize( cross(ro,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ro));
    vec3 rd = normalize( p.x*uu + p.y*vv -ro*0.3 );
	
	vec2 m_offset = vec2(0.0, 0.0);
    //vec3 col = 0.15*log(1.0+raymarch(ro,rd, m_offset));
	vec3 col = vec3(0.0);
	
	time += rand(vec2(time * 0.1));
	
	// switch to random grid patterns 
	int mode = int(fract( sin( floor( 0.6 * time ) * 2.0 ) * 99999.0 ) * 13.0);
	
	// create a demo mode which switch every x seconds to a new mode
	//int mode = int(mod(.6*time,4.));
	
	if (mode==0)
	{
		m_offset = vec2(rand(vec2(time, time *0.9)));
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset));
	}
	else if (mode==1) 
	{
		m_offset = vec2(0.8234, 0.778);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));
	}
	else if (mode==2) 
	{
		m_offset = vec2(0.64, 0.562);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==3) 
	{
		m_offset = vec2(0.745, 0.456);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==4) 
	{
		m_offset = vec2(5.22, 0.19);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==5) 
	{
		m_offset = vec2(0.4, 0.59);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==6) 
	{
		m_offset = vec2(-0.37, 0.97);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==7) 
	{
		m_offset = vec2(-0.55, -0.19);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==8) 
	{
		m_offset = vec2(0.12, 0.61);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==9) 
	{
		m_offset = vec2(0.05, 1.08);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==10) 
	{
		m_offset = vec2(-0.09, 0.69);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==11) 
	{
		m_offset = vec2(-0.13, 0.61);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}
	else if (mode==12) 
	{
		m_offset = vec2(-0.12, 1.32);
	    col = 0.15*log(1.0+raymarch(ro,rd, m_offset ));	
	}



    gl_FragColor.rgb = col.rrr * 1.3;
}

