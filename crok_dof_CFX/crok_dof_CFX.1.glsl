//*****************************************************************************/
// 
// Filename: Action3DSelective.1.glsl
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
 * @brief 3d selective 
 *
 * First pass : decode the depth
 */
#version 120

float adsk_mergeHalvesInFloat(vec3 h);

// textures
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D depthTex; // depth input

//-----------------------------------------------------------------------------
//
void main()
{
   vec3 packedDepth = 
      texture2D(depthTex,gl_FragCoord.xy/vec2(adsk_result_w,adsk_result_h)).xyz;
   gl_FragColor = vec4(adsk_mergeHalvesInFloat(packedDepth));
}
