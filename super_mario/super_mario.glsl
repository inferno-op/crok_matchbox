// [SIG15] Mario World 1-1
// by Krzysztof Narkowicz @knarkowicz
// 
// Intersting findings from original NES Super Mario Bros.:
// -Clouds and brushes of all sizes are drawn using the same small sprite (32x24)
// -Hills, clouds and bushes weren't placed manually. Every background object type is repeated after 768 pixels.
// -Overworld (main theme) drum sound uses only the APU noise generator

// based on https://www.shadertoy.com/view/XtlSD7  Krzysztof Narkowicz @knarkowicz

uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float Speed;
float time = adsk_time *.05 * Speed;

#define SPRITE_DEC( x, i ) mod( floor( i / pow( 4.0, float( x ) ) ), 4.0 )
#define RGB( r, g, b ) vec3( float( r ) / 255.0, float( g ) / 255.0, float( b ) / 255.0 )

const float MARIO_SPEED	 = 89.0;
const float GOOMBA_SPEED = 32.0;
const float INTRO_LENGTH = 2.0;

void SpriteBlock( inout vec3 color, int x, int y )
{
    // black
    float idx = 1.0;
    
    // light orange
    idx = x < y ? 3.0 : idx;
    
    // dark orange
    idx = x > 3 && x < 12 && y > 3 && y < 12 ? 2.0 : idx;
    idx = x == 15 - y ? 2.0 : idx;
    
    color = RGB( 0, 0, 0 );
	color = idx == 2.0 ? RGB( 231,  90,  16 ) : color;
	color = idx == 3.0 ? RGB( 247, 214, 181 ) : color;
}

void SpriteHill( inout vec3 color, int x, int y )
{
    float idx = 0.0;
    
    // dark green
    idx = ( x > y && 79 - x > y ) && y < 33 ? 2.0 : idx;
    idx = ( x >= 37 && x <= 42 ) && y == 33 ? 2.0 : idx;
    
    // black
    idx = ( x == y || 79 - x == y ) && y < 33 ? 1.0 : idx;
    idx = ( x == 33 || x == 46 ) && y == 32 ? 1.0 : idx;
    idx = ( x >= 34 && x <= 36 ) && y == 33 ? 1.0 : idx;
    idx = ( x >= 43 && x <= 45 ) && y == 33 ? 1.0 : idx;
    idx = ( x >= 37 && x <= 42 ) && y == 34 ? 1.0 : idx;
    idx = ( x >= 25 && x <= 26 ) && ( y >= 8  && y <= 11 ) ? 1.0 : idx;
    idx = ( x >= 41 && x <= 42 ) && ( y >= 24 && y <= 27 ) ? 1.0 : idx;
    idx = ( x >= 49 && x <= 50 ) && ( y >= 8  && y <= 11 ) ? 1.0 : idx;
    idx = ( x >= 28 && x <= 30 ) && ( y >= 11 && y <= 14 ) ? 1.0 : idx;
    idx = ( x >= 28 && x <= 30 ) && ( y >= 11 && y <= 14 ) ? 1.0 : idx;
    idx = ( x >= 44 && x <= 46 ) && ( y >= 27 && y <= 30 ) ? 1.0 : idx;
    idx = ( x >= 44 && x <= 46 ) && ( y >= 27 && y <= 30 ) ? 1.0 : idx;
    idx = ( x >= 52 && x <= 54 ) && ( y >= 11 && y <= 14 ) ? 1.0 : idx;
    idx = ( x == 29 || x == 53 ) && ( y >= 10 && y <= 15 ) ? 1.0 : idx;
    idx = x == 45 && ( y >= 26 && y <= 31 ) ? 1.0 : idx;
    
	color = idx == 1.0 ? RGB( 0,     0,  0 ) : color;
	color = idx == 2.0 ? RGB( 0,   173,  0 ) : color;
}

void SpritePipe( inout vec3 color, int x, int y, int h )
{
    int offset = h * 16;

    // light green
	float idx = 3.0;
    
    // dark green
    idx = ( ( x > 5 && x < 8 ) || ( x == 13 ) || ( x > 15 && x < 23 ) ) && y < 17 + offset ? 2.0 : idx;
    idx = ( ( x > 4 && x < 7 ) || ( x == 12 ) || ( x > 14 && x < 24 ) ) && ( y > 17 + offset && y < 30 + offset ) ? 2.0 : idx;    
    idx = ( x < 5 || x > 11 ) && y == 29 + offset ? 2.0 : idx;
	idx = fract( float( x ) * 0.5 + float( y ) * 0.5 ) == 0.5 && x > 22 && ( ( x < 26 && y < 17 + offset ) || ( x < 28 && y > 17 + offset && y < 30 + offset ) ) ? 2.0 : idx;    
    
    // black
    idx = y == 31 + offset || x == 0 || x == 31 || y == 17 + offset ? 1.0 : idx;
    idx = ( x == 2 || x == 29 ) && y < 18 + offset ? 1.0 : idx;
    idx = ( x > 1 && x < 31 ) && y == 16 + offset ? 1.0 : idx;    
    
    // transparent
    idx = ( x < 2 || x > 29 ) && y < 17 + offset ? 0.0 : idx;

	color = idx == 1.0 ? RGB( 0,     0,  0 ) : color;
	color = idx == 2.0 ? RGB( 0,   173,  0 ) : color;
	color = idx == 3.0 ? RGB( 189, 255, 24 ) : color;
}

void SpriteCloud( inout vec3 color, int x, int y, bool isBush )
{
   	float idx = 0.0;
	idx = y == 23 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 20480.0 : ( x <= 23 ? 5.0 : 0.0 ) ) ) : idx;
	idx = y == 22 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 62464.0 : ( x <= 23 ? 31.0 : 0.0 ) ) ) : idx;
	idx = y == 21 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 64832.0 : ( x <= 23 ? 127.0 : 0.0 ) ) ) : idx;
	idx = y == 20 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 65488.0 : ( x <= 23 ? 1151.0 : 0.0 ) ) ) : idx;
	idx = y == 19 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 65488.0 : ( x <= 23 ? 7679.0 : 0.0 ) ) ) : idx;
	idx = y == 18 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 65488.0 : ( x <= 23 ? 32763.0 : 0.0 ) ) ) : idx;
	idx = y == 17 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 60404.0 : ( x <= 23 ? 32751.0 : 0.0 ) ) ) : idx;
	idx = y == 16 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 65277.0 : ( x <= 23 ? 32767.0 : 0.0 ) ) ) : idx;
	idx = y == 15 ? ( x <= 7 ? 21504.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 65.0 ) ) ) : idx;
	idx = y == 14 ? ( x <= 7 ? 64768.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 465.0 ) ) ) : idx;
	idx = y == 13 ? ( x <= 7 ? 65344.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 503.0 ) ) ) : idx;
	idx = y == 12 ? ( x <= 7 ? 65472.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 4607.0 ) ) ) : idx;
	idx = y == 11 ? ( x <= 7 ? 65492.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 30719.0 ) ) ) : idx;
	idx = y == 10 ? ( x <= 7 ? 65533.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 32767.0 ) ) ) : idx;
	idx = y == 9 ? ( x <= 7 ? 65533.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 32767.0 ) ) ) : idx;
	idx = y == 8 ? ( x <= 7 ? 65524.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 8191.0 ) ) ) : idx;
	idx = y == 7 ? ( x <= 7 ? 64464.0 : ( x <= 15 ? 65535.0 : ( x <= 23 ? 65535.0 : 2047.0 ) ) ) : idx;
	idx = y == 6 ? ( x <= 7 ? 61248.0 : ( x <= 15 ? 65531.0 : ( x <= 23 ? 65534.0 : 8191.0 ) ) ) : idx;
	idx = y == 5 ? ( x <= 7 ? 48384.0 : ( x <= 15 ? 45034.0 : ( x <= 23 ? 65535.0 : 32767.0 ) ) ) : idx;
	idx = y == 4 ? ( x <= 7 ? 64768.0 : ( x <= 15 ? 43695.0 : ( x <= 23 ? 64510.0 : 16383.0 ) ) ) : idx;
	idx = y == 3 ? ( x <= 7 ? 21504.0 : ( x <= 15 ? 64255.0 : ( x <= 23 ? 65194.0 : 6143.0 ) ) ) : idx;
	idx = y == 2 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 32765.0 : ( x <= 23 ? 65451.0 : 381.0 ) ) ) : idx;
	idx = y == 1 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 8148.0 : ( x <= 23 ? 24565.0 : 20.0 ) ) ) : idx;
	idx = y == 0 ? ( x <= 7 ? 0.0 : ( x <= 15 ? 1344.0 : ( x <= 23 ? 1360.0 : 0.0 ) ) ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

    vec3 colorB = isBush ? RGB( 0,   173,  0 ) : RGB(  57, 189, 255 );
    vec3 colorC = isBush ? RGB( 189, 255, 24 ) : RGB( 254, 254, 254 );

	color = idx == 1.0 ? RGB( 0, 0, 0 ) : color;
	color = idx == 2.0 ? colorB 		: color;
	color = idx == 3.0 ? colorC 		: color;
}

void SpriteCloud1( inout vec3 color, int x, int y, bool isBush )
{
    if ( x >= 0 && x <= 31 )
    {
    	SpriteCloud( color, x, y, isBush );
    }
}

void SpriteCloud2( inout vec3 color, int x, int y, bool isBush )
{
    if ( x >= 0 && x <= 47 )
    {
    	SpriteCloud( color, x <= 23 ? x : x - 16, y, isBush );
    }
}

void SpriteCloud3( inout vec3 color, int x, int y, bool isBush )
{
    if ( x >= 0 && x <= 63 )
    {
    	SpriteCloud( color, x <= 23 ? x : ( x <= 39 ? x - 16 : x - 32 ), y, isBush );
    }
}

void SpriteFlag( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? 43690.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 43688.0 : 42326.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43680.0 : 38501.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43648.0 : 39529.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 43520.0 : 39257.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 43008.0 : 38293.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 40960.0 : 38229.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 32768.0 : 43354.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 0.0 : 43690.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 0.0 : 43688.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 0.0 : 43680.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 0.0 : 43648.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 0.0 : 43520.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 0.0 : 43008.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 0.0 : 40960.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 0.0 : 32768.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB(   0, 173,   0 ) : color;
	color = idx == 2.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteGoomba3( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? 0.0 : idx;
	idx = y == 13 ? 0.0 : idx;
	idx = y == 12 ? 0.0 : idx;
	idx = y == 11 ? 0.0 : idx;
	idx = y == 10 ? 0.0 : idx;
	idx = y == 9 ? 0.0 : idx;
	idx = y == 8 ? 0.0 : idx;
	idx = y == 7 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 43648.0 : 682.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 42344.0 : 10586.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 24570.0 : 45045.0 ) : idx;
	idx = y == 3 ? 43690.0 : idx;
	idx = y == 2 ? ( x <= 7 ? 65472.0 : 1023.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 65280.0 : 255.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 1364.0 : 5456.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 0,     0,   0 ) : color;
	color = idx == 2.0 ? RGB( 153,  75,  12 ) : color;
	color = idx == 3.0 ? RGB( 255, 200, 184 ) : color;
}

void SpriteGoomba2( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43008.0 : 42.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43520.0 : 170.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43648.0 : 682.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 43360.0 : 2410.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 42920.0 : 10970.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 22440.0 : 10965.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 47018.0 : 43742.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 49066.0 : 43774.0 ) : idx;
	idx = y == 6 ? 43690.0 : idx;
	idx = y == 5 ? ( x <= 7 ? 65192.0 : 10943.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 65280.0 : 255.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 65360.0 : 255.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 62804.0 : 383.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 54612.0 : 351.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 5456.0 : 84.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 0,     0,   0 ) : color;
	color = idx == 2.0 ? RGB( 153,  75,  12 ) : color;
	color = idx == 3.0 ? RGB( 255, 200, 184 ) : color;
}

void SpriteGoomba1( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43008.0 : 42.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43520.0 : 170.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43648.0 : 682.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 43360.0 : 2410.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 42920.0 : 10970.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 22440.0 : 10965.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 47018.0 : 43742.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 49066.0 : 43774.0 ) : idx;
	idx = y == 6 ? 43690.0 : idx;
	idx = y == 5 ? ( x <= 7 ? 65192.0 : 10943.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 65280.0 : 255.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 65280.0 : 1535.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 64832.0 : 5471.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 62784.0 : 5463.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 5376.0 : 1364.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 0,     0,   0 ) : color;
	color = idx == 2.0 ? RGB( 153,  75,  12 ) : color;
	color = idx == 3.0 ? RGB( 255, 200, 184 ) : color;
}

void SpriteGoomba( inout vec3 color, int x, int y, int frame )
{    
	if ( frame == 0 )
    {
		SpriteGoomba1( color, x, y );
	}
	else if ( frame == 1 )
	{
		SpriteGoomba2( color, x, y );
	}
    else if ( frame == 2 )
    {
        SpriteGoomba3( color, x, y );
    }
}

void SpriteKoopa2( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 23 ? 0.0 : idx;
	idx = y == 22 ? ( x <= 7 ? 192.0 : 0.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 1008.0 : 0.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 3056.0 : 0.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 11224.0 : 0.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 11224.0 : 0.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 11224.0 : 0.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 11256.0 : 0.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 10986.0 : 0.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 10918.0 : 0.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 2730.0 : 341.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 18986.0 : 1622.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 18954.0 : 5529.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 24202.0 : 8037.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 24200.0 : 7577.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 28288.0 : 9814.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 40864.0 : 6485.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 26496.0 : 9814.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 23424.0 : 5529.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 22272.0 : 5477.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 24320.0 : 64921.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 65152.0 : 4054.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 60064.0 : 11007.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 2728.0 : 43520.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 30,  132,   0 ) : color;
	color = idx == 2.0 ? RGB( 215, 141,  34 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteKoopa1( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 23 ? ( x <= 7 ? 768.0 : 0.0 ) : idx;
	idx = y == 22 ? ( x <= 7 ? 4032.0 : 0.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 4064.0 : 0.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 12128.0 : 0.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 12136.0 : 0.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 12136.0 : 0.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 12264.0 : 0.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 11174.0 : 0.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 10922.0 : 0.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 10282.0 : 341.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 30730.0 : 1622.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 31232.0 : 1433.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 24192.0 : 8037.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 24232.0 : 7577.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 28320.0 : 9814.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 40832.0 : 6485.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 26496.0 : 9814.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 23424.0 : 5529.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 22272.0 : 5477.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 24320.0 : 64921.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 65024.0 : 12246.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 59904.0 : 11007.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 43008.0 : 10752.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 40960.0 : 2690.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 30,  132,   0 ) : color;
	color = idx == 2.0 ? RGB( 215, 141,  34 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteKoopa( inout vec3 color, int x, int y, int frame )
{    
	if ( frame == 0 )
    {
		SpriteKoopa1( color, x, y );
	}
	else if ( frame == 1 )
	{
		SpriteKoopa2( color, x, y );
	}
}

void SpriteQuestion( inout vec3 color, int x, int y, float t )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 43688.0 : 10922.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 65534.0 : 32767.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 65502.0 : 30719.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 44030.0 : 32762.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 23294.0 : 32745.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 56062.0 : 32619.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 56062.0 : 32619.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 55294.0 : 32618.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 49150.0 : 32598.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 49150.0 : 32758.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 65534.0 : 32757.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 49150.0 : 32766.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 49150.0 : 32758.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 65502.0 : 30709.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 65534.0 : 32767.0 ) : idx;
	idx = y == 0 ? 21845.0 : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 0,     0,   0 ) : color;
	color = idx == 2.0 ? RGB( 231,  90,  16 ) : color;
	color = idx == 3.0 ? mix( RGB( 255,  165, 66 ), RGB( 231,  90,  16 ), t ) : color;
}

void SpriteMushroom( inout vec3 color, int x, int y )
{
    float idx = 0.0;
    idx = y == 15 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43008.0 : 22.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43520.0 : 85.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43648.0 : 341.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 43680.0 : 2646.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 42344.0 : 10922.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 38232.0 : 10922.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 38234.0 : 42410.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 38234.0 : 38314.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 42346.0 : 38570.0 ) : idx;
	idx = y == 5 ? 43690.0 : idx;
	idx = y == 4 ? ( x <= 7 ? 64856.0 : 9599.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 65280.0 : 255.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 65280.0 : 239.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 65280.0 : 239.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 64512.0 : 59.0 ) : idx;
    
    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

    color = idx == 1.0 ? RGB( 181, 49,   33 ) : color;
	color = idx == 2.0 ? RGB( 230, 156,  33 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteGround( inout vec3 color, int x, int y )
{   
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 65534.0 : 49127.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 43691.0 : 27254.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 43691.0 : 38246.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 43691.0 : 32758.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 43691.0 : 27318.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 43685.0 : 27309.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 43615.0 : 27309.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 22011.0 : 27307.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 32683.0 : 27307.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 27307.0 : 23211.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 38230.0 : 38231.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = RGB( 0, 0, 0 );
	color = idx == 2.0 ? RGB( 231,  90,  16 ) : color;
	color = idx == 3.0 ? RGB( 247, 214, 181 ) : color;
}

void SpriteSuperMarioJump( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 31 ? ( x <= 7 ? 0.0 : 16128.0 ) : idx;
	idx = y == 30 ? ( x <= 7 ? 0.0 : 63424.0 ) : idx;
	idx = y == 29 ? ( x <= 7 ? 40960.0 : 55274.0 ) : idx;
	idx = y == 28 ? ( x <= 7 ? 43520.0 : 65514.0 ) : idx;
	idx = y == 27 ? ( x <= 7 ? 43648.0 : 21866.0 ) : idx;
	idx = y == 26 ? ( x <= 7 ? 43648.0 : 23210.0 ) : idx;
	idx = y == 25 ? ( x <= 7 ? 62784.0 : 22013.0 ) : idx;
	idx = y == 24 ? ( x <= 7 ? 63440.0 : 24573.0 ) : idx;
	idx = y == 23 ? ( x <= 7 ? 55248.0 : 32767.0 ) : idx;
	idx = y == 22 ? ( x <= 7 ? 55248.0 : 32735.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 65492.0 : 5461.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 64852.0 : 7511.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 64832.0 : 6143.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 43520.0 : 5477.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 38228.0 : 1382.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 21845.0 : 1430.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 21845.0 : 410.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 22005.0 : 602.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 38909.0 : 874.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43007.0 : 686.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 44031.0 : 682.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 43763.0 : 17066.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 43708.0 : 21162.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 43648.0 : 21930.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 43584.0 : 21930.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 42389.0 : 21930.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 23189.0 : 21930.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 43669.0 : 21920.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 43669.0 : 0.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 10901.0 : 0.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 5.0 : 0.0 ) : idx;
	idx = y == 0 ? 0.0 : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteSuperMarioWalk3( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 31 ? ( x <= 7 ? 40960.0 : 42.0 ) : idx;
	idx = y == 30 ? ( x <= 7 ? 43520.0 : 58.0 ) : idx;
	idx = y == 29 ? ( x <= 7 ? 43648.0 : 62.0 ) : idx;
	idx = y == 28 ? ( x <= 7 ? 43648.0 : 2730.0 ) : idx;
	idx = y == 27 ? ( x <= 7 ? 62784.0 : 253.0 ) : idx;
	idx = y == 26 ? ( x <= 7 ? 63440.0 : 4085.0 ) : idx;
	idx = y == 25 ? ( x <= 7 ? 55248.0 : 16383.0 ) : idx;
	idx = y == 24 ? ( x <= 7 ? 55252.0 : 16351.0 ) : idx;
	idx = y == 23 ? ( x <= 7 ? 65492.0 : 1365.0 ) : idx;
	idx = y == 22 ? ( x <= 7 ? 65364.0 : 1367.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 64832.0 : 1023.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 21504.0 : 15.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 43520.0 : 12325.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 38208.0 : 64662.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 21840.0 : 64922.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 21844.0 : 65114.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 21844.0 : 30298.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 38228.0 : 5722.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 42325.0 : 1902.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43605.0 : 682.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 44031.0 : 682.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 44031.0 : 17066.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 43775.0 : 21162.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 43772.0 : 21866.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 43392.0 : 21866.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 42640.0 : 21866.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 23189.0 : 21866.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 43605.0 : 21824.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 2389.0 : 0.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 84.0 : 0.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 84.0 : 0.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 336.0 : 0.0 ) : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteSuperMarioWalk2( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 31 ? 0.0 : idx;
	idx = y == 30 ? ( x <= 7 ? 40960.0 : 42.0 ) : idx;
	idx = y == 29 ? ( x <= 7 ? 43520.0 : 58.0 ) : idx;
	idx = y == 28 ? ( x <= 7 ? 43648.0 : 62.0 ) : idx;
	idx = y == 27 ? ( x <= 7 ? 43648.0 : 2730.0 ) : idx;
	idx = y == 26 ? ( x <= 7 ? 62784.0 : 253.0 ) : idx;
	idx = y == 25 ? ( x <= 7 ? 63440.0 : 4085.0 ) : idx;
	idx = y == 24 ? ( x <= 7 ? 55248.0 : 16383.0 ) : idx;
	idx = y == 23 ? ( x <= 7 ? 55252.0 : 16351.0 ) : idx;
	idx = y == 22 ? ( x <= 7 ? 65492.0 : 1365.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 65360.0 : 1367.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 64832.0 : 1023.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 43520.0 : 15.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 38464.0 : 22.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 21904.0 : 26.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 21904.0 : 90.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 21904.0 : 106.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 21904.0 : 125.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 21904.0 : 255.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 21920.0 : 767.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 22176.0 : 2815.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 23200.0 : 2751.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 43680.0 : 2725.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 43648.0 : 661.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 27136.0 : 341.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 23040.0 : 85.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 26624.0 : 21.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 41984.0 : 86.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 21504.0 : 81.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 21760.0 : 1.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 21760.0 : 21.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 20480.0 : 21.0 ) : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteSuperMarioWalk1( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 31 ? 0.0 : idx;
	idx = y == 30 ? 0.0 : idx;
	idx = y == 29 ? ( x <= 7 ? 32768.0 : 170.0 ) : idx;
	idx = y == 28 ? ( x <= 7 ? 43008.0 : 234.0 ) : idx;
	idx = y == 27 ? ( x <= 7 ? 43520.0 : 250.0 ) : idx;
	idx = y == 26 ? ( x <= 7 ? 43520.0 : 10922.0 ) : idx;
	idx = y == 25 ? ( x <= 7 ? 54528.0 : 1015.0 ) : idx;
	idx = y == 24 ? ( x <= 7 ? 57152.0 : 16343.0 ) : idx;
	idx = y == 23 ? ( x <= 7 ? 24384.0 : 65535.0 ) : idx;
	idx = y == 22 ? ( x <= 7 ? 24400.0 : 65407.0 ) : idx;
	idx = y == 21 ? ( x <= 7 ? 65360.0 : 5463.0 ) : idx;
	idx = y == 20 ? ( x <= 7 ? 64832.0 : 5471.0 ) : idx;
	idx = y == 19 ? ( x <= 7 ? 62464.0 : 4095.0 ) : idx;
	idx = y == 18 ? ( x <= 7 ? 43264.0 : 63.0 ) : idx;
	idx = y == 17 ? ( x <= 7 ? 22080.0 : 6.0 ) : idx;
	idx = y == 16 ? ( x <= 7 ? 22080.0 : 25.0 ) : idx;
	idx = y == 15 ? ( x <= 7 ? 22096.0 : 4005.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 22160.0 : 65365.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 23184.0 : 65365.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 23168.0 : 64853.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 27264.0 : 64853.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 43648.0 : 598.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 43648.0 : 682.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 43648.0 : 426.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 43605.0 : 2666.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 43605.0 : 2710.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 43605.0 : 681.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 10837.0 : 680.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 85.0 : 340.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 5.0 : 340.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 1.0 : 5460.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 0.0 : 5460.0 ) : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteMarioJump( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 0.0 : 64512.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 40960.0 : 64554.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43008.0 : 64170.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 21504.0 : 21727.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 56576.0 : 22495.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 23808.0 : 32639.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 62720.0 : 5471.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 61440.0 : 2047.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 38224.0 : 405.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 21844.0 : 16982.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 21855.0 : 17066.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 39487.0 : 23470.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 43596.0 : 23210.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 43344.0 : 23210.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 43604.0 : 42.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 43524.0 : 0.0 ) : idx;

	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteMarioWalk3( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 43008.0 : 10.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43520.0 : 682.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 54528.0 : 55.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 63296.0 : 1015.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 55104.0 : 4063.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 64832.0 : 343.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 64512.0 : 255.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 42320.0 : 5.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 42335.0 : 16214.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 58687.0 : 15722.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 43535.0 : 1066.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 43648.0 : 1450.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 43680.0 : 1450.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 2708.0 : 1448.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 84.0 : 0.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 336.0 : 0.0 ) : idx;
												   
	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 106, 107.0,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52.0, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157.0, 37 ) : color;
}

void SpriteMarioWalk2( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? ( x <= 7 ? 43008.0 : 10.0 ) : idx;
	idx = y == 14 ? ( x <= 7 ? 43520.0 : 682.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 54528.0 : 55.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 63296.0 : 1015.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 55104.0 : 4063.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 64832.0 : 343.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 64512.0 : 255.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 25856.0 : 5.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 38208.0 : 22.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 42304.0 : 235.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 38208.0 : 170.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 62848.0 : 171.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 62976.0 : 42.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 43008.0 : 21.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 21504.0 : 85.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 21504.0 : 1.0 ) : idx;
										   
	idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );

	color = idx == 1.0 ? RGB( 106, 107.0,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52.0, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157.0, 37 ) : color;
}

void SpriteMarioWalk1( inout vec3 color, int x, int y )
{
	float idx = 0.0;
	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 40960.0 : 42.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 43008.0 : 2730.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 21504.0 : 223.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 56576.0 : 4063.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 23808.0 : 16255.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 62720.0 : 1375.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 61440.0 : 1023.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 21504.0 : 793.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 22272.0 : 4053.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 23488.0 : 981.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 43328.0 : 170.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 43584.0 : 170.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 10832.0 : 42.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 16400.0 : 5.0 ) : idx;
	idx = y == 0 ? ( x <= 7 ? 16384.0 : 21.0 ) : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 106, 107,  4 ) : color;
	color = idx == 2.0 ? RGB( 177,  52, 37 ) : color;
	color = idx == 3.0 ? RGB( 227, 157, 37 ) : color;
}

void SpriteMario( inout vec3 color, int x, int y, int frame )
{    
	if ( frame == 0 )
    {
		SpriteMarioWalk1( color, x, y );
	}
    else if ( frame == 1 ) 
    {
        SpriteMarioWalk2( color, x, y );
    }
    else if ( frame == 2 ) 
    {
        SpriteMarioWalk3( color, x, y );
    }
    else
    {
        SpriteMarioJump( color, x, y );
    }
}

void SpriteSuperMario( inout vec3 color, int x, int y, int frame )
{    
	if ( frame == 0 )
    {
		SpriteSuperMarioWalk1( color, x, y );
	}
    else if ( frame == 1 ) 
    {
        SpriteSuperMarioWalk2( color, x, y );
    }
    else if ( frame == 2 ) 
    {
        SpriteSuperMarioWalk3( color, x, y );
    }
    else
    {
        SpriteSuperMarioJump( color, x, y );
    }
}

void SpriteCoin0( inout vec3 color, int x, int y )
{
    float idx = 0.0;
   	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 32768.0 : 1.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 32768.0 : 1.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 28672.0 : 5.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 28672.0 : 5.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 24576.0 : 5.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 32768.0 : 1.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 32768.0 : 1.0 ) : idx;
	idx = y == 0 ? 0.0 : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 181, 49,   33 ) : color;
	color = idx == 2.0 ? RGB( 230, 156,  33 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteCoin1( inout vec3 color, int x, int y )
{
    float idx = 0.0;
	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 32768.0 : 2.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 43008.0 : 42.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 59392.0 : 41.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 47616.0 : 166.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 59392.0 : 41.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 43008.0 : 42.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 40960.0 : 10.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 32768.0 : 2.0 ) : idx;
	idx = y == 0 ? 0.0 : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 181, 49,   33 ) : color;
	color = idx == 2.0 ? RGB( 230, 156,  33 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteCoin2( inout vec3 color, int x, int y )
{
    float idx = 0.0;
	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 49152.0 : 1.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 49152.0 : 1.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 61440.0 : 7.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 49152.0 : 1.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 49152.0 : 1.0 ) : idx;
	idx = y == 0 ? 0.0 : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 181, 49,   33 ) : color;
	color = idx == 2.0 ? RGB( 230, 156,  33 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteCoin3( inout vec3 color, int x, int y )
{
    float idx = 0.0;
	idx = y == 15 ? 0.0 : idx;
	idx = y == 14 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 13 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 12 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 11 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 10 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 9 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 8 ? ( x <= 7 ? 0.0 : 3.0 ) : idx;
	idx = y == 7 ? ( x <= 7 ? 0.0 : 3.0 ) : idx;
	idx = y == 6 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 5 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 4 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 3 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 2 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 1 ? ( x <= 7 ? 0.0 : 2.0 ) : idx;
	idx = y == 0 ? 0.0 : idx;

    idx = SPRITE_DEC( mod( float( x ), 8.0 ), idx );
    
	color = idx == 1.0 ? RGB( 181, 49,   33 ) : color;
	color = idx == 2.0 ? RGB( 230, 156,  33 ) : color;
	color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteCoin( inout vec3 color, int x, int y, int frame )
{    
	if ( frame == 0 )
    {
		SpriteCoin0( color, x, y );
	}
    else if ( frame == 1 ) 
    {
        SpriteCoin1( color, x, y );
    }
    else if ( frame == 2 ) 
    {
        SpriteCoin2( color, x, y );
    }
    else
    {
        SpriteCoin3( color, x, y );
    }
}

void DrawPipe( inout vec3 color, int tileX, int tileY, int pixelX, int pixelY, int h )
{
    int pipeX = pixelX - tileX * 16;
    int pipeY = pixelY - tileY * 16;    
    if ( pipeX >= 0 && pipeX <= 31 && pipeY >= 0 && pipeY <= 31 + h * 16 )
    {
        SpritePipe( color, pipeX, pipeY, h );
    }
}

void SpriteBrick( inout vec3 color, int x, int y )
{    
	int ymod4 = int( mod( float( y ), 4.0 ) );    
    int xmod8 = int( mod( float( x ), 8.0 ) );
    int ymod8 = int( mod( float( y ), 8.0 ) );
    
    // dark orange
    float idx = 2.0;
   
    // black
    idx = ymod4 == 0 ? 1.0 : idx;
    idx = xmod8 == ( ymod8 < 4 ? 3 : 7 ) ? 1.0 : idx;

    // light orange
    idx = y == 15 ? 3.0 : idx;

    color = idx == 1.0 ? RGB( 0,     0,   0 ) : color;
	color = idx == 2.0 ? RGB( 231,  90,  16 ) : color;
	color = idx == 3.0 ? RGB( 247, 214, 181 ) : color;
}

void DrawCastle( inout vec3 color, int x, int y )
{
    if ( x >= 0 && x < 80 && y >= 0 && y < 80 )
    {
        int ymod4    = int( mod( float( y ), 4.0 ) );
        int xmod8    = int( mod( float( x ), 8.0 ) );
        int xmod16_4 = int( mod( float( x + 4 ), 16.0 ) );
        int xmod16_3 = int( mod( float( x + 5 ), 16.0 ) );
        int ymod8    = int( mod( float( y ), 8.0 ) );
        
        // dark orange
        float idx = 2.0;

        // black
        idx = ymod4 == 0 && y <= 72 && ( y != 44 || xmod16_3 > 8 ) ? 1.0 : idx;
        idx = x >= 24 && x <= 32 && y >= 48 && y <= 64 ? 1.0 : idx;
        idx = x >= 48 && x <= 56 && y >= 48 && y <= 64 ? 1.0 : idx;
        idx = x >= 32 && x <= 47 && y <= 25 ? 1.0 : idx;
        idx = xmod8 == ( ymod8 < 4 ? 3 : 7 ) && y <= 72 && ( xmod16_3 > 8 || y <= 40 || y >= 48 ) ? 1.0 : idx;  
        
        // white
        idx = y == ( xmod16_4 < 8 ? 47 : 40 ) ? 3.0 : idx;
        idx = y == ( xmod16_4 < 8 ? 79 : 72 ) ? 3.0 : idx;
        idx = xmod8 == 3 && y >= 40 && y <= 47 ? 3.0 : idx;
        idx = xmod8 == 3 && y >= 72 ? 3.0 : idx;
        
        // transparent
        idx = ( x < 16 || x >= 64 ) && y >= 48 ? 0.0 : idx;
        idx = x >= 4  && x <= 10 && y >= 41 && y <= 47 ? 0.0 : idx;
        idx = x >= 68 && x <= 74 && y >= 41 && y <= 47 ? 0.0 : idx;             
        idx = y >= 73 && xmod16_3 > 8 ? 0.0 : idx;
        
		color = idx == 1.0 ? RGB(   0,   0,   0 ) : color;
		color = idx == 2.0 ? RGB( 231,  90,  16 ) : color;
		color = idx == 3.0 ? RGB( 247, 214, 181 ) : color;
    }
}

void DrawGoomba( inout vec3 color, int x, int y, int frame )
{
    if ( x >= 0 && x <= 15 )
    {
        SpriteGoomba( color, x, y, frame );
    }
}

void DrawKoopa( inout vec3 color, int x, int y, int frame )
{
    if ( x >= 0 && x <= 15 )
    {
        SpriteKoopa( color, x, y, frame );
    }
}

void MarioLand( inout int jumpOffset, float time, float startTime, float amplitude )
{
    float timeLength = amplitude / 120.0;
    if ( time >= startTime && time <= startTime + timeLength )
    {
        float t = 0.5 * ( time - startTime ) / timeLength + 0.5;
       	jumpOffset = int( sin( t * 3.14 ) * amplitude );
    }
}

void MarioJump( inout int jumpOffset, float time, float startTime, float scale )
{
    float timeLength = 1.5  * scale;
    float amplitude  = 76.0 * scale;
    if ( time >= startTime && time <= startTime + timeLength )
    {
        float t = ( time - startTime ) / timeLength;
        jumpOffset = int( sin( t * 3.14 ) * amplitude );
    }
}

void GoombaWalk( inout vec3 color, int worldX, int worldY, float time, int goombaFrame, int startX, float lifeTime )
{
    if ( lifeTime > 0.0 )
    {
    	goombaFrame = time > lifeTime + 0.0 ? 2 : goombaFrame;
    	goombaFrame = time > lifeTime + 0.6 ? 3 : goombaFrame;
    	time = min( time, lifeTime );
    }
    
    int x = worldX - startX + int( time * GOOMBA_SPEED );
    DrawGoomba( color, x, worldY - 16, goombaFrame );    
}

void KoopaWalk( inout vec3 color, int worldX, int worldY, float time, int goombaFrame, int startX )
{
    int x = worldX - startX + int( time * GOOMBA_SPEED );
    DrawKoopa( color, x, worldY - 16, goombaFrame );    
}

void GoombaPatrol( inout vec3 color, int worldX, int worldY, float time, float timeOffset, int goombaFrame, int startX, int endX, float lifeTime )
{    
    if ( lifeTime > 0.0 )
    {
    	goombaFrame = time > lifeTime + 0.0 ? 2 : goombaFrame;
    	goombaFrame = time > lifeTime + 0.6 ? 3 : goombaFrame;
    	time = min( time, lifeTime );
    }

    float segment = float( endX - 16 - startX );
    int x = worldX - startX - int( abs( mod( ( time + timeOffset ) * GOOMBA_SPEED, 2.0 * segment ) - segment ) ); 
    DrawGoomba( color, x, worldY - 16, goombaFrame );
}

void DrawCoin( inout vec3 color, int coinX, int coinY, int coinFrame, float time, float startTime )
{
   	float t = clamp( ( time - startTime ) / 0.8, 0.0, 1.0 );
    t = 1.0 - abs( 2.0 * t - 1.0 );
    
    coinY -= int( t * 64.0 );
    if ( coinX >= 0 && coinX <= 15 && time >= startTime + 0.1 )
    {   
        SpriteCoin( color, coinX, coinY, coinFrame );
    }
}

void DrawHitQuestion( inout vec3 color, int questionX, int questionY, float time, float questionT, float questionHitTime )
{
	float t = clamp( ( time - questionHitTime ) / 0.25, 0.0, 1.0 );
    t = 1.0 - abs( 2.0 * t - 1.0 );
        
    questionY -= int( t * 8.0 );
    if ( questionX >= 0 && questionX <= 15 )
    {            
    	if ( time >= questionHitTime )
        {                
        	SpriteQuestion( color, questionX, questionY, 1.0 );
            if ( questionX >= 3 && questionX <= 12 && questionY >= 1 && questionY <= 15 )
            {
                color = RGB( 231, 90, 16 );
            }
        }
        else
        {
         	SpriteQuestion( color, questionX, questionY, questionT );
        }
    }
}

void DrawW( inout vec3 color, int x, int y )
{
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if (    ( x <= 3 || x >= 10 ) 
             || ( x >= 4 && x <= 5 && y >= 2 && y <= 7 )
             || ( x >= 8 && x <= 9 && y >= 2 && y <= 7 )
             || ( x >= 6 && x <= 7 && y >= 4 && y <= 9 )
           )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawO( inout vec3 color, int x, int y )
{
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if (    ( x <= 1 || x >= 12 ) && ( y >= 2 && y <= 11 )
             || ( x >= 2 && x <= 4 )
             || ( x >= 9 && x <= 11 )
             || ( y <= 1 || y >= 11 ) && ( x >= 2 && x <= 11 )
           )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawR( inout vec3 color, int x, int y )
{
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if (    ( x <= 3 )
			 || ( y >= 12 && x <= 11 )
             || ( x >= 10 && y >= 6 && y <= 11 )
             || ( x >= 8  && x <= 9 && y <= 7 )
             || ( x <= 9  && y >= 4 && y <= 5 )
             || ( x >= 8  && y <= 1 )
             || ( x >= 6  && x <= 11 && y >= 2 && y <= 3 )
           )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawL( inout vec3 color, int x, int y )
{
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if ( x <= 3 || y <= 1 )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawD( inout vec3 color, int x, int y )
{    
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
    	color = RGB( 255, 255, 255 );        
        
        if (    ( x >= 4 && x <= 7 && y >= 2 && y <= 11 ) 
           	 || ( x >= 8 && x <= 9 && y >= 4 && y <= 9 ) 
             || ( x >= 12 && ( y <= 3 || y >= 10 ) )
             || ( x >= 10 && ( y <= 1 || y >= 12 ) )
           )
        {
            color = RGB( 0, 0, 0 );
        }
    }
}

void Draw1( inout vec3 color, int x, int y )
{    
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if (    ( y <= 1 )
             || ( x >= 5 && x <= 8 )
             || ( x >= 3 && x <= 4 && y >= 10 && y <= 11 )
           )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawM( inout vec3 color, int x, int y )
{    
    if ( x >= 0 && x < 14 && y >= 0 && y < 14 )
    {
        if ( y >= 4 && y <= 7 )
        {
            color = RGB( 255, 255, 255 );
        }
    }
}

void DrawIntro( inout vec3 color, int x, int y, int screenWidth, int screenHeight )
{
    color = RGB( 0, 0, 0 );
        
    int offset 	= 18;     
    int textX 	= x - ( screenWidth - offset * 8 - 7 ) / 2;
    int textY 	= y - ( screenHeight - 7 ) / 2 - 16 * 2;
    int marioX	= textX - offset * 4;
    int marioY	= textY + 16 * 3;
	
    DrawW( color, textX - offset * 0, textY );
    DrawO( color, textX - offset * 1, textY );
    DrawR( color, textX - offset * 2, textY );
    DrawL( color, textX - offset * 3, textY );
    DrawD( color, textX - offset * 4, textY );
    Draw1( color, textX - offset * 6, textY );
    DrawM( color, textX - offset * 7, textY );
    Draw1( color, textX - offset * 8, textY );
    
    if ( marioX >= 0 && marioX <= 15 )
    {
    	SpriteSuperMario( color, marioX, marioY, 0 );
    }
}

void DrawGame( inout vec3 color, float time, int pixelX, int pixelY, int screenWidth, int screenHeight )
{
    float mushroomPauseStart 	= 16.25;    
    float mushroomPauseLength 	= 2.0;    
    
    int cameraX 		= int( min( ( time - clamp( time - mushroomPauseStart, 0.0, mushroomPauseLength ) ) * MARIO_SPEED - 240.0, 3152.0 ) );    
    int worldX 			= pixelX + cameraX;
    int worldY  		= pixelY - 8;
    int tileX			= worldX / 16;
    int tileY			= worldY / 16;
    int worldXMod16		= int( mod( float( worldX ), 16.0 ) );
    int worldYMod16 	= int( mod( float( worldY ), 16.0 ) );


    // default background color
    color = RGB( 92, 148, 252 );

    
    // draw big hills
    int hillX = int( mod( float( worldX ), 768.0 ) );
    int hillY = worldY - 16;    
    SpriteHill( color, hillX, hillY );
    
    // draw small hills
    hillX = int( mod( float( worldX - 240 ), 768.0 ) );
    hillY = worldY;    
    SpriteHill( color, hillX, hillY );    
    
    // draw single clouds
    int cloundX = int( mod( float( worldX - 296 ), 768.0 ) );
    int cloundY = worldY - 168;
    SpriteCloud1( color, cloundX, cloundY, false );
    cloundX = int( mod( float( worldX - 904 ), 768.0 ) );
    cloundY = worldY - 152;
    SpriteCloud1( color, cloundX, cloundY, false );    
    
    // draw double clouds
    cloundX = int( mod( float( worldX - 584 ), 768.0 ) );
    cloundY = worldY - 168;
    SpriteCloud2( color, cloundX, cloundY, false );
    
    // draw tripple clouds
    cloundX = int( mod( float( worldX - 440 ), 768.0 ) );
    cloundY = worldY - 152;
    SpriteCloud3( color, cloundX, cloundY, false );
    
    // draw single bushes
    int bushX = int( mod( float( worldX - 376 ), 768.0 ) );
    int bushY = worldY - 8;    
    SpriteCloud1( color, bushX, bushY, true );
    
    // draw double bushes
    bushX = int( mod( float( worldX - 664 ), 768.0 ) );
    SpriteCloud2( color, bushX, bushY, true );    
    
    // draw tripple bushes
    bushX = int( mod( float( worldX - 184 ), 768.0 ) );
    SpriteCloud3( color, bushX, bushY, true );
    
    // draw flag pole
    if ( worldX >= 3175 && worldX <= 3176 && worldY <= 176 )        
    {
        color = RGB( 189, 255, 24 );
    }
    
    // draw flag
    int flagX = worldX - 3160;
    int flagY = worldY - 160;
    if ( flagX >= 0 && flagX <= 15 )
    {
    	SpriteFlag( color, flagX, flagY );
    }     
    
    // draw blocks
   	if (    ( tileX >= 134 && tileX < 138 && tileX - 132 > tileY )
         || ( tileX >= 140 && tileX < 144 && 145 - tileX > tileY )
         || ( tileX >= 148 && tileX < 153 && tileX - 146 > tileY && tileY < 5 )
         || ( tileX >= 155 && tileX < 159 && 160 - tileX > tileY ) 
         || ( tileX >= 181 && tileX < 190 && tileX - 179 > tileY && tileY < 9 )
         || ( tileX == 198 && tileY == 1 )
       )
    {
        SpriteBlock( color, worldXMod16, worldYMod16 );
    }    
    
    // draw pipes
    DrawPipe( color,  28, 1, worldX, worldY, 0 );
    DrawPipe( color,  38, 1, worldX, worldY, 1 );
    DrawPipe( color,  46, 1, worldX, worldY, 2 );
    DrawPipe( color,  57, 1, worldX, worldY, 2 );
    DrawPipe( color, 163, 1, worldX, worldY, 0 );
    DrawPipe( color, 179, 1, worldX, worldY, 0 );
    
    // draw mushroom
    float mushroomStart = 15.7;    
    if ( time >= mushroomStart && time <= 17.0 )
    {
        float jumpTime = 0.5;
        
        int mushroomX = worldX - 1248;
        int mushroomY = worldY - 4 * 16;
        if ( time >= mushroomStart )
        {
            mushroomY = worldY - 4 * 16 - int( 16.0 * clamp( ( time - mushroomStart ) / 0.5, 0.0, 1.0 ) );
        }
        if ( time >= mushroomStart + 0.5 )
        {
            mushroomX -= int( MARIO_SPEED * ( time - mushroomStart - 0.5 ) );
        }
        if ( time >= mushroomStart + 0.5 + 0.4 )
        {
            mushroomY = mushroomY + int( sin( ( ( time - mushroomStart - 0.5 - 0.4 ) ) * 3.14 ) * 4.0 * 16.0 );
        }
        
        if ( mushroomX >= 0 && mushroomX <= 15 )
        {
        	SpriteMushroom( color, mushroomX, mushroomY );
        }
    }
    
    // draw coins
    int coinFrame = int( mod( time * 12.0, 4.0 ) );
    DrawCoin( color, worldX -  352, worldY - 4 * 16, coinFrame, time,  5.5 );
    DrawCoin( color, worldX - 1696, worldY - 4 * 16, coinFrame, time, 22.5 );
    DrawCoin( color, worldX - 2720, worldY - 4 * 16, coinFrame, time, 34.0 );
    
    // draw hitted questions
    float questionT = clamp( sin( time * 6.0 ), 0.0, 1.0 );
    DrawHitQuestion( color, worldX - 352,  worldY - 4 * 16, time, questionT,  5.3 );
    DrawHitQuestion( color, worldX - 1248, worldY - 4 * 16, time, questionT, 15.4 );
    DrawHitQuestion( color, worldX - 1696, worldY - 4 * 16, time, questionT, 22.4 );
    DrawHitQuestion( color, worldX - 2720, worldY - 4 * 16, time, questionT, 33.9 );
    
    // draw questions
    if (    ( tileY == 4 && ( tileX == 16 || tileX == 20 || tileX == 109 || tileX == 112 ) )
         || ( tileY == 8 && ( tileX == 21 || tileX == 94 || tileX == 109 ) )
         || ( tileY == 8 && ( tileX >= 129 && tileX <= 130 ) )
       )
    {
        SpriteQuestion( color, worldXMod16, worldYMod16, questionT );
    }
    
    // draw bricks
   	if (    ( tileY == 4 && ( tileX == 19 || tileX == 21 || tileX == 23 || tileX == 77 || tileX == 79 || tileX == 94 || tileX == 118 || tileX == 168 || tileX == 169 || tileX == 171 ) )
         || ( tileY == 8 && ( tileX == 128 || tileX == 131 ) )
         || ( tileY == 8 && ( tileX >= 80 && tileX <= 87 ) )
         || ( tileY == 8 && ( tileX >= 91 && tileX <= 93 ) )
         || ( tileY == 4 && ( tileX >= 100 && tileX <= 101 ) )
         || ( tileY == 8 && ( tileX >= 121 && tileX <= 123 ) )
         || ( tileY == 4 && ( tileX >= 129 && tileX <= 130 ) )
       )
    {
        SpriteBrick( color, worldXMod16, worldYMod16 );
    }   
    
    DrawCastle( color, worldX - 3232, worldY - 16 );

    // draw ground
    if ( tileY <= 0
         && !( tileX >= 69  && tileX < 71 )
         && !( tileX >= 86  && tileX < 89 ) 
         && !( tileX >= 153 && tileX < 155 ) 
       )
    {
        SpriteGround( color, worldXMod16, worldYMod16 );
    }    
    
    // draw Goomba
    int goombaFrame = int( mod( time * 5.0, 2.0 ) );
    GoombaPatrol( color, worldX, worldY, time, 6.6, goombaFrame, 638, 738, 0.0 );
    GoombaPatrol( color, worldX, worldY, time, 6.3, goombaFrame, 766, 914 - 24, 0.0 );
    GoombaPatrol( color, worldX, worldY, time, 6.3, goombaFrame, 766 + 24, 914, 10.3 );    
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 435, 0.0 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2150, 20.29 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2150 + 24, 0.0 );
    KoopaWalk(  color, worldX, worldY, time, goombaFrame, 2370 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2540, 23.5 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2540 + 24, 0.0 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2760, 25.3 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2760 + 24, 0.0 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2850, 0.0 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 2850 + 24, 26.3 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 3850, 0.0 );
    GoombaWalk( color, worldX, worldY, time, goombaFrame, 3850 + 24, 0.0 );

    // draw mario
    int marioJumpOffset = 0;
    MarioJump( marioJumpOffset, time, 4.2, 0.45 );
    MarioJump( marioJumpOffset, time, 5.0, 0.5 );
    MarioJump( marioJumpOffset, time, 6.05, 0.7 );
    MarioJump( marioJumpOffset, time, 7.8, 0.8 );
    MarioJump( marioJumpOffset, time, 9.0, 1.0 );
    MarioJump( marioJumpOffset, time, 10.3,	0.3 );
    MarioJump( marioJumpOffset, time, 11.05, 1.0 );
    MarioJump( marioJumpOffset, time, 13.62, 0.45 );   
    MarioJump( marioJumpOffset, time, 15.1, 0.5 );
    MarioJump( marioJumpOffset, time, 18.7, 0.6 );
    MarioJump( marioJumpOffset, time, 19.65, 0.45 );
    MarioJump( marioJumpOffset, time, 20.29, 0.3 );
    MarioJump( marioJumpOffset, time, 21.8, 0.35 );
    MarioJump( marioJumpOffset, time, 22.3, 0.35 );    
    MarioJump( marioJumpOffset, time, 23.0, 0.40 );
    MarioJump( marioJumpOffset, time, 23.5, 0.3 );
    MarioJump( marioJumpOffset, time, 24.7, 0.45 );
    MarioJump( marioJumpOffset, time, 25.3, 0.3 );
    MarioJump( marioJumpOffset, time, 25.75, 0.4 );
    MarioJump( marioJumpOffset, time, 26.3, 0.25 );
    
    float marioBigJump1 = 27.1;
    MarioJump( marioJumpOffset, time, marioBigJump1, 1.0 );
    MarioJump( marioJumpOffset, time, marioBigJump1 + 1.0, 0.6 );
    MarioLand( marioJumpOffset, time, marioBigJump1 + 1.0 + 0.45, 109.0 );    
    
    float marioBigJump2 = 29.75;
    MarioJump( marioJumpOffset, time, marioBigJump2, 1.0 );
    MarioJump( marioJumpOffset, time, marioBigJump2 + 1.0, 0.6 );
    MarioLand( marioJumpOffset, time, marioBigJump2 + 1.0 + 0.45, 109.0 );    
    
	MarioJump( marioJumpOffset, time, 32.3, 0.7 );
    MarioJump( marioJumpOffset, time, 33.7, 0.3 );
    MarioJump( marioJumpOffset, time, 34.15, 0.45 );
    
    float marioBigJump3 = 35.05;
    MarioJump( marioJumpOffset, time, marioBigJump3, 1.0 );
    MarioJump( marioJumpOffset, time, marioBigJump3 + 1.2, 0.89 );
    MarioJump( marioJumpOffset, time, marioBigJump3 + 1.2 + 0.75, 0.5 );
    MarioLand( marioJumpOffset, time, marioBigJump3 + 1.2 + 0.75 + 0.375, 150.0 );    
    MarioJump( marioJumpOffset, time, 38.7, 0.45 );

    int marioBase = 0;
    if ( time >= marioBigJump1 + 1.0 && time < marioBigJump1 + 1.0 + 0.45 )
    {
        marioBase = 16 * 4;
    }
    if ( time >= marioBigJump2 + 1.0 && time < marioBigJump2 + 1.0 + 0.45 )
    {
        marioBase = 16 * 4;
    }    
    if ( time >= marioBigJump3 + 1.2 && time < marioBigJump3 + 1.2 + 0.75 )
    {
        marioBase = 16 * 3;
    }    
    if ( time >= marioBigJump3 + 1.2 + 0.75 && time < marioBigJump3 + 1.2 + 0.75 + 0.375 )
    {
        marioBase = 16 * 7;
    }

    int marioX		= pixelX - 112;
    int marioY		= pixelY - 16 - 8 - marioBase - marioJumpOffset;    
    int marioFrame 	= marioJumpOffset == 0 ? int( mod( time * 10.0, 3.0 ) ) : 3;
    int superMario 	= 0;
    if ( time >= mushroomPauseStart && time <= mushroomPauseStart + mushroomPauseLength )
    {
    	marioFrame = 1;
    }    
    if ( time > mushroomPauseStart + 0.7 )
    {
        float t = time - mushroomPauseStart - 0.7;
    	superMario = mod( t, 0.2 ) <= mix( 0.0, 0.2, clamp( t / 1.3, 0.0, 1.0 ) ) ? 1 : 0;
    }    
    if ( marioX >= 0 && marioX <= 15 && cameraX < 3152 )
    {
        if ( superMario == 1 )
        {
            SpriteSuperMario( color, marioX, marioY, marioFrame );
        }
        else
        {
        	SpriteMario( color, marioX, marioY, marioFrame );
        }
    }
}

vec2 CRTCurveUV( vec2 uv )
{
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs( uv.yx ) / vec2( 6.0, 4.0 );
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void DrawVignette( inout vec3 color, vec2 uv )
{    
    float vignette = uv.x * uv.y * ( 1.0 - uv.x ) * ( 1.0 - uv.y );
    vignette = clamp( pow( 16.0 * vignette, 0.3 ), 0.0, 1.0 );
    color *= vignette;
}

void DrawScanline( inout vec3 color, vec2 uv )
{
    float scanline 	= clamp( 0.95 + 0.05 * cos( 3.14 * ( uv.y + 0.008 * time ) * 240.0 * 1.0 ), 0.0, 1.0 );
    float grille 	= 0.85 + 0.15 * clamp( 1.5 * cos( 3.14 * uv.x * 640.0 * 1.0 ), 0.0, 1.0 );    
    color *= scanline * grille * 1.2;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
    // we want to see at least 256x224 (overscan) and we want multiples of pixel size
    float resMultX  = floor( resolution.x / 256.0 );
    float resMultY  = floor( resolution.y / 224.0 );
    float resRcp	= 1.0 / max( min( resMultX, resMultY ), 1.0 );
    
    float time			= time + 0.0;
    int screenWidth		= int( resolution.x * resRcp );
    int screenHeight	= int( resolution.y * resRcp );
    int pixelX 			= int( gl_FragCoord.x * resRcp );
    int pixelY 			= int( gl_FragCoord.y * resRcp );

    vec3 color = RGB( 92, 148, 252 );
 	DrawGame( color, time, pixelX, pixelY, screenWidth, screenHeight );
    if ( time < INTRO_LENGTH )
    {
        DrawIntro( color, pixelX, pixelY, screenWidth, screenHeight );
    }    

    
    // CRT effects (curvature, vignette, scanlines and CRT grille)
    /*
	vec2 crtUV = CRTCurveUV( uv );
    if ( crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0 )
    {
        color = vec3( 0.0, 0.0, 0.0 );
    }
	*/
    //DrawVignette( color, crtUV );
    //DrawScanline( color, uv );
    
	gl_FragColor.xyz 	= color;
    gl_FragColor.w		= 1.0;
}