uniform sampler2D source, matte;
 
uniform float adsk_time, zoom, adsk_result_frameratio, rotation;
uniform float overall_seed, overall_frq, overall_amp, pos_frq, pos_amp_x, pos_amp_y, add_noise_frq, add_noise_amp_x, add_noise_amp_y, zoom_amp, zoom_frq, rot_frq, rot_amp, moblur_samples, moblur_shutter;
uniform float additional_rot_frq, additional_rot_amp, additional_zoom_amp, additional_zoom_frq, additional_overall_amp, additional_overall_frq;
uniform vec2 off_pos;

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform bool enbl_zoom, enbl_position, enbl_rotation, enbl_moblur, enbl_add_pos_noise, enbl_add_rot_noise, enbl_add_zoom_noise;
 
 
// Using Ashima's simplex noise
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
 
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}
 
float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,
                      0.366025403784439,
                     -0.577350269189626,
                      0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
 
  vec2 i1;

  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
 
  i = mod289(i);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));
 
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
 
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
 
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
 
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
 
 
float hash( float n ) {
    return fract(sin(n)*687.3123);
}
 
float noise( in vec2 x ) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0;
    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}
 
const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );
 
float fbm( vec2 p ) {
    float f = 0.0;
    f += 0.5000*noise( p ); p = m2*p*2.02;
    f += 0.2500*noise( p ); p = m2*p*2.03;
    f += 0.1250*noise( p ); p = m2*p*2.01;
	f += 0.0625*noise( p );
    
    return f/0.9375;
}
 
 
void main()
{
	vec3 col = vec3(0.0);
	float mat = 0.0;

	float time = adsk_time * 0.2 * overall_frq;
	vec2 uv = ((gl_FragCoord.xy / resolution.xy) + 0.5) - off_pos;
	vec2 off_center;
	vec2 center; 

	if ( enbl_position )
	{
		// random x y
		off_center.x = fbm(vec2((time + 34414. + overall_seed) * pos_frq * 0.1, (time + 123515. + overall_seed) * pos_frq * 0.1)) * pos_amp_x * .3 * overall_amp;
		off_center.y = fbm(vec2((time + 54635. + overall_seed) * pos_frq * 0.1, (time + 545. + overall_seed) * pos_frq * 0.1)) * pos_amp_y * .3 * overall_amp;
		
		
		if ( enbl_add_pos_noise )
		{
			float additional_n_frq = add_noise_frq * 0.1;
			float additional_n_amp_x = add_noise_amp_x * 0.05;
			float additional_n_amp_y = add_noise_amp_y * 0.05;
			off_center.x += fbm(vec2((time + 974657. + overall_seed) * additional_n_frq, (time + 74563. + overall_seed) * additional_n_frq * additional_overall_frq)) * additional_n_amp_x * additional_overall_amp * overall_amp;
			off_center.y += fbm(vec2((time + 345623. + overall_seed) * additional_n_frq, (time + 73562. + overall_seed) * additional_n_frq * additional_overall_frq)) * additional_n_amp_y * additional_overall_amp * overall_amp;
		}

		
		
		center.x = pos_amp_x * .3 * overall_amp / 2.0;
		center.y = pos_amp_y * .3 * overall_amp / 2.0;
		
		uv.x += center.x - off_center.x;
		uv.y += center.y - off_center.y;
		

		
	}

	if ( enbl_rotation )
	{
		float rnd = 0.0;
	 	// random rotation 
		rnd = fbm(vec2((time + 5678. + overall_seed) * rot_frq * .1 )) * rot_amp * .05 * overall_amp;
		
		if (enbl_add_rot_noise )
			rnd += fbm(vec2((time + 3542. + overall_seed) * additional_rot_frq * additional_overall_frq)) * additional_rot_amp * .01 * additional_overall_amp * overall_amp;
				
		float rot_cent = rot_amp * .05 * overall_amp / 2.0;
 	    mat2 rot = mat2( cos(-rotation + rnd - rot_cent), -sin(-rotation + rnd - rot_cent), sin(-rotation + rnd - rot_cent), cos(-rotation + rnd - rot_cent));
	    uv -= vec2(0.5);
	    uv.x *= adsk_result_frameratio;
	    uv *= rot;
		uv.x /= adsk_result_frameratio;
	    uv += vec2(0.5);
	}

	if ( enbl_zoom )
	{
		// random Zoom
		uv -= vec2(0.5);
		uv *= 1.0 - fbm(vec2((time + 24234. + overall_seed) * zoom_frq * .1 )) * zoom_amp * .05 * overall_amp;
		
		if ( enbl_add_zoom_noise )
			uv *= 1.0 - fbm(vec2((time + 9135. + overall_seed) * additional_zoom_frq * .5 * additional_overall_frq)) * additional_zoom_amp *.03 * additional_overall_amp * overall_amp;
			
		uv += vec2(0.5);
	}


	// offset rotation
	mat2 r = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation));
    uv -= vec2(0.5);
	uv.x *= adsk_result_frameratio;
	uv *= r;
	uv.x /= adsk_result_frameratio;
	uv += vec2(0.5);
	
	// offset zoom
	uv -= vec2(0.5);
	uv *= zoom;
	uv += vec2(0.5);
	
	col += texture2D(source, uv).rgb;
	mat += texture2D(matte, uv).r;

	
	if (enbl_moblur)
	{
	 	for(float mytime = adsk_time-moblur_shutter/2.0; mytime < adsk_time+moblur_shutter/2.0; mytime += moblur_shutter/moblur_samples)
		{
			float time = mytime * 0.2 * overall_frq;
			vec2 uv = ((gl_FragCoord.xy / resolution.xy) + 0.5) - off_pos;
 
			if ( enbl_position )
			{
				// random x y
				off_center.x = fbm(vec2((time + 34414. + overall_seed) * pos_frq * 0.1, (time + 123515. + overall_seed) * pos_frq * 0.1)) * pos_amp_x * .3 * overall_amp;
				off_center.y = fbm(vec2((time + 54635. + overall_seed) * pos_frq * 0.1, (time + 545. + overall_seed) * pos_frq * 0.1)) * pos_amp_y * .3 * overall_amp;
		
		
				if ( enbl_add_pos_noise )
				{
					float additional_n_frq = add_noise_frq * 0.1;
					float additional_n_amp_x = add_noise_amp_x * 0.05;
					float additional_n_amp_y = add_noise_amp_y * 0.05;
					off_center.x += fbm(vec2((time + 974657. + overall_seed) * additional_n_frq, (time + 74563. + overall_seed) * additional_n_frq * additional_overall_frq)) * additional_n_amp_x * additional_overall_amp * overall_amp;
					off_center.y += fbm(vec2((time + 345623. + overall_seed) * additional_n_frq, (time + 73562. + overall_seed) * additional_n_frq * additional_overall_frq)) * additional_n_amp_y * additional_overall_amp * overall_amp;
				}

		
		
				center.x = pos_amp_x * .3 * overall_amp / 2.0;
				center.y = pos_amp_y * .3 * overall_amp / 2.0;
		
				uv.x += center.x - off_center.x;
				uv.y += center.y - off_center.y;
		

		
			}

			if ( enbl_rotation )
			{
				float rnd = 0.0;
			 	// random rotation 
				rnd = fbm(vec2((time + 5678. + overall_seed) * rot_frq * .1 )) * rot_amp * .05 * overall_amp;
		
				if (enbl_add_rot_noise )
					rnd += fbm(vec2((time + 3542. + overall_seed) * additional_rot_frq * additional_overall_frq)) * additional_rot_amp * .01 * additional_overall_amp * overall_amp;
				
				float rot_cent = rot_amp * .05 * overall_amp / 2.0;
		 	    mat2 rot = mat2( cos(-rotation + rnd - rot_cent), -sin(-rotation + rnd - rot_cent), sin(-rotation + rnd - rot_cent), cos(-rotation + rnd - rot_cent));
			    uv -= vec2(0.5);
			    uv.x *= adsk_result_frameratio;
			    uv *= rot;
				uv.x /= adsk_result_frameratio;
			    uv += vec2(0.5);
			}

			if ( enbl_zoom )
			{
				// random Zoom
				uv -= vec2(0.5);
				uv *= 1.0 - fbm(vec2((time + 24234. + overall_seed) * zoom_frq * .1 )) * zoom_amp * .05 * overall_amp;
		
				if ( enbl_add_zoom_noise )
					uv *= 1.0 - fbm(vec2((time + 9135. + overall_seed) * additional_zoom_frq * .5 * additional_overall_frq)) * additional_zoom_amp *.03 * additional_overall_amp * overall_amp;
			
				uv += vec2(0.5);
			}


			// offset rotation
			mat2 r = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation));
		    uv -= vec2(0.5);
			uv.x *= adsk_result_frameratio;
			uv *= r;
			uv.x /= adsk_result_frameratio;
			uv += vec2(0.5);
	
			// offset zoom
			uv -= vec2(0.5);
			uv *= zoom;
			uv += vec2(0.5);
	
			col += texture2D(source, uv).rgb;
			mat += texture2D(matte, uv).r;
		}

		col /= moblur_samples + 1.;
		mat /= moblur_samples + 1.;
	}
	

	gl_FragColor = vec4(col, mat);
}