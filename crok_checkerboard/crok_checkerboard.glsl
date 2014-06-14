uniform float adsk_result_w, adsk_result_h, Zoom, Aspect;
uniform vec3 color1, color2;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
vec3 checkerboard(vec2 p, float freq, vec3 first, vec3 second)
{
	return 	mix(first, second, max(0.0, sign(sin(p.x * freq * Aspect * (adsk_result_w / adsk_result_h))) * sign(sin(p.y * freq ))));
}
void main( void ) {

	vec2 p = (gl_FragCoord.xy / resolution.xy) ;
	p=(2.0*(p-.5));

	gl_FragColor = vec4(checkerboard( p, Zoom, color1, color2), 1.0 );

}