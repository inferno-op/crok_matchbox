uniform float adsk_time, speed, offset;
uniform float adsk_result_w, adsk_result_h;
uniform vec3 color_1;
uniform float zoom;
uniform float itterations;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time*.025 * speed + offset;
#define PI 3.14159
#define TWO_PI (PI*2.0)
void main(void) 
{
	vec2 center = (gl_FragCoord.xy);
	center.x=-0.12*sin(time/200.0);
	center.y=-100.12*cos(time/200.0);
	vec2 v = (gl_FragCoord.xy - resolution/2.0) / min(resolution.y,resolution.x) * zoom;
	v.x=v.x-200.0;
	v.y=v.y-200.0;
	float col = 0.0;
	for(float i = 0.0; i < itterations; i++) 
	{
	  	float a = i * (TWO_PI/itterations) * 61.95;
		col += cos(TWO_PI*(v.y * cos(a) + v.x * sin(a) + sin(time*0.004)*100.0 ));
	}
	gl_FragColor = vec4(col*color_1.r, col*color_1.g, col*color_1.b, 1.0);
}