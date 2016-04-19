#version 120
// based on http://glslsandbox.com/e#17361.0

#define HALF_PIX 0.5

uniform float zoom;
uniform sampler2D front, depth;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_time;
uniform float prop_f_volume;
uniform vec3 f_pos;
uniform vec3 f_volume;
uniform float ff_volume;
uniform bool prop_volume;

// CameraFX part start
vec2 adsk_getCameraNearFar();
vec2 camNearFar=adsk_getCameraNearFar();
// camera view
mat4 adsk_getCameraViewInverseMatrix();
// camera projection information
vec2 input_texture_size = vec2(adsk_result_w, adsk_result_h);
mat4 adsk_getCameraProjectionMatrix();
mat4 camProj = adsk_getCameraProjectionMatrix();
vec4 camProjectionInfo = vec4(-2.0 / (input_texture_size.x*camProj[0][0]), 
                              -2.0 / (input_texture_size.y*camProj[1][1]),
                              ( 1.0 - camProj[0][2]) / camProj[0][0], 
                              ( 1.0 + camProj[1][2]) / camProj[1][1]);
// Compute the depth from a world space z
float z2d(float z)
{
	return (-z-camNearFar.x)/(camNearFar.y-camNearFar.x);
}
// Reconstruct camera-space P.xyz from screen-space S = (x, y) in pixels and depth. 
vec3 screenToCamPos(vec2 ss_pos,float depth) 
{
	float z = depth*(camNearFar.y-camNearFar.x)+camNearFar.x;
	vec3 cs_pos = vec3(((ss_pos + vec2(HALF_PIX))* 
	camProjectionInfo.xy + camProjectionInfo.zw) * z, z);
	return -cs_pos;
}
// Recover the world position from the given camera position
vec3 camToWorldPos(vec3 c_pos) 
{
	vec4 wpos = adsk_getCameraViewInverseMatrix()*vec4(c_pos,1.0);
	return wpos.w>0.0?wpos.xyz/wpos.w:wpos.xyz;
}							  
// CameraFX part end

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor ); 
float adsk_getLuminance( vec3 rgb );
bool adsk_isSceneLinear();
vec3  adsk_hsv2rgb( vec3 hsv );
const vec3 adskUID_LumCoeff = vec3(0.2125, 0.7154, 0.0721);


uniform vec3 adskUID_colourWheel1;
uniform vec3 adskUID_colourWheel2;
uniform vec3 adskUID_colourWheel3;

uniform float adskUID_Speed;
uniform float adskUID_Offset;
uniform float adskUID_Noise;
uniform float adskUID_brightness;
uniform float adskUID_contrast;
uniform float adskUID_saturation;
uniform float adskUID_tint;
uniform vec3 adskUID_tint_col;

uniform int adskUID_VolumeSteps; // 32
uniform float adskUID_StepSize; // 0.25 
uniform float adskUID_Density; // 0.2
uniform float adskUID_NoiseFreq; // 2.0
uniform float adskUID_NoiseAmp; // 2.0
uniform vec3 adskUID_NoiseAnim; // vec3(0, 0, 0)
uniform float adskUID_SphereRadius; //= 2.0;
uniform int adskUID_blendModes;

float adskUID_time = adsk_time * 0.05 * adskUID_Speed + adskUID_Offset;
vec2 adskUID_resolution = vec2(adsk_result_w, adsk_result_h);

// iq's nice integer-less noise function
// matrix to rotate the noise octaves
mat3 adskUID_m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float adskUID_hash( float n )
{
	return fract(sin(n)*43758.5453);
}

float adskUID_noise( in vec3 x )
{
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	float n = p.x + p.y*57.0 + 113.0*p.z;
	float res = mix(mix(mix( adskUID_hash(n+  0.0), adskUID_hash(n+  1.0),f.x),
		mix( adskUID_hash(n+ 57.0), adskUID_hash(n+ 58.0),f.x),f.y),
		mix(mix( adskUID_hash(n+113.0), adskUID_hash(n+114.0),f.x),
		mix( adskUID_hash(n+170.0), adskUID_hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float adskUID_fbm( vec3 p )
{
	float f;
	f = 0.5000*adskUID_noise( p ); p = adskUID_m*p*2.02;
	f += 0.2500*adskUID_noise( p ); p = adskUID_m*p*2.03;
	f += 0.1250*adskUID_noise( p ); p = adskUID_m*p*2.01;
	f += 0.0625*adskUID_noise( p );
	return f;
}

// returns signed distance to surface
float adskUID_distanceFunc(vec3 p)
{	
	float d = length(p) - adskUID_SphereRadius;	// distance to sphere
	// offset distance with pyroclastic noise
	d += adskUID_fbm(p*adskUID_NoiseFreq + adskUID_NoiseAnim*adskUID_time) * adskUID_NoiseAmp;
	return d;
}

// We are using this function to map the Hue and Gain of the Colour Wheel in HSV to an RGB value
vec3 getRGB( float hue )
{
   return adsk_hsv2rgb( vec3( hue, 1.0, 1.0 ) );
}

// color gradient 
vec4 adskUID_gradient(float x)
{
   vec4 adskUID_c0 = vec4(getRGB( adskUID_colourWheel1.x / 360.0 ) * vec3( adskUID_colourWheel1.y * 0.01), adskUID_colourWheel1.z * 0.01);
   vec4 adskUID_c1 = vec4(getRGB( adskUID_colourWheel2.x / 360.0 ) * vec3( adskUID_colourWheel2.y * 0.01), adskUID_colourWheel2.z * 0.01);
   vec4 adskUID_c3 = vec4(getRGB( adskUID_colourWheel3.x / 360.0 ) * vec3( adskUID_colourWheel3.y * 0.01), adskUID_colourWheel3.z * 0.01);

   const vec4 adskUID_c2 = vec4(0, 0, 0, 0); 	// black
   const vec4 adskUID_c4 = vec4(0, 0, 0, 0); 	// black

   x = clamp(x, 0.0, 0.999);
   float t = fract(x*4.0);
   vec4 c;
   if (x < 0.25) {
      c =  mix(adskUID_c0, adskUID_c1, t);
   } else if (x < 0.5) {
      c = mix(adskUID_c1, adskUID_c2, t);
   } else if (x < 0.75) {
      c = mix(adskUID_c2, adskUID_c3, t);
   } else {
      c = mix(adskUID_c3, adskUID_c4, t);		
   }
   return c;
}

// shade a point based on distance
vec4 adskUID_shade(float d)
{	
   // lookup in color gradient
   return adskUID_gradient(d);
}

// procedural volume
// maps position to color
vec4 adskUID_volumeFunc(vec3 p)
{
   float d = adskUID_distanceFunc(p);
   return adskUID_shade(d);
}

// 
// This function map a camera position into a position 
// relative to the fire noise 
// If you wish to translate, rotate, scale the fire you 
// may add code here
// 
vec3 cam2fire(in vec3 camPos)
{
   // here I just rescale the world so that the fire covers
   // enough of my scene
	vec3 cam;
	if ( prop_volume )
		cam = camToWorldPos(camPos - f_pos)/vec3(ff_volume);
	else
		cam = camToWorldPos(camPos - f_pos)/vec3(f_volume);
   return cam;
}

// 
// This function march the ray from the camera center to the 
// fragment 3d position. 
// The ray is marched by z steps, from the camera near to far 
// 
//
//
vec4 adskUID_rayMarch(vec3 rayOrigin, vec3 dir, float dist)
{
   vec4 sum = vec4(0, 0, 0, 0);
   vec3 dirZ = dir/abs(dir.z);
   float targetZ = (dir.z*dist);
   vec3 pos = (rayOrigin + camNearFar.x*dirZ);
   float stepSize = (camNearFar.y-camNearFar.x)/adskUID_VolumeSteps * adskUID_StepSize * 0.1;
   for(int i=0; i<adskUID_VolumeSteps; i++) 
   {
      // compute the fire noise 
      vec4 col = adskUID_volumeFunc(cam2fire(pos));
      col.a *= adskUID_Density * 15.0 / float( adskUID_VolumeSteps );
      //col.a = min(col.a, 1.0);
      // pre-multiply alpha
      col.rgb *= col.a;
      
	  
      // smoothstep to avoid curtain effects
      float d = targetZ-(pos.z-rayOrigin.z);
      if (d>0) { 
         col *= 1.0-smoothstep(0,stepSize,d); 
      }

      // integrate
      sum = sum + col*(1.0 - sum.a);	

      // we hit the geometry : stop marching further
      if (d>0) { break; }
      
      // march  
      pos += dirZ*stepSize;
   }
   vec4 col = sum;
   vec3 avg_lum = vec3(0.5, 0.5, 0.5);
   vec3 intensity = vec3(dot(col.rgb, adskUID_LumCoeff));
   vec3 sat_color = mix(intensity, col.rgb, adskUID_saturation);
   vec3 con_color = mix(avg_lum, sat_color, adskUID_contrast);
   vec3 brt_color = con_color - 1.0 + adskUID_brightness;
   vec3 c = mix(brt_color, brt_color * adskUID_tint_col, adskUID_tint);
 
	return vec4(c, col.a);
}

void main(void)
{
    // get the resolution
    vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
    // camera position in world (NB : z < 0)
    vec3 ro=vec3(0.0);
    // screen space pos of the current fragment
    vec2 uv = gl_FragCoord.xy/input_texture_size;
    // fetch the fragment depth 
    float depth = texture2D(depth, uv).x;
    // fetch the fragment diffuse color
    vec4 diff = texture2D(front, uv);
	// get the fragment world position (NB : z < 0)
    vec3 pos = screenToCamPos(gl_FragCoord.xy,depth);
    // get the ray dir to march along
    vec3 rd=normalize(pos -ro);
    // get the ray length to march along
    float rz=distance(pos,ro);
    // output color initialize to the diffuse
    vec4 col = diff;
	//vec4 col = vec4(0.0);
	
    // volume render
    col += clamp(adskUID_rayMarch(ro, rd , rz), 0.0, 1000.0);
	//col = adsk_getBlendedValue( adskUID_blendModes, diff, vec4(col.rgb, diff.a));
    gl_FragColor = vec4(col);
}
