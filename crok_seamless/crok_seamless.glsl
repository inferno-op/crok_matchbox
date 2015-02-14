#version 120

// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// One way to avoid texture tile repetition one using one small texture to cover a huge area.
// Based on Voronoise (https://www.shadertoy.com/view/Xd23Dh), a random offset is applied to
// the texture UVs per Voronoi cell. Distance to the cell is used to smooth the transitions
// between cells.
// It doesn't work with automatic mipmapping - one should compute derivatives by hand.

// based on https://www.shadertoy.com/view/4tsGzf

uniform sampler2D source;
uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform float blend, zoom, smoothness; 

vec2 resolution = vec2(adsk_result_w, adsk_result_h);


vec3 hash3( vec2 p ) { return fract(sin(vec3( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)), dot(p,vec2(419.2,371.9)) ))*43758.5453); }

vec3 textureNoTile( in vec2 x, float v )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
		
	float k = 1.0+63.0*pow(1.0-v,4.0);
	
	vec3 va = vec3(0.0);
	float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
		vec3 o = hash3( p + g );
        vec3 c = texture2D( source, .2*x + v*o.zy, -16.0 ).xyz;
		vec2 r = g - f + o.xy;
		float d = dot(r,r);
        float ww = 1.0 - smoothstep(0.0,2.0,dot(d,d));
        ww = pow( ww, 1.0 + 16.0*v * (2.0 - smoothness) );
		va += c*ww;
		wt += ww;
    }
	
    return va/wt;
}

void main( void )
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - 0.5;
        
	vec3 col = textureNoTile(zoom * uv, blend ).xyz;
	
	gl_FragColor = vec4( col, 1.0 );
}