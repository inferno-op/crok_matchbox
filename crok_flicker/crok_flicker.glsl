uniform sampler2D source;
 
uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform float zoom, overall_seed, overall_frq, overall_amp;
uniform float bri_seed, bri_amp, bri_frq, bri_offset;
uniform float sat_seed, sat_amp, sat_frq, sat_offset;
uniform float con_seed, con_amp, con_frq, con_offset;
uniform bool enable_bri, enable_sat, enable_con;
	
vec2 resolution = vec2(adsk_result_w, adsk_result_h);


vec3 saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

// contrast adjustments by  Miles
vec3 adjust_contrast(vec3 col, vec4 con)
{
	vec3 c = con.rgb * vec3(con.a);
	vec3 t = (vec3(1.0) - c) / vec3(2.0);
	t = vec3(.18);
	col = (1.0 - c.rgb) * t + c.rgb * col;
return col;
}

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
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 col = texture2D(source, uv).rgb;

	float time = adsk_time * 0.2 * overall_frq;


	if ( enable_bri )
	{
		// overall brightness change
		float bri_change = fbm(vec2((time + bri_seed + overall_seed) * bri_frq * .1 ));
		bri_change = mix( -bri_amp * .1 * overall_amp, bri_amp * .1 * overall_amp, bri_change );
		col = col + bri_change + bri_offset;
	}

	if ( enable_sat )
	{
		// overall saturation change
		float sat_change = fbm(vec2((time + sat_seed + overall_seed) * sat_frq * .1 ));
		sat_change = mix( 0.0, sat_amp * overall_amp, sat_change );
		sat_change += sat_offset;
		
		col = saturation(col, max(sat_change, 0.0));
		
	}
	
	if ( enable_con )
	{
		// overall contrast change
		float con_change = fbm(vec2((time + con_seed + overall_seed) * con_frq * .1 ));
		con_change = mix( 0.0, con_amp * overall_amp, con_change );
		con_change = max(con_change, 0.0);
		con_change += con_offset;
		col = adjust_contrast(col, vec4(vec3(con_change), 1.0));
	}


	gl_FragColor.rgb = col;
}