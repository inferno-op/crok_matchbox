uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float pRight;
uniform float pLeft;
uniform float Offset;
uniform float Speed;
uniform float Zoom;
uniform float Detail;
uniform float Steps;
uniform float Aspect;
uniform vec3 Color;
uniform bool useduration;
uniform int duration;

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
    
	vec2 position = ( gl_FragCoord.xy / resolution.xy ) * 1.0*Zoom;
	position.x *= resolution.x / resolution.y*Aspect;
	float color = 0.0;
    
	for(float i = 0.0; i < Steps; i++)
	{
		position.x += sin(Detail * sin(length(position.y)));
		color += sin(0.6 * sin(length(position) + position.x + i * position.y*0.5 + sin(i + position.x + time )) + sin(Detail * cos(sin(position.y * 2. + position.x) * 0.5)));
		color = sin(color*1.5);
		position.y += color*1.5;
		position.x -= sin(position.y - cos(dot(position, vec2(color, sin(color*2.)))));
		
	}
	color = abs(color);
	color *= 0.8;
	
	gl_FragColor = vec4(pow(vec3(1.0 - color), vec3(1.-Color.r, 1.-Color.g, 1.-Color.b)), color );
    
}