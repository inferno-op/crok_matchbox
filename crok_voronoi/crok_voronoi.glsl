uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Speed;
uniform float Offset;
uniform float Type; // 5.0 
uniform int Octaves; // 1
uniform float Zoom; // 8.0
uniform float Detail; // 2.0

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time *.05 * Speed + Offset;

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

        o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o ); // animate

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
    vec2 p = gl_FragCoord.xy/iResolution.xy;
	vec2 center = (2.0*(p-.5));
    float c = fbm( Zoom * center );
	
    gl_FragColor = vec4( c,c,c, 1.0 );
}