#version 120
//
// PUBLIC DOMAIN CRT STYLED SCAN-LINE SHADER
//
//   by Timothy Lottes
//
// This is more along the style of a really good CGA arcade monitor.
// With RGB inputs instead of NTSC.
// The shadow mask example has the mask rotated 90 degrees for less chromatic aberration.
//
// Left it unoptimized to show the theory behind the algorithm.
//
// It is an example what I personally would want as a display option for pixel art games.
// Please take and use, change, or whatever.
//
// based on on https://www.shadertoy.com/view/ltB3zK


uniform sampler2D adsk_results_pass4; 
uniform float adsk_result_w, adsk_result_h, adsk_time, offset;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

float time = adsk_time *.05;
uniform bool no_crt_masking;

// Emulated input resolution.
vec2 res = vec2(480., 320.0);

// Hardness of scanline.
//  -8.0 = soft
// -16.0 = medium
float hardScan = 10; // -12.0

// Hardness of pixels in scanline.
// -2.0 = soft
// -4.0 = hard
float hardPix = 2.0; // -10.0

// Hardness of short vertical bloom.
//  -1.0 = wide to the point of clipping (bad)
//  -1.5 = wide
//  -4.0 = not very wide at all
float hardBloomScan = 1.0; // -2.0

// Hardness of short horizontal bloom.
//  -0.5 = wide to the point of clipping (bad)
//  -1.0 = wide
//  -2.0 = not very wide at all
float hardBloomPix = 1.0; // -1.5

// Amount of small bloom effect.
//  1.0/1.0 = only bloom
//  1.0/16.0 = what I think is a good amount of small bloom
//  0.0     = no bloom
float bloomAmount = 0.5; // 1.0/16.0

// Amount of shadow mask.
float maskDark = 0.8; // 0.8
float maskLight = 1.2; // 1.2

// Display warp.
// 0.0 = none
// 1.0/8.0 = extreme
vec2 warp = vec2(1.0/8.0,1.0/8.0); //vec2(1.0/8.0,1.0/8.0); 

// Falloff shape.
// 1.0  = exp(x)
// 1.25 = in between
// 2.0  = gaussian
// 3.0  = more square
float shape = 3.0; // 3.0;

int mask_style = 2;



//------------------------------------------------------------------------

// sRGB to Linear.
// Assuing using sRGB typed textures this should not be needed.
float ToLinear1(float c){return(c<=0.04045)?c/12.92:pow((c+0.055)/1.055,2.4);}
vec3 ToLinear(vec3 c){return vec3(ToLinear1(c.r),ToLinear1(c.g),ToLinear1(c.b));}

// Linear to sRGB.
// Assuing using sRGB typed textures this should not be needed.
float ToSrgb1(float c){return(c<0.0031308?c*12.92:1.055*pow(c,0.41666)-0.055);}
vec3 ToSrgb(vec3 c){return vec3(ToSrgb1(c.r),ToSrgb1(c.g),ToSrgb1(c.b));}

// Nearest emulated sample given floating point position and texel offset.
// Also zero's off screen.
const vec3 black = vec3(0.0,0.0,0.0);
vec3 Fetch(vec2 pos,vec2 off){
  pos=floor(pos*res+off)/res;
  if(max(abs(pos.x-0.5),abs(pos.y-0.5))>0.5)return black;
  return ToLinear(texture2D(adsk_results_pass4,pos.xy,-16.0).rgb);}

// Distance in emulated pixels to nearest texel.
vec2 Dist(vec2 pos) {return -(fract(pos*res)-vec2(0.5));}
    
// Try different filter kernels.
float Gaus(float pos,float scale){return exp2(scale*pow(abs(pos),shape));}

// 3-tap Gaussian filter along horz line.
vec3 Horz3(vec2 pos,float off){
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix * -1.0;
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  // Return filtered sample.
  return (b*wb+c*wc+d*wd)/(wb+wc+wd);}

// 5-tap Gaussian filter along horz line.
vec3 Horz5(vec2 pos,float off){
  vec3 a=Fetch(pos,vec2(-2.0,off));
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  vec3 e=Fetch(pos,vec2( 2.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix * -1.0;
  float wa=Gaus(dst-2.0,scale);
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  float we=Gaus(dst+2.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we)/(wa+wb+wc+wd+we);}

// 7-tap Gaussian filter along horz line.
vec3 Horz7(vec2 pos,float off){
  vec3 a=Fetch(pos,vec2(-3.0,off));
  vec3 b=Fetch(pos,vec2(-2.0,off));
  vec3 c=Fetch(pos,vec2(-1.0,off));
  vec3 d=Fetch(pos,vec2( 0.0,off));
  vec3 e=Fetch(pos,vec2( 1.0,off));
  vec3 f=Fetch(pos,vec2( 2.0,off));
  vec3 g=Fetch(pos,vec2( 3.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=(2.0 - hardBloomPix) * -1.0;
  float wa=Gaus(dst-3.0,scale);
  float wb=Gaus(dst-2.0,scale);
  float wc=Gaus(dst-1.0,scale);
  float wd=Gaus(dst+0.0,scale);
  float we=Gaus(dst+1.0,scale);
  float wf=Gaus(dst+2.0,scale);
  float wg=Gaus(dst+3.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we+f*wf+g*wg)/(wa+wb+wc+wd+we+wf+wg);}

// 5-tap Gaussian filter along horz line.
vec3 Horz5Bloom(vec2 pos,float off){
  vec3 b=Fetch(pos,vec2(-2.0,off));
  vec3 c=Fetch(pos,vec2(-1.0,off));
  vec3 d=Fetch(pos,vec2( 0.0,off));
  vec3 e=Fetch(pos,vec2( 1.0,off));
  vec3 f=Fetch(pos,vec2( 2.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=(2.0 - hardBloomPix) * -1.0;
  float wb=Gaus(dst-2.0,scale);
  float wc=Gaus(dst-1.0,scale);
  float wd=Gaus(dst+0.0,scale);
  float we=Gaus(dst+1.0,scale);
  float wf=Gaus(dst+2.0,scale);
  // Return filtered sample.
  return (b*wb+c*wc+d*wd+e*we+f*wf)/(wb+wc+wd+we+wf);}

// Return scanline weight.
float Scan(vec2 pos,float off){
  float dst=Dist(pos).y;
  return Gaus(dst+off,(30 - hardScan) * -1.);}

// Return scanline weight for bloom.
float BloomScan(vec2 pos,float off){
  float dst=Dist(pos).y;
  return Gaus(dst+off, (4.0 - hardBloomScan) * -1.0);}

// Allow nearest three lines to effect pixel.
vec3 Tri(vec2 pos){
  vec3 a=Horz3(pos,-1.0);
  vec3 b=Horz5(pos, 0.0);
  vec3 c=Horz3(pos, 1.0);
  float wa=Scan(pos,-1.0);
  float wb=Scan(pos, 0.0);
  float wc=Scan(pos, 1.0);
  return a*wa+b*wb+c*wc;}


// Distortion of scanlines, and end of screen alpha.
vec2 Warp(vec2 pos)
{
    pos=pos*2.0-1.0;    
    pos*=vec2(1.0+(pos.y*pos.y)*warp.x,1.0+(pos.x*pos.x)*warp.y);
    return pos*0.5+0.5;
}
	  
// Small bloom.
vec3 Bloom(vec2 pos){
  vec3 a=Horz5(pos,-2.0);
  vec3 b=Horz7(pos,-1.0);
  vec3 c=Horz7(pos, 0.0);
  vec3 d=Horz7(pos, 1.0);
  vec3 e=Horz5(pos, 2.0);
  float wa=BloomScan(pos,-2.0);
  float wb=BloomScan(pos,-1.0);
  float wc=BloomScan(pos, 0.0);
  float wd=BloomScan(pos, 1.0);
  float we=BloomScan(pos, 2.0);
  return a*wa+b*wb+c*wc+d*wd+e*we;}

// Very compressed TV style shadow mask.
vec3 Mask1(vec2 pos){
  float line=maskLight;
  float odd=0.0;
  if(fract(pos.x/6.0)<0.5)odd=1.0;
  if(fract((pos.y+odd)/2.0)<0.5)line=maskDark;  
  pos.x=fract(pos.x/3.0);
  vec3 mask=vec3(maskDark,maskDark,maskDark);
  if(pos.x<0.333)mask.r=maskLight;
  else if(pos.x<0.666)mask.g=maskLight;
  else mask.b=maskLight;
  mask*=line;
  return mask;}   

// Aperture-grille.
vec3 Mask2(vec2 pos){
  pos.x=fract(pos.x/3.0);
  vec3 mask=vec3(maskDark,maskDark,maskDark);
  if(pos.x<0.333)mask.r=maskLight;
  else if(pos.x<0.666)mask.g=maskLight;
  else mask.b=maskLight;
  return mask;}      

// Stretched VGA style shadow mask (same as prior shaders).
vec3 Mask3(vec2 pos){
  pos.x+=pos.y*3.0;
  vec3 mask=vec3(maskDark,maskDark,maskDark);
  pos.x=fract(pos.x/6.0);
  if(pos.x<0.333)mask.r=maskLight;
  else if(pos.x<0.666)mask.g=maskLight;
  else mask.b=maskLight;
  return mask;}    

// VGA style shadow mask.
vec3 Mask4(vec2 pos){
  pos.xy=floor(pos.xy*vec2(1.0,0.5));
  pos.x+=pos.y*3.0;
  vec3 mask=vec3(maskDark,maskDark,maskDark);
  pos.x=fract(pos.x/6.0);
  if(pos.x<0.333)mask.r=maskLight;
  else if(pos.x<0.666)mask.g=maskLight;
  else mask.b=maskLight;
  return mask;}

void main() 
{
 	//vec2 pos = Warp(gl_FragCoord.xy/resolution.xy);
	vec2 pos = gl_FragCoord.xy/resolution.xy;
	vec3 col_org = texture2D(adsk_results_pass4, pos).rgb;
	vec3 col = vec3(0.0);
	col = Tri(pos)*Mask2(gl_FragCoord.xy);
	col += Bloom(pos)* (bloomAmount - 0.5) * 0.5;
	col = ToSrgb(col.rgb);
	// simple  vignette
	col *= 0.5 + 0.5*pow(80.0*pos.x*pos.y*(1.0-pos.x)*(1.0-pos.y),0.5);
	
	if ( no_crt_masking )
		col = col;
	else
		col = col_org;
	gl_FragColor.rgb = col.rgb;
}