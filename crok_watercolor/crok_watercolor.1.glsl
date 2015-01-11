#version 120
// bubbles
// rakesh@picovico.com : www.picovico.com
// http://glsl.heroku.com/e#15514.0

int bubbles = 100; // = 150;
float Sharpness = 0.70;
uniform float Seed;

uniform float Speed;

float size = 2.0;
float s_offset = 0.5;
float h_offset = -0.5;
float v_offset = 0.0;

vec3 tint = vec3(0.5, 0.0, 0.0);
vec3 t_offset = vec3(1.0, 1.0, 1.0);

uniform float adsk_time;


uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time*.05 * Speed +100.;

const float fRadius = 0.05;

void main(void)
{
	vec2 uv = -1.0 + 2.0*gl_FragCoord.xy / resolution.xy;
	uv.x *=  resolution.x / resolution.y;
	
	vec3 color = vec3(0.0);

    	// bubbles
	for( int i=0; i<bubbles; i++ )
	{
        	// bubble seeds
		float pha = sin(float(i)*5.13+1.0)*0.5 + 0.5;
		float siz = pow( sin(float(i)*1.74+5.0)*0.5+ Seed+3., 4.0 );
		float pox = sin(float(i)*3.55+4.1) * resolution.x / resolution.y;

		
        	// buble size, position and color
		float rad = fRadius + sin(float(i))*0.12*s_offset+0.08*size;
		vec2  pos = vec2( pox+sin(time/30.*h_offset+pha+siz), -1.0-rad + (2.0+2.0*rad)*mod(pha+0.1*(time/5.*v_offset)*(0.2+0.8*size),1.0)) * vec2(1.0, 1.0);
		float dis = length( uv - pos );
		vec3  col = mix( vec3(tint.r, tint.g, tint.b), vec3(t_offset.r,t_offset.g,t_offset.b), 0.5+0.5*sin(float(i)*sin(time*pox*0.03)+1.9));
		
        	// render
		color += col.xyz *(1.- smoothstep( rad*((Sharpness-.02)*sin(pox*time)), rad, dis )) * (1.0 - cos(pox*time));
	}

	gl_FragColor = vec4(color,1.0);
}