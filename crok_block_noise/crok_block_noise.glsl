uniform float Speed;
uniform float Offset;
uniform float scale;
uniform float scale_x;
uniform float scale_y;
uniform float seed;
uniform float gain;
uniform float aspect_x;
uniform float aspect_y;


uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform vec3 tint;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time * .04234 * Speed + Offset + 200.0;


float rand(vec2 n)
{
  return fract(sin(dot(n.xy, vec2(0.000435134551 * scale_x, .0043451929 * scale_y)))* time);
}

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	float color = rand(seed*floor((position.xy*vec2(1.0 * aspect_x,0.5 * aspect_y) + 0.5) * scale) / scale)
		+rand(seed*floor((position.xy*vec2(1.0 * aspect_x,0.5 * aspect_y) + 0.5) * scale*2.0) / scale*2.0 )
		+rand(seed*floor((position.xy*vec2(1.0 * aspect_x,0.5 * aspect_y) + 0.5) * scale*4.0) / scale*4.0 )
		+rand(seed*floor((position.xy*vec2(1.0 * aspect_x,0.5 * aspect_y) + 0.5) * scale*8.0) / scale*8.0 )
		+rand(seed*floor((position.xy*vec2(1.0 * aspect_x,0.5 * aspect_y) + 0.5) * scale*16.0) / scale*16.0 );
	color = color / 5.0 * gain;

	gl_FragColor = vec4( vec3( color*tint.r, color*tint.g, color*tint.b), 1.0 );

}