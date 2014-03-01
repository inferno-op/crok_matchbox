uniform float Line, Size;
void main( void ) {
	vec2 position = gl_FragCoord.xy;
	float color = 1.0;
	if(mod(position.x, Size) <= Line)
	{
		color = 1.0;
	}
	else if(mod(position.y, Size) <= Line)
	{
		color = 1.0;
	}
	else
	{
		color = 0.0;
	}
	gl_FragColor = vec4( color, color, color, 1.0 );
}