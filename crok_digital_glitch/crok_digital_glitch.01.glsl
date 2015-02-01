#version 120
// based on https://www.shadertoy.com/view/Md2GDw and  https://www.shadertoy.com/view/4sBSDd and https://www.shadertoy.com/view/MdfGD2 and https://www.shadertoy.com/view/4sjGRD# 
// original glsl shader by kusma, hornet and bytewave 

uniform sampler2D Source;
uniform bool horizontal_slice;
uniform float adsk_time, adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

const float min_change_frq = 4.0;

uniform float max_ofs_siz;
uniform float yuv_threshold;
uniform float time_frq;
uniform float line_offset_threshold;

float THRESHOLD = line_offset_threshold * 1000. / resolution.x;
float time_s = mod( time, 32.0 );
float glitch_threshold = 1.0 - THRESHOLD;

float sat( float t ) {
	return clamp( t, 0.0, 1.0 );
}
vec2 sat( vec2 t ) {
	return clamp( t, 0.0, 1.0 );
}

float remap( float t, float a, float b ) {
	return sat( (t - a) / (b - a) );
}

float linterp( float t ) {
	return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

float rand2(vec2 co) 
{
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

float srand( vec2 n ) {
	return rand2(n) * 2.0 - 1.0;
}

float trunc( float x, float num_levels )
{
	return floor(x*num_levels) / num_levels;
}
vec2 trunc( vec2 x, vec2 num_levels )
{
	return floor(x*num_levels) / num_levels;
}

vec3 rgb2yuv( vec3 rgb )
{
	vec3 yuv;
	yuv.x = dot( rgb, vec3(0.299,0.587,0.114) );
	yuv.y = dot( rgb, vec3(-0.14713, -0.28886, 0.436) );
	yuv.z = dot( rgb, vec3(0.615, -0.51499, -0.10001) );
	return yuv;
 }
 vec3 yuv2rgb( vec3 yuv )
 {
	vec3 rgb;
	rgb.r = yuv.x + yuv.z * 1.13983;
	rgb.g = yuv.x + dot( vec2(-0.39465, -0.58060), yuv.yz );
	rgb.b = yuv.x + yuv.y * 2.03211;
	return rgb;
 }
  
void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 col = texture2D(Source,uv).rgb;
	
	
	if ( horizontal_slice )
	{
		float ct = trunc( time_s, min_change_frq );
		float change_rnd = rand2( trunc(uv.yy,vec2(16)) + 150.0 * ct );
		float tf = time_frq*change_rnd;
		float t = 5.0 * trunc( time_s, tf );
		float vt_rnd = 0.5*rand2( trunc(uv.yy + t, vec2(11)) );
		vt_rnd += 0.5 * rand2(trunc(uv.yy + t, vec2(7)));
		vt_rnd = vt_rnd*2.0 - 1.0;
		vt_rnd = sign(vt_rnd) * sat( ( abs(vt_rnd) - glitch_threshold) / (1.0-glitch_threshold) );
		vec2 uv_nm = uv;
		uv_nm = sat( uv_nm + vec2(max_ofs_siz*vt_rnd, 0) );
		float rnd = rand2( vec2( trunc( time_s, 8.0 )) );
		uv_nm.y = (rnd>mix(1.0, 0.975, sat(THRESHOLD))) ? 1.0-uv_nm.y : uv_nm.y;
		vec4 sample = texture2D(Source,uv_nm); 
		vec3 sample_yuv = rgb2yuv( sample.rgb );
		sample_yuv.y /= 1.0-3.0*abs(vt_rnd) * sat( yuv_threshold - vt_rnd );
		sample_yuv.z += 0.125 * vt_rnd * sat( vt_rnd - yuv_threshold );
		col = vec3( yuv2rgb(sample_yuv));		
	}

	gl_FragColor = vec4(col, 1.0);
}
