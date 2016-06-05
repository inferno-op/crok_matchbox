//*****************************************************************************/
// 
// Filename: Action3DSelective.2.glsl
//
// Copyright (c) 2015 Autodesk, Inc.
// All rights reserved.
// 
// This computer source code and related instructions and comments are the
// unpublished confidential and proprietary information of Autodesk, Inc.
// and are protected under applicable copyright and trade secret law.
// They may not be disclosed to, copied or used by any third party without
// the prior written consent of Autodesk, Inc.
//*****************************************************************************/

/**
 * @brief Action3DSelective show how to generate a matte based on 
 *        characteristics of the fragment :
 * - its 3D position
 * - its 3D normal
 * - its 3D motion
 * - its colour
 */

#version 120
#define HALF_PIX 0.5

//Forward Declaration
float adsk_getLuminance( vec3 rgb);
vec3 adsk_rgb2hsv( vec3 rgb );
vec3 adsk_hsv2rgb( vec3 hsv );

// input textures
uniform sampler2D front, matte, normals, motion3d;
uniform sampler2D adsk_results_pass1; // depth
uniform float adsk_result_w, adsk_result_h;

// selection type
uniform int selectiveType;

// colour based selection
uniform vec3 colourSelect;
uniform float hueTolerance;
uniform float saturationTolerance;
uniform float luminanceTolerance;

// normal based selection
uniform vec3 NormalDir;
uniform float GainNormals;
uniform float Exponent;
uniform float Threshold;

// 3D sphere selection world
uniform vec3  CentreSphere;
uniform float RadiusSphere;
uniform float YaspectSphere;
uniform float ZaspectSphere;
uniform float FalloffSphere;
uniform float GainSphere;

// 3D sphere selection camera
uniform vec2  CentreSphereCam;
uniform float RadiusSphereCam;
uniform float YaspectSphereCam;
uniform float ZaspectSphereCam;
uniform float FalloffSphereCam;
uniform float GainSphereCam;
uniform float DepthSphereCam;

// 3D cube selection world
uniform vec3  CentreCube;
uniform float RadiusCube;
uniform float YaspectCube;
uniform float ZaspectCube;
uniform float FalloffCube;
uniform float GainCube;

// 3D cube selection cam
uniform vec2  CentreCubeCam;
uniform float RadiusCubeCam;
uniform float YaspectCubeCam;
uniform float ZaspectCubeCam;
uniform float FalloffCubeCam;
uniform float GainCubeCam;
uniform float DepthCubeCam;


// z-plane clipping selection
uniform float near;
uniform float far;
uniform float Falloff;
uniform float Gain;

// camera position selection
uniform float decayGain;
uniform int decayType;
uniform float decayWeight;

// z-plane selection
uniform float zOrigin;
uniform float zRange;
uniform float zFalloff;
uniform float zGain;

// 3D Motion selection
uniform vec3 MotionDir;
uniform vec2 MotionMagBound;
uniform float MotionDirExponent;
uniform float MotionMagExponent;
uniform float MotionGain;

// invert selection
uniform bool selectInvert;
// clamping selection
uniform bool depthClamping;

// camera near/far
vec2 adsk_getCameraNearFar();
vec2 camNearFar=adsk_getCameraNearFar();
// camera view
mat4 adsk_getCameraViewInverseMatrix();
// camera projection information
vec2 input_texture_size = vec2(adsk_result_w, adsk_result_h);
mat4 adsk_getCameraProjectionMatrix();
mat4 camProj = adsk_getCameraProjectionMatrix();
vec4 camProjectionInfo = vec4(-2.0f / (input_texture_size.x*camProj[0][0]), 
                              -2.0f / (input_texture_size.y*camProj[1][1]),
                              ( 1.0f - camProj[0][2]) / camProj[0][0], 
                              ( 1.0f + camProj[1][2]) / camProj[1][1]);

//-----------------------------------------------------------------------------
// Compute the depth from a world space z
float z2d(float z)
{
   return (-z-camNearFar.x)/(camNearFar.y-camNearFar.x);
}

//-----------------------------------------------------------------------------
// Reconstruct camera-space P.xyz from screen-space S = (x, y) in pixels and
// depth. 
vec3 screenToCamPos(vec2 ss_pos,float depth) 
{
   float z = depth*(camNearFar.y-camNearFar.x)+camNearFar.x;
   vec3 cs_pos = vec3(((ss_pos + vec2(HALF_PIX))* 
      camProjectionInfo.xy + camProjectionInfo.zw) * z, z);
   return -cs_pos;
}

//-----------------------------------------------------------------------------
// Recover the world position from the given camera position
vec3 camToWorldPos(vec3 c_pos) 
{
   vec4 wpos = adsk_getCameraViewInverseMatrix()*vec4(c_pos,1.0);
   return wpos.w>0.0?wpos.xyz/wpos.w:wpos.xyz;
}

// -----------------------------------------------------------------------------
// Returns a value between 0 to 1, based on the distance of a pixel from
// a picked colour.  The value will be 1 if the colours are equal, 0 if
// the colour is outside the ellipsoid centred on the picked colour, and a
// smooth value in between.
float getSelectiveAmount( vec3 pickedColour, vec3 radius, vec3 pixelColour )
{
   vec3 delta = pixelColour - pickedColour;
   // Handle Hue wraparound, so that the difference of hue 5 and 355
   // becomes 10
   delta.x = delta.x - 360.0 * floor( (delta.x + 180.0) / 360.0 );
   vec3 rad = max( radius, vec3( 0.0001 ) );
   delta = delta / rad;
   float dist = dot( delta, delta );

   float weight;
   if ( dist >= 1.0 ) {
      weight = 0.0;
   } else {
      dist = 1.0 - sqrt( dist );
      weight = dist * dist * (3.0 - 2.0 * dist);
   }

   return weight;
}

// ------------------------------------------------------------------------
// Converts a 3D value from the colour wheel into a 3D direction in the
// hemisphere.
//
vec3 convertColourWheelToDir( vec3 cw )
{
   float angle = radians(cw.x+90.0);
   vec2 xy = vec2( cos( angle ), sin( angle ) ) * cw.y * 0.01;
   float len2 = length( xy );
   if ( len2 >= 1.0 ) {
      float factor = 1.0 / sqrt( len2 );
      xy *= factor;
      len2 = 1.0;
   }
   float z = sqrt( 1.0 - len2 );
   return vec3( xy, z );
}

// -----------------------------------------------------------------------------
// Returns a mask value based on how close the normal is to the direction
// defined by the colour wheel.  Beyond the max angle diff (in degrees), the
// mask is 0, indicating no change.
//
float getNormalAmount( in vec2 coords, 
                       in vec3 colourWheel, 
                       in float maxAngleDiff,
                       in float exponent )
{
   vec3 n = texture2D(normals, coords).rgb;
   vec3 dir = convertColourWheelToDir( colourWheel );
   vec3 targetDirection = vec3(-dir.x,-dir.y,dir.z);
   float dotProd = clamp(abs(dot( n, targetDirection)), 0.0, 1.0);
   float angle = degrees(acos( dotProd ));
   float amount =  angle >= maxAngleDiff ? 0.0
                     : max( 0.0, maxAngleDiff - angle ) / maxAngleDiff;
   return pow( amount, exponent );
}

// -----------------------------------------------------------------------------
// Returns a mask value based on how close the normal is to the direction
// defined by the colour wheel.  Beyond the max angle diff (in degrees), the
// mask is 0, indicating no change.
//
float getMotionAmount( in vec2 coords, 
                       in vec3 colourWheel, 
                       in float dirExp,
                       in float magExp,
                       in vec2  magBounds )
{
   vec3 mt = texture2D(motion3d, coords).rgb;
   vec3 dir = convertColourWheelToDir( colourWheel );
   vec3 targetDirection = vec3(dir.x,-dir.y,dir.z);
   float dirAmount = 0.5*(dot(normalize(mt),normalize(targetDirection))+1.0);
   float magAmount = clamp(
         (length(mt) - magBounds.x)/(magBounds.y-magBounds.x),0.0,1.0);
   return pow( dirAmount,dirExp ) * pow( magAmount, magExp );
}

// -----------------------------------------------------------------------------
// Return a value of 1 inside the ellipsoid, 0 outside the ellipsoid + falloff
// radius, and a smooth gradient in between
float getSphereAmount( in vec3 p,
                       in vec3 centre, 
                       in vec3 radius,
                       in float falloff )
{
   vec3 dx = p - centre;
   float lenDx = length( dx );
   vec3 dist = dx / radius;
   float lenNorm = length(dist);
   float amount = 1.0 - clamp( (lenNorm - 1.0) * lenDx, 0.0, falloff ) /
                       (falloff + 1.0 - sign(falloff));  // avoid div by 0
   amount = amount * amount * (3.0 - 2.0 * amount);
   return amount;
}

// -----------------------------------------------------------------------------
// Return a value of 1 inside the box, 0 outside the box + falloff radius,
// and a smooth gradient in between
float getCubeAmount( in vec3 p,
                     in vec3 centre, 
                     in vec3 radius,
                     in float falloff )
{
   vec3 dx = abs( p - centre );
   dx = max( dx - radius, 0.0 );
   float amount = 1.0 - clamp( length( dx ), 0.0, falloff ) /
                       (falloff + 1.0 - sign(falloff));  // avoid div by 0
   amount = amount * amount * (3.0 - 2.0 * amount);
   return amount;
}

// -----------------------------------------------------------------------------
float getPlaneAmount( in vec3 p,
                      in float near, 
                      in float far, 
                      in float falloff )
{
   float dist = -p.z;
   float amount;
   if ( dist <= near-falloff) {
      amount = 0.0;      
   } else if ( dist < near) {
      amount = (falloff - near + dist)/falloff;
   } else if ( dist <= far ) {
      amount = 1.0;
   } else if ( dist <= far+falloff ) {
      amount = (falloff + far - dist)/falloff;
   } else {
      amount = 0.0;
   }
   return amount;
}

// -----------------------------------------------------------------------------
float computeDecay( int type, float dist )
{
   const int LINEAR_DECAY = 0;
   const int QUADRATIC_DECAY = 1;
   const int CUBIC_DECAY = 2;
   const int EXP_DECAY = 3;
   const int EXP2_DECAY = 4;
   const float LOG2E = -1.442695;
   float inv_dist = 1.0 - dist;
   return clamp(
   ( ( type == LINEAR_DECAY )    ? dist :
     ( type == QUADRATIC_DECAY ) ? ( abs( dist ) * dist ) :
     ( type == CUBIC_DECAY )     ? ( dist * dist * dist ) :
     exp2( LOG2E * ( ( type == EXP_DECAY ) ? inv_dist : inv_dist * inv_dist ) ) ),
           0.0, 1.0 );
}

// -----------------------------------------------------------------------------
void main()
{
   vec2 coords = gl_FragCoord.xy/input_texture_size;
   // get the depth
   float depth = texture2D(adsk_results_pass1, coords).x;
   // get the camera position
   float camDistToOrigin=camToWorldPos(vec3(0.0)).z;
   vec3 camPos = screenToCamPos(gl_FragCoord.xy,depth);
   // get the input fragment colour 
   vec4 colour = vec4(texture2D(front, coords).rgb, texture2D(matte, coords).r);
  
   // check visibility
   if (depthClamping && ((depth>=1.0) || (depth<=0.0)))
   { 
      gl_FragColor = vec4(0.0); 
      return;
   }

   // output weight 
   float weight = 1.0;

   // selection based on normals
   if (selectiveType == 1 ) 
   {
      weight = getNormalAmount( coords, NormalDir, Threshold, Exponent );  
      weight = weight*GainNormals*0.01;
   } 
   // selection based on 3d sphere world
   else if (selectiveType == 2) 
   {
      vec3 pos = camToWorldPos(camPos);
      vec3 radius = vec3( RadiusSphere ) * 
                    vec3( 1.0, YaspectSphere*0.01,
                               ZaspectSphere*0.01 );
      weight = getSphereAmount( pos, CentreSphere, radius, FalloffSphere );
      weight = weight*GainSphere*0.01;
   }
   // selection based on 3d sphere camera
   else if (selectiveType == 3) 
   {
      vec3 centre = vec3(CentreSphereCam*input_texture_size, 
                         DepthSphereCam-camDistToOrigin);
      centre = screenToCamPos(centre.xy, z2d(centre.z));
      vec3 radius = vec3( RadiusSphereCam ) * 
                    vec3( 1.0, YaspectSphereCam*0.01,
                               ZaspectSphereCam*0.01 );
      weight = getSphereAmount( camPos, centre, radius, FalloffSphereCam );
      weight = weight*GainSphereCam*0.01;
   } 
   // selection based on 3d cube world
   else if (selectiveType == 4) 
   {
      vec3 pos = camToWorldPos(camPos);
      vec3 radius = vec3( RadiusCube ) * 
                    vec3( 1.0, YaspectCube*0.01,
                               ZaspectCube*0.01 );
      weight = getCubeAmount( pos, CentreCube, radius, FalloffCube );
      weight = weight*GainCube*0.01;
   } 
   // selection based on 3d cube camera
   else if (selectiveType == 5) 
   {
      vec3 centre = vec3(CentreCubeCam*input_texture_size, 
                         DepthCubeCam-camDistToOrigin);
      centre = screenToCamPos(centre.xy, z2d(centre.z));
      vec3 radius = vec3( RadiusCubeCam ) * 
                    vec3( 1.0, YaspectCubeCam*0.01,
                               ZaspectCubeCam*0.01 );
      weight = getCubeAmount( camPos, centre, radius, FalloffCubeCam );
      weight = weight*GainCubeCam*0.01;
   } 
   // selection based on z-plane clipping
   else if (selectiveType == 6) 
   {
      weight = getPlaneAmount( camPos, near, far, Falloff );
      weight = weight*Gain*0.01;
   } 
   // selection based on distance to point of view 
   else if (selectiveType == 7) 
   {
      float distance = length(camPos) * (decayWeight * 0.0001);
      weight = computeDecay( decayType , distance );
      weight = weight*decayGain*0.01;   
   }
   // selection based on distance to z-plane 
   else if (selectiveType == 8) 
   {
      float fo=0.5*zRange+max(zFalloff,0.0001);
      float ro=1.0-(0.5*zRange/fo);
      float dist=1.0-
         abs(camDistToOrigin+zOrigin+camPos.z)/fo;
      weight = (dist>=ro ? ro : dist)/(ro>0.0?ro:1.0);
      weight = weight*zGain*0.01;
   } 
   // selection based on input colour 
   else if (selectiveType == 0) 
   {
      vec3 sourceHSV = adsk_rgb2hsv( colour.rgb ) * vec3( 360.0, 100.0, 100.0 );
      vec3 pickedHSV = adsk_rgb2hsv( colourSelect ) * vec3( 360.0, 100.0, 100.0 );
      vec3 radius = vec3(hueTolerance, saturationTolerance, luminanceTolerance);
      weight = getSelectiveAmount( pickedHSV, radius, sourceHSV );
   }
   // selection based on 3d motion
   else if (selectiveType == 9 ) 
   {
      weight = getMotionAmount( coords, MotionDir, MotionDirExponent, 
                                MotionMagExponent, MotionMagBound );
      weight = weight*MotionGain*0.01;
   } 
   // select all 
   else 
   {
      weight = 1.0;
   }

   // invert the selection    
   if ( selectInvert ) { weight = 1.0 - weight; }
  
   gl_FragColor = vec4(weight); 
}
