#version 120

// based on https://www.shadertoy.com/view/XlsGRs
// srtuss, 2015

// volumetric cloud tunnel, a single light source, lightning and something that is supposed
// to look like raindrops. :)
// visuals are inspired by a piece of music, 2d-texture based 3d noise function by iq.
// the code could need some cleaning, but i don't want to do that right now.

uniform sampler2D iChannel0;
uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float speed, rot, glow, noise, size, bias, smoothness, gain, p1, p2;
uniform float moblur_samples, moblur_shutter;
uniform int branches;
uniform vec2 center;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform bool out_gamma;
uniform bool enbl_moblur;

float time = adsk_time * 0.05 + 0.69;

#define pi 3.1415926535897932384626433832795

struct ITSC
{
	vec3 p;
	float dist;
	vec3 n;
    vec2 uv;
};

vec3 p = vec3(0.0);
float dist = 0.0;
vec3 n = vec3(0.0);
vec2 uv = vec2(0.0);




void tPlane(inout ITSC hit, vec3 ro, vec3 rd, vec3 o, vec3 n, vec3 tg, vec2 si)
{
    vec2 uv = vec2(0.0);
    ro -= o;
    float t = -dot(ro, n) / dot(rd, n);
    if(t < 0.0)
        return;
    vec3 its = ro + rd * t;
    uv.x = dot(its, tg);
    uv.y = dot(its, cross(tg, n));
    if(abs(uv.x) > si.x || abs(uv.y) > si.y)
        return;
    
    {
        hit.dist = t;
        hit.uv = uv;
    }
    return;
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

  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  i = mod289(i); // Avoid truncation effects in permutation
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

vec2 rotate(vec2 p, float a)
{
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

float hash1(float p)
{
	return fract(sin(p * 172.435) * 29572.683) - 0.5;
}

float ns(float p)
{
	float fr = fract(p);
	float fl = floor(p);
	return mix(hash1(fl), hash1(fl + 1.0), fr);
}

float fbm(float p)
{
	return (ns(p) * 0.4 + ns(p * 2.0 - 10.0) * 0.125 + ns(p * 8.0 + 10.0) * 0.025);
}

float fbmd(float p)
{
	float h = 0.01;
	return atan(fbm(p + h) - fbm(p - h), h);
}

float arcsmp(float x, float seed)
{
	return fbm(x * noise + seed * 1111.111)  * (1.0 - exp(-x * 5.0));
}

float arc(vec2 p, float seed, float len)
{
	p *= len;
	float v = abs(p.y - arcsmp(p.x, seed));
	v += exp((2.0 - p.x) * -6.0);
	v = exp(v * -60. * (-gain +5.0)) + exp(v * -10.0) * glow * .1;
	v *= smoothstep(0.0, 0.05, p.x);
	return v;
}

float arcc(vec2 p, float sd)
{
	float v = 0.0;
	float rnd = fract(sd);
	float sp = 0.0;
	v += arc(p, sd, 1.0);
	for(int i = 0; i < branches - 1; i ++)
	{
		sp = rnd + 0.01;
		vec2 mrk = vec2(sp, arcsmp(sp, sd));
		v += arc(rotate(p - mrk, fbmd(sp)), mrk.x, mrk.x * 0.4 + 1.5);
		rnd = fract(sin(rnd * 195.2837) * 1720.938);
	}
	return v;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - center;
    uv.x *= resolution.x / resolution.y;
    
    vec3 ro = vec3(0.0);
    vec3 rd = normalize(vec3(uv, 1.2));
    vec3 col = vec3(0.0);
    vec4 rnd = vec4(0.1, 0.2, 0.3, 0.4);
 
    float arcv = 0.0;
	float arclight = 0.0;
    float v = 0.0;
    rnd = fract(sin(rnd * 1.111111) * 298729.258972);
    float ts = rnd.z * 1.61803398875 + 1.0;
    float arcfl = ts * rot;
        
    ITSC arcits;
    arcits.dist = 1e38;
    float arcz = ro.z + 1.0 + rnd.x / size;
    tPlane(arcits, ro, rd, vec3(0.0, 0.0, arcz), vec3(0.0, 0.0, -1.0), vec3(cos(arcfl), sin(arcfl), 0.0), vec2(2.0));
	
	vec3 arccol = vec3(0.9, 0.7, 0.7);
	
	if (enbl_moblur)
	{
	 	for(float mytime = time-moblur_shutter /2.0; mytime < time+moblur_shutter /2.0; mytime += moblur_shutter /moblur_samples)
		{
		    float arcseed = floor(mytime * 12.0 * speed + rnd.y);
		    if(arcits.dist < 20.0)
		        {
		            arcits.uv *= 0.8;
		            v = arcc(vec2(arcits.uv.x, arcits.uv.y * sign(arcits.uv.x)) * 1.4, arcseed * 0.0003333 / -smoothness);
		        }
			    arcv += v;
		}

		arcv /= moblur_samples;
	}
	
	else
	{
	    float arcseed = floor(time * 12.0 * speed + rnd.y);
		if(arcits.dist < 20.0)
		{
            arcits.uv *= 0.8;
            // 2 bolts from the center 
			//v = arcc(vec2(abs(arcits.uv.x), arcits.uv.y * sign(arcits.uv.x)) * 1.4, arcseed * 0.0033333);
            v = arcc(vec2(arcits.uv.x, arcits.uv.y * sign(arcits.uv.x)) * 1.4, arcseed * 0.0003333 / -smoothness);
			
        }
    arcv += v;
	}

    col = mix(col, arccol, clamp(arcv, 0.0, 1.0));
    col = pow(col, vec3(1.0, 0.8, 0.5) * 1.5) * 1.5;
	
    float blend = snoise(vec2(adsk_time * 200.));
    blend = clamp((blend-(1.0-bias))*9.0, 0.0, 1.0);
	col = mix(vec3(0.0), col, blend);

	if ( out_gamma )
	{
		col = pow(col, vec3(2.2));
	}
	
	gl_FragColor = vec4(col, 1.0);
}