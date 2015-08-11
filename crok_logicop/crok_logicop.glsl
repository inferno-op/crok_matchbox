//****************************************************************************/
// 
// Filename: logicOPS_3vis.glsl
// Author: Eric Pouliot
//
// Copyright (c) 2013 3vis, Inc.
//*****************************************************************************/
//	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//	
//	25 of the layer blending modes from Photoshop.
//	
//	The ones I couldn't figure out are from Nvidia's advanced blend equations extension spec -
//	http://www.opengl.org/registry/specs/NV/blend_equation_advanced.txt
//	
//	~bj.2013
//	
uniform sampler2D iChannel0, iChannel1, iChannel2 ;
uniform float adsk_time, adsk_result_w, adsk_result_h, blend;
uniform float Speed;
float time = adsk_time * 0.05;
uniform int LogicOp, Math;
uniform bool clamp_color;

// uniform bool idarken,imultiply,icolorBurn,ilinearBurn,idarkerColor,ilighten,iscreen,icolorDodge,ilinearDodge,ilighterColor,ioverlay,isoftLight,ihardLight,ivividLight,ilinearLight,ipinLight,ihardMix,idifference,iexclusion,isubstract,idivide,ihue,icolor,isaturation,iluminosity;

vec3 normal( vec3 s, vec3 d )
{
	return s;
}

vec3 darken( vec3 s, vec3 d )
{
	return min(s,d);
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
}

vec3 colorBurn( vec3 s, vec3 d )
{
	return 1.0 - (1.0 - d) / s;
}

vec3 linearBurn( vec3 s, vec3 d )
{
	return s + d - 1.0;
}

vec3 darkerColor( vec3 s, vec3 d )
{
	return (s.x + s.y + s.z < d.x + d.y + d.z) ? s : d;
}

vec3 lighten( vec3 s, vec3 d )
{
	return max(s,d);
}

vec3 screen( vec3 s, vec3 d )
{
	return s + d - s * d;
}

vec3 colorDodge( vec3 s, vec3 d )
{
	return d / (1.0 - s);
}

vec3 linearDodge( vec3 s, vec3 d )
{
	return s + d;
}

vec3 lighterColor( vec3 s, vec3 d )
{
	return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
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

float softLight( float s, float d )
{
	return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d) 
		: (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0) 
					 : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}

vec3 softLight( vec3 s, vec3 d )
{
	vec3 c;
	c.x = softLight(s.x,d.x);
	c.y = softLight(s.y,d.y);
	c.z = softLight(s.z,d.z);
	return c;
}

float hardLight( float s, float d )
{
	return (s < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec3 hardLight( vec3 s, vec3 d )
{
	vec3 c;
	c.x = hardLight(s.x,d.x);
	c.y = hardLight(s.y,d.y);
	c.z = hardLight(s.z,d.z);
	return c;
}

float vividLight( float s, float d )
{
	return (s < 0.5) ? 1.0 - (1.0 - d) / (2.0 * s) : d / (2.0 * (1.0 - s));
}

vec3 vividLight( vec3 s, vec3 d )
{
	vec3 c;
	c.x = vividLight(s.x,d.x);
	c.y = vividLight(s.y,d.y);
	c.z = vividLight(s.z,d.z);
	return c;
}

vec3 linearLight( vec3 s, vec3 d )
{
	return 2.0 * s + d - 1.0;
}

float pinLight( float s, float d )
{
	return (2.0 * s - 1.0 > d) ? 2.0 * s - 1.0 : (s < 0.5 * d) ? 2.0 * s : d;
}

vec3 pinLight( vec3 s, vec3 d )
{
	vec3 c;
	c.x = pinLight(s.x,d.x);
	c.y = pinLight(s.y,d.y);
	c.z = pinLight(s.z,d.z);
	return c;
}

vec3 hardMix( vec3 s, vec3 d )
{
	return floor(s + d);
}

vec3 difference( vec3 s, vec3 d )
{
	return abs(d - s);
}

vec3 exclusion( vec3 s, vec3 d )
{
	return s + d - 2.0 * s * d;
}

vec3 subtract( vec3 s, vec3 d )
{
	return s - d;
}

vec3 divide( vec3 s, vec3 d )
{
	return s / d;
}

vec3 spotlightBlend( vec3 s, vec3 d )
{
	return d*s+d;
}

vec3 over( vec3 s, vec3 d, vec3 matte)
{
	vec3 c;
	c = (1.0-matte)*d;
	c = screen(s,c);
	return c;
	
}

//	rgb<-->hsv functions by Sam Hocevar
//	http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hue( vec3 s, vec3 d )
{
	d = rgb2hsv(d);
	d.x = rgb2hsv(s).x;
	return hsv2rgb(d);
}

vec3 color( vec3 s, vec3 d )
{
	s = rgb2hsv(s);
	s.z = rgb2hsv(d).z;
	return hsv2rgb(s);
}

vec3 saturation( vec3 s, vec3 d )
{
	d = rgb2hsv(d);
	d.y = rgb2hsv(s).y;
	return hsv2rgb(d);
}

vec3 luminosity( vec3 s, vec3 d )
{
	float dLum = dot(d, vec3(0.3, 0.59, 0.11));
	float sLum = dot(s, vec3(0.3, 0.59, 0.11));
	float lum = sLum - dLum;
	vec3 c = d + lum;
	float minC = min(min(c.x, c.y), c.z);
	float maxC = max(max(c.x, c.y), c.z);
	if(minC < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - minC);
	else if(maxC > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (maxC - sLum);
	else return c;
}


float Random ( float x )
{
	return fract( sin( ((x) - 1.45) / 0.25 ) * 999. );
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	
	// source texture (upper layer)
	vec3 s = texture2D(iChannel0, uv).xyz;
	
	// destination texture (lower layer)
	vec3 d = texture2D(iChannel1, uv).xyz;
	
	// alpha  texture
    vec3 matte =  vec3( texture2D(iChannel2, uv).rgb);
    
	vec3 original = d;
    float blend_fin = 0.0;
	
	vec3 c = vec3(0.0);
   if( LogicOp ==0)
	   	c =  c +darken(s,d);
   else if ( LogicOp == 1)
	    c =  c + multiply(s,d);
   else if ( LogicOp == 2)
	    c =  c + colorBurn(s,d);
   else if ( LogicOp == 3)
	    c =  c + linearBurn(s,d);
   else if ( LogicOp == 4)
	    c =  c + darkerColor(s,d);
   else if ( LogicOp == 5)
	   c = c;
   else if ( LogicOp == 6)
	   c =  c +  lighten(s,d);
   else if ( LogicOp == 7)
	   c =  c +   screen(s,d);
   else if ( LogicOp == 8)
	   c =  c + colorDodge(s,d);
   else if ( LogicOp == 9)
	   c =  c + linearDodge(s,d);
   else if ( LogicOp == 10)
	   c =  c + lighterColor(s,d);
   else if ( LogicOp == 11)
	   c =  c + overlay(s,d);
   else if ( LogicOp == 12)
	   c =  c + softLight(s,d);
   else if ( LogicOp == 13)
	   c =  c + hardLight(s,d);
   else if ( LogicOp == 14)
	   c =  c + vividLight(s,d);
   else if ( LogicOp == 15)
	   c =  c + linearLight(s,d);
   else if ( LogicOp == 16)
	   c =  c + pinLight(s,d);
   else if ( LogicOp == 17)
	   c =  c + hardMix(s,d);
   else if ( LogicOp == 18)
	   c =  c + difference(s,d);
   else if ( LogicOp == 19)
	   c =  c + exclusion(s,d);
   else if ( LogicOp == 20)
	   c =  c + subtract(s,d);
   else if ( LogicOp == 21)
	   c =  c + divide(s,d);
   else if ( LogicOp == 22)
	   c =  c + hue(s,d);
   else if ( LogicOp == 23)
	   c =  c + saturation(s,d);
   else if ( LogicOp == 24)
	   c =  c + color(s,d);
   else if ( LogicOp == 25)
	   c =  c + luminosity(s,d);
   else if ( LogicOp == 26)
	   c =  c + spotlightBlend(s,d);
   else if ( LogicOp == 27)
	   c =  c + normal(s,d);
   else if ( LogicOp == 28)
	   c =  c + over(s,d, matte);
   
    
   // adding math functions to the blend slider
   if ( Math == 0 )
	   blend_fin = blend;
   else if ( Math == 1 )
	   blend_fin = sin( time * Speed / 0.5 - 1.5 ) * 0.5 + 0.5;
   else if ( Math == 4 )
	   blend_fin = Random( floor (time * Speed));
   else if ( Math == 5 )
	   blend_fin = smoothstep( 0.0, 1.0, fract (time * Speed));
   
   c = mix(original, c, blend_fin * blend);
   
   if ( LogicOp == 28)
	   c = c;
   else
	   c = vec3(matte * c + (1.0 - matte) * original);
	   
   if ( clamp_color )
	   c = clamp(c, 0.0, 1.0);
   
      
	gl_FragColor = vec4(c, matte);
}