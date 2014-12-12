uniform sampler2D source;
 
uniform float adsk_time, zoom, adsk_result_frameratio, rotation;
uniform float overall_seed, overall_frq, overall_amp, pos_frq, pos_amp_x, pos_amp_y, pos_seed, zoom_amp, zoom_frq, zoom_seed, rot_frq, rot_amp, rot_seed, moblur_samples, moblur_shutter;
 
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
 
uniform bool enbl_zoom, enbl_position, enbl_rotation, enbl_moblur;
 
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
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
 
// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
 
// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));
 
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
 
// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
 
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
 
// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
 
// Compute final noise value at P
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

	float time = adsk_time * 0.2 * overall_frq;
	vec2 uv = (gl_FragCoord.xy / resolution.xy);
	vec2 off_center;
	vec2 center; 

	if ( enbl_position )
	{
		// random x y
		off_center.x = fbm(vec2((time + 34414. + pos_seed) * pos_frq * 0.1, (time + 123515. + overall_seed) * pos_frq * 0.1)) * pos_amp_x * .3 * overall_amp;
		off_center.y = fbm(vec2((time + 54635. + pos_seed) * pos_frq * 0.1, (time + 545. + overall_seed) * pos_frq * 0.1)) * pos_amp_y * .3 * overall_amp;
		
		center.x = pos_amp_x * .3 * overall_amp / 2.0;
		center.y = pos_amp_y * .3 * overall_amp / 2.0;
		
		uv.x += center.x - off_center.x;
		uv.y += center.y - off_center.y;
	}

	if ( enbl_rotation )
	{
	 	// random rotation 
		float rnd = fbm(vec2((time + 3542. + overall_seed) * rot_frq * .1 )) * rot_amp * .05 * overall_amp;
		float rot_cent = rot_amp * .05 * overall_amp / 2.0;
 	    mat2 rot = mat2( cos(-rotation + rnd - rot_cent), -sin(-rotation + rnd - rot_cent), sin(-rotation + rnd - rot_cent), cos(-rotation + rnd - rot_cent));
	    //We remove 0.5 from the coords to apply the rotation.
	    uv -= vec2(0.5);
	    //We multiply the X value by the frame ratio before applying the rotation.
	    uv.x *= adsk_result_frameratio;
	    //We apply the rotation
	    uv *= rot;
		//We divide the X value by the frame ratio after applying the rotation.
		uv.x /= adsk_result_frameratio;
	    //We add the 0.5 we substracted back to the coords before applying the rotation.
	    uv += vec2(0.5);
	}



	if ( enbl_zoom )
	{
		// random Zoom
		uv -= vec2(0.5);
		uv *= 1.0 - fbm(vec2((time + 24234. + overall_seed) * zoom_frq * .1 )) * zoom_amp * .05 * overall_amp;
		uv += vec2(0.5);
	}

	// overall zoom
	uv -= vec2(0.5);
	uv *= zoom;
	uv += vec2(0.5);

	col += texture2D(source, uv).rgb;

	
	if (enbl_moblur)
	{
	 	for(float mytime = adsk_time-moblur_shutter/2.0; mytime < adsk_time+moblur_shutter/2.0; mytime += moblur_shutter/moblur_samples)
		{
			float time = mytime * 0.05 * overall_frq;
			vec2 uv = (gl_FragCoord.xy / resolution.xy);
 
			if ( enbl_position )
			{
				// random x y
				off_center.x = fbm(vec2((time + 34414. + overall_seed) * pos_frq * 0.1, (time + 123515. + pos_seed) * pos_frq * 0.1)) * pos_amp_x *.3 * overall_amp;
				off_center.y = fbm(vec2((time + 54635. + overall_seed) * pos_frq * 0.1, (time + 545. + pos_seed) * pos_frq * 0.1)) * pos_amp_y * .3 * overall_amp;
		
				center.x = pos_amp_x * .3 * overall_amp / 2.0;
				center.y = pos_amp_y * .3 * overall_amp / 2.0;
		
				uv.x += center.x - off_center.x;
				uv.y += center.y - off_center.y;
			}
 
			if ( enbl_rotation )
			{
			 	// random rotation 
				float rnd = fbm(vec2((time + 3542. + overall_seed) * rot_frq * .1 )) * rot_amp * .05 * overall_amp;
				float rot_cent = rot_amp * .05 * overall_amp / 2.0;
		 	    mat2 rot = mat2( cos(-rotation + rnd - rot_cent), -sin(-rotation + rnd - rot_cent), sin(-rotation + rnd - rot_cent), cos(-rotation + rnd - rot_cent));
			    //We remove 0.5 from the coords to apply the rotation.
			    uv -= vec2(0.5);
			    //We multiply the X value by the frame ratio before applying the rotation.
			    uv.x *= adsk_result_frameratio;
			    //We apply the rotation
			    uv *= rot;
				//We divide the X value by the frame ratio after applying the rotation.
				uv.x /= adsk_result_frameratio;
			    //We add the 0.5 we substracted back to the coords before applying the rotation.
			    uv += vec2(0.5);
			}
					
			if ( enbl_zoom )
			{
				// random Zoom
				uv -= vec2(0.5);
				uv *= 1.0 - fbm(vec2((time + 24234. + overall_seed) * zoom_frq * .1 )) * zoom_amp * .05 * overall_amp;
				uv += vec2(0.5);
			}
		
			// overall zoom
			uv -= vec2(0.5);
			uv *= zoom;
			uv += vec2(0.5);
		
			col += texture2D(source, uv).rgb;
		}

		col /= moblur_samples;
	}
	

 
	gl_FragColor.rgb = col;
}