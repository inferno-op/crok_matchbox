//*****************************************************************************/
//
// Filename: GridFetchingComp.1.glsl
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

#define HALF_PIXEL 0.5

uniform sampler2D adsk_texture_grid;
uniform float adsk_result_w, adsk_result_h;
uniform int       textureSelector;

  
// These 2 lines define the texture grid resolution and tile resolution 
vec2  tileSize = vec2(2048.0, 1080.0);  
const vec2     gridSize = vec2(2048.0, 1080.0);

//------------------------------------------------------------------------------
// Function that get the position in the grid of the bottom left pixel of a tile.
//
// - gridSize : size of the grid in pixels
//
// - tileSize : size of the tiles in pixels
//
// - tileNum : index of the tile to be fetched (0 is the bottom-left)
//             example of tile index layout  : 6 - 7 - 8
//                                             3 - 4 - 5
//                                             0 - 1 - 2
//------------------------------------------------------------------------------
vec2 getTilePosition( vec2 gridSize, 
                      vec2 tileSize, 
                      int tileNum )
{
   // compute the actual number of tiles per grid row and column
   ivec2 nbTiles = ivec2(gridSize)/ivec2(tileSize);

   // compute the tile position in the grid from its index
   vec2 tile = vec2(mod(float(tileNum), float(nbTiles.x)),float(tileNum/nbTiles.x));

   return tile*tileSize;
}

//------------------------------------------------------------------------------
// Function that fetch a pixel of a tile within the grid texture 
//
// - gridSize : size of the grid in pixels
//
// - tileSize : size of the tiles in pixels
//
// - tilePosition : the position in pixel of the bottom-left corner of the tile
//                  (as returned by getTilePosition)
//
// - positionInTile : the position in pixel of the tile pixel to be fetched
//                    (0,0) is the bottom-left corner of the tile
//                    (tileSize.x,tileSize.y) is the upper-rigth corner of the tile
//
//------------------------------------------------------------------------------
vec4 fetchInTile( vec2 gridSize,
                  vec2 tileSize,
                  vec2 tilePosition, 
                  vec2 positionInTile )
{

   // compute the normalized coords of tile pixel to be 
   // fetched within the grid 
   vec2 positionInGrid = (tilePosition+positionInTile)/gridSize;
  
   return texture2D( adsk_texture_grid, positionInGrid );
}


//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
void main()
{
   // fetch the transform position
   vec4 tileResult = fetchInTile(gridSize, tileSize, 
      getTilePosition(gridSize,tileSize,textureSelector), gl_FragCoord.xy);
             
   gl_FragColor = tileResult;
}
