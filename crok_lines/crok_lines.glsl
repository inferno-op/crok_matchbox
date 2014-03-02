uniform float adsk_result_w, adsk_result_h, adsk_time, density, speed, offset;
uniform int itterations; //7
uniform float gain; //0.45
uniform	float edgeSharpness; //1.67
uniform vec3 color;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time*.002 * speed + offset;
const float Pi = 3.14159;

void main()
{
  vec2 pos = gl_FragCoord.xy / resolution.xy;
  float angled = (pos.x) * density;	
  for (int i = 1; i < itterations; i++)
  {
	  angled += (edgeSharpness * sin( float(i)*angled) / float(i) ) + time;
  }
  float base = gain * sin(3.0*angled);
  gl_FragColor=vec4(color.r * base, color.g * base, color.b * base, 1.0);
}
