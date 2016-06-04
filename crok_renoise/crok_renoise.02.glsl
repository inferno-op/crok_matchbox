#version 120
uniform sampler2D source, matte, adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h, adsk_time, adsk_result_pixelratio, adsk_result_frameratio;
uniform float scale, o_gain;
uniform bool show_grain;
uniform vec3 gain;


// Forward declaration of API function. This is necessary to use in Matchbox otherwise it won't compiled. Please see MatchboxAPI for more info.
float adsk_getLuminance ( vec3 rgb );
float adskEvalDynCurves( int curve, float x );

// Here is the int used for the single Luma Curve widget
uniform ivec4 lumaCurve;

float hash( float n ) {
    return fract(sin(n)*687.3123);
}

float noise( in vec2 x ) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0;
    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );

float fbm( vec2 p ) {
    float f = 0.0;
    f += 0.5000*noise( p ); p = m2*p*2.02;
    f += 0.2500*noise( p ); p = m2*p*2.03;
    f += 0.1250*noise( p ); p = m2*p*2.01;
		f += 0.0625*noise( p );

    return f/0.9375;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	float time = adsk_time;
	vec4 c = vec4(0.0);
	vec2 off_center;

	// random x y
	off_center.x = noise(vec2((time + 134.) * 148.12, (time + 115.) * 13.56));
	off_center.y = noise(vec2((time + 54.) * 151.1, (time + 135.) * 84.3));

	float rnd = 0.0;
 	// random rotation
	rnd = noise(vec2((time + 67.) * 123.32)) * 214.2;
	rnd += noise(vec2((time + 42.) * 34.1)) * 213.53;

	float rot_cent = noise(vec2((time + 5678.) * 123.32)) * 214.2;
  mat2 rot = mat2( cos(rnd - rot_cent), -sin( rnd - rot_cent), sin( rnd - rot_cent), cos( rnd - rot_cent));

	vec2 o_uv = uv;
	o_uv -= vec2(0.5);
  o_uv.x *= adsk_result_frameratio;
  o_uv *= rot;
	o_uv /= scale*0.4;
  o_uv += vec2(0.5);

	vec3 s = texture2D(source, uv).rgb;
	vec3 g = texture2D(adsk_results_pass1, (o_uv + off_center)).rgb;
	float m = texture2D(matte, uv).r;

  // Extract Luminance from source using API function
  float lum = adsk_getLuminance(s);
  // Here I'm evluating the RGB Master Luma curve widget
  float master_lum = adskEvalDynCurves(lumaCurve.r, lum);
  float red_lum = adskEvalDynCurves(lumaCurve.g, lum);
  float green_lum = adskEvalDynCurves(lumaCurve.b, lum);
  float blue_lum = adskEvalDynCurves(lumaCurve.a, lum);

	// gain red noise channel
	g.r *= gain.r;
	// gain green noise channel
	g.g *= gain.g;
	// gain blue noise channel
	g.b *= gain.b;
	// overall gain
	g *= o_gain;

	// master channel
	c.rgb = g + s;
	c.rgb = vec3(master_lum * c.rgb + (1.0 - master_lum) * s);
	c.rgb = vec3(m * c.rgb + (1.0 - m) * s);

	if ( show_grain )
		c = vec4(g + 0.5, 1.0);

	gl_FragColor = c;
}
