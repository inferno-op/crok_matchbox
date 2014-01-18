// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform vec2 paramPos;
uniform float paramSpeed;
uniform bool paramProcedural;
uniform int steps;

uniform float Detail;
uniform float Density;
uniform float Volume;

// Added for Action camera 
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform vec3 camera_position, camera_interest;
uniform float camera_roll, camera_fov;
uniform bool camera_use;

#define pi 3.1415926535897932384624433832795
// end Action camera 

// hash based 3d value noise
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*((Detail+1.0)-Detail*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
           mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
           mix(mix( hash(n+113.0), hash(n+114.0),f.x),
           mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}


vec4 map( in vec3 p )
{
	float d = Volume - p.y;

	vec3 q = p - vec3(1.0,0.1,0.0)*(adsk_time*paramSpeed/1000.0);
	float f;
    f  = 0.5000*noise( q ); q = q*2.02;
    f += 0.2500*noise( q ); q = q*2.03;
    f += 0.1250*noise( q ); q = q*2.01;
    f += 0.0625*noise( q );

	d += Density * f;

	d = clamp( d, 0.0, 1.0 );
	
	vec4 res = vec4( d );

	res.xyz = mix( 1.15*vec3(1.0,0.95,0.8), vec3(0.7,0.7,0.7), res.x );
	
	return res;
}


vec3 sundir = vec3(-1.0,0.0,0.0);


vec4 raymarch( in vec3 ro, in vec3 rd )
{
	vec4 sum = vec4(0, 0, 0, 0);

	float t = 0.0;
	for(int i=0; i<steps; i++)
	{
		if( sum.a > 0.99 ) continue;

		vec3 pos = ro + t*rd;
		vec4 col = map( pos );
		
		#if 1
		float dif =  clamp((col.w - map(pos+0.3*sundir).w)/0.6, 0.0, 1.0 );

        vec3 lin = vec3(0.65,0.68,0.7)*1.35 + 0.45*vec3(0.7, 0.5, 0.3)*dif;
		col.xyz *= lin;
		#endif
		
		col.a *= 0.35;
		col.rgb *= col.a;

		sum = sum + col*(1.0 - sum.a);	

        #if 0
		t += 0.1;
		#else
		t += max(0.1,0.025*t);
		#endif
	}

	sum.xyz /= (0.001+sum.w);

	return clamp( sum, 0.0, 1.0 );
}



// Added for Action camera.  Returns a matrix that rotates about an axis 
mat4 rot(vec3 axis, float angle) {
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;

	return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
	            oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
	            oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
	            0.0,                                0.0,                                0.0,                                1.0);
}

// Added for Action camera
float deg2rad(float angle) {
	return(angle/(180.0/pi));
}
// end Action camera




void main(void)
{
    vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	vec2 q = gl_FragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x/ iResolution.y;
    vec2 mo = -1.0 + 2.0*paramPos.xy;
  	

    // added for Action camera 
   	vec3 ro, rd;
    if(camera_use) {
    	// ok.
    	vec3 camera_position_r = camera_position * vec3(-1.0, 1.0, 1.0);
    	vec3 camera_interest_r = camera_interest * vec3(-1.0, 1.0, 1.0);
    	vec3 camera_direction = camera_interest_r - camera_position_r;
    	camera_direction = normalize(camera_direction);
    	vec3 camera_up = (vec4(0.0, 1.0, 0.0, 0.0) * rot(camera_direction, deg2rad(camera_roll))).xyz;
    	vec3 camera_right = cross(camera_direction, camera_up);
    	camera_up = cross(camera_right, camera_direction);
    	p *= tan(deg2rad(camera_fov/2.0));
    	vec3 image_point = -p.x * camera_right + p.y * camera_up + camera_position_r + camera_direction;
    	rd = normalize(image_point - camera_position_r);
    	ro = camera_position_r;
	 } 
	 // end Action camera
	 else
	 {
    
    // camera
    ro = 4.0*normalize(vec3(cos(2.75-3.0*mo.x), 0.7+(mo.y+1.0), sin(2.75-3.0*mo.x)));
	vec3 ta = vec3(0.0, 1.0, 0.0);
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    rd = normalize( p.x*uu + p.y*vv + 1.5*ww );
	}
	
    vec4 res = raymarch( ro, rd );

	float sun = clamp( dot(sundir,rd), 0.0, 1.0 );
	vec3 col = vec3(0.6,0.71,0.75) - rd.y*0.2*vec3(1.0,0.5,1.0) + 0.15*0.5;
	col += 0.2*vec3(1.0,.6,0.1)*pow( sun, 8.0 );
	col *= 0.95;
	col = mix( col, res.xyz, res.w );
	col += 0.1*vec3(1.0,0.4,0.2)*pow( sun, 3.0 );

    gl_FragColor = vec4( col, 1.0 );
}
