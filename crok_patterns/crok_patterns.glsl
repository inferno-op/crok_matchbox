#version 120

// PolkaDot2D based on http://briansharpe.files.wordpress.com/2012/01/simplexpolkadotsample.jpg
// Simple loading screen based on https://www.shadertoy.com/view/XdBXzd by ndel
// ZigZag based on http://patriciogonzalezvivo.com/2015/thebookofshaders/edit.html#09/zigzag.frag by patriciogv
// iching based on http://patriciogonzalezvivo.com/2015/thebookofshaders/edit.html#09/iching-01.frag by patriciogv
// Truchet based on http://patriciogonzalezvivo.com/2015/thebookofshaders/edit.html#09/truchet.frag by patriciogv
// Binary Noise based on http://glslsandbox.com/e#27146.0


#define PI 3.14159265359
#define TWO_PI 6.28318530718

uniform float adsk_result_w, adsk_result_h, adsk_time, adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);


// global uniforms
uniform float speed;
uniform float offset;
uniform float scale;
uniform float aspect;
uniform float rot;
uniform vec2 pos;
uniform int pattern_type;

float time = adsk_time *.05 * speed + offset -1.0;

// polka dots uniforms
uniform float radius, dim, smooth;

// zigzag uniforms
uniform float zigzag_sharpness;
uniform float zigzag_style;

// loading screen uniforms
uniform float loading_inner;
uniform float loading_outer;
uniform float loading_sharpness;

// iching uniforms
uniform float iching_amount;
uniform float iching_detail;

// truchet uniforms
uniform int truchet_style;
uniform bool truchet_curve;
uniform float truchet_frequence, truchet_amplitude;

// binary uniforms
uniform float binary_seed;
uniform float binary_move;

float hash2(vec2 uv) {
	return fract(sin(uv.x * 15.78 + uv.y * 35.14) * 43758.23);
}

vec4 FAST32_hash_2D( vec2 gridcell )	//	generates a random number for each of the 4 cell corners
{
    //	gridcell is assumed to be an integer coordinate
    const vec2 OFFSET = vec2( 26.0, 161.0 );
    float DOMAIN = 71.0 * 0.02;
    const float SOMELARGEFLOAT = 951.135664;
    vec4 P = vec4( gridcell.xy, gridcell.xy + 1.0 );
    P = P - floor(P * ( 1.0 / DOMAIN )) * DOMAIN;	//	truncate the domain
    P += OFFSET.xyxy;								//	offset to interesting part of the noise
    P *= P;											//	calculate and return the hash
    return fract( P.xzxz * P.yyww * ( 1.0 / SOMELARGEFLOAT ) );
}

float SimplexPolkaDot2D( 	vec2 P,
                            float radius, 		//	radius range is 0.0->1.0
                            float max_dimness )	//	the maximal dimness of a dot ( 0.0->1.0   0.0 = all dots bright,  1.0 = maximum variation )
{
    //	simplex math based off Stefan Gustavson's and Ian McEwan's work at...
    //	http://github.com/ashima/webgl-noise

    //	simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;			// 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;			// (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;	// sqrt( 0.5 )	height of simplex triangle
    const float INV_SIMPLEX_TRI_HALF_EDGELEN = 2.4494897427831780981972840747059;	// sqrt( 0.75 )/(2.0*sqrt( 0.5 ))
    const vec3 SIMPLEX_POINTS = vec3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );		//	vertex info for simplex triangle

    //	establish our grid cell.
    P *= SIMPLEX_TRI_HEIGHT;		// scale space so we can have an approx feature size of 1.0  ( optional )
    vec2 Pi = floor( P + dot( P, vec2( SKEWFACTOR ) ) );

    //	establish vectors to the 4 corners of our simplex triangle
    vec2 v0 = ( Pi - dot( Pi, vec2( UNSKEWFACTOR ) ) - P);
    vec4 v0123_x = vec4( 0.0, SIMPLEX_POINTS.xyz ) + v0.x;
    vec4 v0123_y = vec4( 0.0, SIMPLEX_POINTS.yxz ) + v0.y;

    //	calculate the hash.
    vec4 hash = FAST32_hash_2D( Pi + time * .0005);

    //	apply user controls
    radius = INV_SIMPLEX_TRI_HALF_EDGELEN/radius * 1.2;		//	INV_SIMPLEX_TRI_HALF_EDGELEN here is to scale to a nice 0.0->1.0 range
    v0123_x *= radius;
    v0123_y *= radius;

    //	return a smooth falloff from the closest point.  ( we use a f(x)=(1.0-x*x)^3 falloff )
    vec4 point_distance = max( vec4( 0.0 ), 1.0 - ( v0123_x*v0123_x + v0123_y*v0123_y ) );
    point_distance = point_distance*point_distance*point_distance;
    return dot( 1.0 - hash * max_dimness, point_distance);
}

// begin loading screen
float movingRing(vec2 uv, float r1, float r2)
{
	#define SMOOTH(r) (mix(1.0, 0.0, smoothstep(loading_sharpness, 1.0, r)))
    vec2 d = (uv *250.0);
	float r = sqrt( dot( d, d ) );
    d = normalize(d);
    float theta = -atan(d.y,d.x);
    theta  = mod(-time+0.5*(1.0+theta/PI), 1.0);
    //anti aliasing for the ring's head (thanks to TDM !)
    theta -= max(theta - 1.0 + 1e-2, 0.0) * 200.0 * loading_sharpness;
    return theta*(SMOOTH(r/r2)-SMOOTH(r/r1));
}
// end loading screen

// begin zig zag
vec2 zigzag(vec2 zig_uv, float zigzag_zoom)
{
    zig_uv *= zigzag_zoom;
    if (fract(zig_uv.y * 0.5) > 0.5){
        zig_uv.x = zig_uv.x+0.5;
        zig_uv.y = 1.0-zig_uv.y;
    }
    return fract(zig_uv);
}

float fillY(vec2 _st, float _pct,float _antia)
{
  return  smoothstep( _pct-_antia, _pct, _st.y);
}
// end zig zag

//begin iching
float shape(vec2 st, float N){
    st = st*2.-1.;
    float a = atan(st.x,st.y)+PI;
    float r = TWO_PI/N;
    return abs(cos(floor(.5+a/r)*r-a)*length(st));
}

float box(vec2 st, vec2 size){
    return shape(st*size,4.);
}

float rect(vec2 _st, vec2 _size){
    _size = vec2(0.5)-_size* iching_detail * .50;
    vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st);
    uv *= smoothstep(_size,_size+vec2(1e-4),vec2(1.0)-_st);
    return uv.x*uv.y;
}

float hex(vec2 st, float a, float b, float c, float d, float e, float f){
    st = st*vec2(2.,6.);

    vec2 fpos = fract(st);
    vec2 ipos = floor(st);

    if (ipos.x == 1.0) fpos.x = 1.-fpos.x;
    if (ipos.y < 1.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),a);
    } else if (ipos.y < 2.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),b);
    } else if (ipos.y < 3.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),c);
    } else if (ipos.y < 4.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),d);
    } else if (ipos.y < 5.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),e);
    } else if (ipos.y < 6.0){
        return mix(box(fpos, vec2(0.84,1.)),box(fpos-vec2(0.03,0.),vec2(1.)),f);
    }
    return 0.0;
}

float hex(vec2 st, float N){
    float b[6];
    float remain = floor(mod(N,64.));
    for(int i = 0; i < 6; i++){
        b[i] = 0.0;
        b[i] = step(1.0,mod(remain,2.));
        remain = ceil(remain/2.);
    }
    return hex(st,b[0],b[1],b[2],b[3],b[4],b[5]);
}
//end iching

// begin truchet
vec2 rotate2D (vec2 _st, float _angle) {
    _st -= 0.5;
    _st =  mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) * _st;
    _st += 0.5;
    return _st;
}

vec2 tile (vec2 _st, float _zoom) {
    _st *= _zoom;
    return fract(_st);
}

vec2 rotateTilePattern(vec2 _st){

    //  Scale the coordinate system by 2x2 
    _st *= 2.0;

    //  Give each cell an index number
    //  according to its position
    float index = 0.0;    
    index += step(1., mod(_st.x,2.0));
    index += step(1., mod(_st.y,2.0))*2.0;

    //      |
    //  0   |   1
    //      |
    //--------------
    //      |
    //  2   |   3
    //      |

    // Make each cell between 0.0 - 1.0
    _st = fract(_st);

    // Rotate each cell according to the index
    if(index == 1.0){
        //  Rotate cell 1 by 90 degrees
        _st = rotate2D(_st,PI*0.5);
    } else if(index == 2.0){
        //  Rotate cell 2 by -90 degrees
        _st = rotate2D(_st,PI*-0.5);
    } else if(index == 3.0){
        //  Rotate cell 3 by 180 degrees
        _st = rotate2D(_st,PI);
    }

    return _st;
}
// end truchet

// begin binary
float random (vec2 st) 
{ 
    return fract(sin(dot(st, vec2(12.9898,78.233+0.0001 * binary_seed)))* 43758.5453123);
}

float eq(float v, float compareTo)
{
    return step(compareTo-1.,v) * step(v, compareTo+1.); 	
}
// end binary


void main()
{
	vec2 uv = (gl_FragCoord.xy / resolution.xy) - pos;
    vec4 col = vec4(0.0);
	uv.x *= adsk_result_frameratio;
	float rad_rot = (rot+180.0) * PI / 180.0; 
	mat2 rotation = mat2( cos(-rad_rot), -sin(-rad_rot), sin(-rad_rot), cos(-rad_rot));
	uv *= rotation;
	uv.x *= aspect;
	uv *= scale;
	
	if ( pattern_type == 1 )
	{
		// polka dots
		col = vec4(SimplexPolkaDot2D (uv * 20., radius * 1.9, dim));
	}
	
	else if ( pattern_type == 2 )
	{
		// loading screen
	    float ring = movingRing(uv, loading_inner, loading_outer);
		
	    col = vec4( ring );
	}
	
	else if ( pattern_type == 3 )
	{
		// Zig Zag
	    uv = zigzag(uv*vec2(1.,2.),5.);
	    float x = uv.x* zigzag_style; 
	    float a = floor(1.+sin(x*PI));
	    float b = floor(1.+sin((x+1.)*PI));
	    float f = fract(x);
	    col.rgb = vec3( fillY(uv,mix(a,b,f),0.1 / zigzag_sharpness *0.1) );
	}
	
	else if ( pattern_type == 4 )
	{
		// iching
		uv.y *= resolution.y/resolution.x;
	    uv *= 5.0;
	    vec2 fpos = fract(uv);
	    vec2 ipos = floor(uv);
	    float t = time*5.0;
	    float df = 1.0;
	    df = hex(fpos,ipos.x+ipos.y+t)+(1.0-rect(fpos,vec2(1.0)));
	    col = vec4(mix(vec3(1.),vec3(0.),step(iching_amount,df)),1.0);
	}
	
	else if ( pattern_type == 5 )
	{
		// Truchet
	    uv = tile(uv,2.0);
	    uv = rotateTilePattern(uv);
		float paint = 0.0;
	    // Make more interesting combinations
		if ( truchet_style == 1)
		{
			uv = rotate2D(uv,-PI*time*0.25);
		    uv = rotateTilePattern(uv*2.);
		    uv = rotate2D(uv,PI*time*0.25);
		}
		else if ( truchet_style == 2)
		{
			uv = rotate2D(uv,-PI*time*0.25);
		    uv += rotateTilePattern(uv*2.);
		    uv = rotate2D(uv,PI*time*0.25);
		}
		else if ( truchet_style == 3)
		{
			uv *= rotate2D(uv,-PI*time*0.25);
		    uv = rotateTilePattern(uv*2.);
		    uv *= rotate2D(uv,PI*time*0.25);
		}
		else if ( truchet_style == 4)
		{
			uv = rotateTilePattern(uv*2.);
		    uv *= rotate2D(uv,PI*time*0.25);
		}
		else if ( truchet_style == 5)
		{
			uv *= rotate2D(uv,-PI*time*0.25);
			uv *= rotateTilePattern(uv*2.);
		}
		else if ( truchet_style == 6)
		{
			uv *= rotate2D(uv,-PI*time*0.25);
			uv = rotateTilePattern(uv*2.);
		}
		else if ( truchet_style == 7)
		{
			uv = rotate2D(uv,-PI*time*0.25);
			uv *= rotateTilePattern(uv*2.);
		}

	    // step(st.x,st.y) just makes a b&w triangles
	    // but you can use whatever design you want.  
		if ( truchet_curve )
		{
			// enable additional curvature
			col.rgb = vec3(fillY(uv,0.5+sin(uv.x*PI*truchet_frequence)*truchet_amplitude,0.01));
		}
		else col.rgb = vec3(step(uv.x,uv.y));
	}
	else if ( pattern_type == 6 )
	{
		uv.x *= 100.;
		uv.y *= 100.;

		float line = floor(uv.y);
		uv.x += time*40.*(mod(line,binary_move)*2. -1.)*random(vec2(line));

		vec2 ipos = floor(uv);
		vec2 fpos = fract(uv);

		col.rgb = vec3(step(0.5*random(vec2(line)), binary_seed * random(ipos)));
	}
		
	gl_FragColor = col;
}
	