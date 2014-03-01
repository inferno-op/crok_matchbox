uniform float adsk_result_w, adsk_result_h, Number;
uniform vec3 color1, color2;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
vec3 checkerboard(vec2 p, float freq, vec3 first, vec3 second)
{
	return 	mix(first, second, max(0.0, sign(sin(p.x * 6.283*freq)) * sign(sin(p.y * 6.283 * freq))));
}
void main( void ) {
	vec2 p = ( gl_FragCoord.xy / resolution.xy );
	p.x *= resolution.x / resolution.y;
	gl_FragColor = vec4(checkerboard( p, Number, vec3(color1.r, color1.g, color1.b), vec3(color2.r, color2.g, color2.b)), 1.0 );
}