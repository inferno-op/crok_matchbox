#version 120

// based on http://glsl.herokuapp.com/e#15053.5

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform int octaves;
uniform float som_persistence, som_zoom_small, som_zoom_large, som_seed, som_contrast, som_sharpness, som_blend, som_overall_zoom, som_large_blend;
uniform vec3 som_tint, som_large_tint;
#define PI 3.14159265
#define octaves 10
#define persistence 0.76

// voronoi parameters
float Type = 1.0; 
int Octaves = 10;
float Zoom = 25.;
float Detail = 2.0;
	


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

float rand(vec2 co){
	return fract(sin(som_seed + dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float interpolate( float a, float b, float x ) {
	float f = ( 1.0 - cos( x * PI ) ) * 0.5;
	return a * ( 1.0 - f ) + b * f;
}

float smoothnoise( vec2 co ) {
	co *= 0.01;
	float stepsize = ( 1.0 / resolution.x ) * 0.01;
	float corners = ( rand( ( co + vec2( stepsize ) ) ) + rand( ( co + vec2( stepsize, -stepsize ) ) ) + rand( ( co + vec2( -stepsize, stepsize ) ) ) + rand( ( co + vec2( -stepsize ) ) ) ) / 16.0;
	float sides = ( rand( ( co + vec2( stepsize, 0.0 ) ) ) + rand( ( co + vec2( -stepsize, 0.0 ) ) ) + rand( ( co + vec2( 0.0, stepsize ) ) ) + rand( ( co + vec2( 0.0, -stepsize ) ) ) ) / 8.0;
	float center = rand( co ) / 4.0;
	
	return corners + sides + center;
}

float interpolatednoise( vec2 co ) {
	float int_x = floor( co.x );
	float frac_x = fract( co.x );
	float int_y = floor( co.y );
	float frac_y = fract( co.y );
	
	float v1 = smoothnoise( vec2( int_x, int_y ) );
	float v2 = smoothnoise( vec2( int_x + 1.0, int_y ) );
	float v3 = smoothnoise( vec2( int_x, int_y + 1.0 ) );
	float v4 = smoothnoise( vec2( int_x + 1.0, int_y + 1.0 ) );
	
	float i1 = interpolate( v1, v2, frac_x );
	float i2 = interpolate( v3, v4, frac_x );
	return interpolate( i1, i2, frac_y );
}

float perlinnoise( vec2 co ) {
	float total = 0.0;
	
	for( int i = 0; i < octaves; i++ ) {
		float frequency = pow( 2.0, float( i ) );
		float amplitude = pow( persistence, float( i ) );
		total += interpolatednoise( vec2( co.x * frequency / som_zoom_small / som_overall_zoom, co.y * frequency / som_zoom_small / som_overall_zoom ) ) * amplitude;
	}
	
	return total;
}

bool inrange( float a, float minimum, float maximum ) {
	return ( a > minimum && a < maximum );
}


// Voronoi noises
// by Pietro De Nicola
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


float t = Type;

//
// the following parameters identify the voronoi you're watching
//
float function 			= mod(t,4.0);
bool  multiply_by_F1	= mod(t,8.0)  >= 4.0;
bool  inverse			= mod(t,16.0) >= 8.0;
float distance_type		= mod(t/16.0,4.0);



vec2 hash( vec2 p )
{
    p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return fract(sin(p)*43758.5453);
}

float voronoi( in vec2 x )
{
    vec2 n = floor( x );
    vec2 f = fract( x );

	float F1 = 8.0;
	float F2 = 8.0;
	
	
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2(i,j);
        vec2 o = hash( n + g );

        o = 0.5 + 0.5*sin( 1.0 + 6.2831*o ); // animate

		vec2 r = g - f + o;

		float d = 	distance_type < 1.0 ? dot(r,r)  :				// euclidean^2
				  	distance_type < 2.0 ? sqrt(dot(r,r)) :			// euclidean
					distance_type < 3.0 ? abs(r.x) + abs(r.y) :		// manhattan
					distance_type < 4.0 ? max(abs(r.x), abs(r.y)) :	// chebyshev
					0.0;

		if( d<F1 ) 
		{ 
			F2 = F1; 
			F1 = d; 
		}
		else if( d<F2 ) 
		{
			F2 = d;
		}
    }
	
	float c = function < 1.0 ? F1 : 
			  function < 2.0 ? F2 : 
			  function < 3.0 ? F2-F1 :
			  function < 4.0 ? (F1+F2)/2.0 : 
			  0.0;
		
	if( multiply_by_F1 )	c *= F1;
	if( inverse )			c = 1.0 - c;
	
    return c;
}

float fbm( in vec2 p )
{
	float s = 0.0;
	float m = 0.0;
	float a = 0.5;
	
	for( int i=0; i<Octaves; i++ )
	{
		s += a * voronoi(p);
		m += a;
		a *= 0.5;
		p *= Detail;
	}
	return s/m;
}


void main( void ) 
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - 0.5;
	float noise = perlinnoise( uv * 100. ) / 4.0;
	vec3 col = mix(vec3(0.5), vec3(noise), som_contrast);
	col =  overlay(col, som_tint);
	
    vec3 voronoi = vec3(fbm( Zoom / som_zoom_large * 2.*uv / som_overall_zoom));
	//col = mix(large_tint, vec3(voronoi), contrast);
	voronoi = mix(som_large_tint, voronoi, som_large_blend);
	col = mix(col, overlay(voronoi, col), som_blend* .2);
		
	
	gl_FragColor = vec4( col, voronoi );
}