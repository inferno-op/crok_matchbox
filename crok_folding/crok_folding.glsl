uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float pRight;
uniform float pLeft;
uniform float Offset;
uniform float Speed;
uniform float Zoom;
uniform float Noise;
uniform float Steps;
uniform float Aspect;
uniform vec3 color_pot;
uniform bool useduration;
uniform int duration;
uniform float Detail;


vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main( void ) {
	float time;
	if(useduration) {
		// The only time-dependent function below is sin(time), which
		// repeats every 2*pi
		time = 2.0 * 3.14159265358979 * (adsk_time/float(duration));
		time += Offset/float(duration);
	} else {
		time = adsk_time*.01*Speed+Offset;
	}
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 zoom_center=(2.0*(position-.5)) * Zoom;
	zoom_center.x *= resolution.x / resolution.y*Aspect;
	float color = 0.0;
	for(float i = 0.0; i < Steps; i++)
	{
		zoom_center.x += sin(Noise * sin(length(zoom_center.y + 5.)));
		color += sin(0.6 * Detail * sin(length(position) + zoom_center.x + i * zoom_center.y + sin(i + zoom_center.x + time )) + sin(Noise * cos(sin(zoom_center.y + zoom_center.x) * 0.5)));
		color = sin(color*1.5);
		zoom_center.y += color*1.5;
		zoom_center.x -= sin(zoom_center.y - cos(dot(zoom_center, vec2(color, sin(color*2.)))));
	}
	gl_FragColor = vec4(abs(color) * color_pot, 1.0);
    
}