// based on http://glslsandbox.com/e#21649.1
uniform float adsk_time;
uniform float style;
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main( void ) {
	vec2 uv = gl_FragCoord.xy/resolution.xy;
	const int memLen = 2;
	vec4 lotsOfMemory[memLen];
	for(int i = 0; i < memLen; i++){
		gl_FragColor += lotsOfMemory[i];
	}
	gl_FragColor = sin(gl_FragColor * adsk_time);
}