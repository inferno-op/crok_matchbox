#version 120
// based on: http://www.ozone3d.net/smf/index.php?topic=68.0

// load original Image
uniform sampler2D adsk_results_pass1;
// load Remove Highlights result
uniform sampler2D adsk_results_pass8;

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float strength;
float step_w = 1.0 / resolution.x;
float step_h = 1.0 / resolution.y;


float overlay( float s, float d )
{
	return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec3 overlay( vec3 s, vec3 d )
{
	vec3 c;
	c.x = overlay(s.x,d.x);
	c.y = overlay(s.y,d.y);
	c.z = overlay(s.z,d.z);
	return c;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
	vec3 d = texture2D(adsk_results_pass8, uv).rgb;
	float key = texture2D(adsk_results_pass8, uv).a;

	vec2 offset[9];
	float kernel[ 9 ];

	offset[ 0 ] = vec2(-step_w, -step_h);
	offset[ 1 ] = vec2(0.0, -step_h);
	offset[ 2 ] = vec2(step_w, -step_h);
	offset[ 3 ] = vec2(-step_w, 0.0);
	offset[ 4 ] = vec2(0.0, 0.0);
	offset[ 5 ] = vec2(step_w, 0.0);
	offset[ 6 ] = vec2(-step_w, step_h);
	offset[ 7 ] = vec2(0.0, step_h);
	offset[ 8 ] = vec2(step_w, step_h);
	kernel[ 0 ] = -1.;
	kernel[ 1 ] = -1.;
	kernel[ 2 ] = -1.;
	kernel[ 3 ] = -1.;
	kernel[ 4 ] = 8.;
	kernel[ 5 ] = -1.;
	kernel[ 6 ] = -1.;
	kernel[ 7 ] = -1.;
	kernel[ 8 ] = -1.;


   int i = 0;
   vec3 col = vec3(0.0);

   for( int i=0; i<9; i++ )
   {
    vec4 org = texture2D(adsk_results_pass1, uv + offset[i]);
    col += org.rgb * kernel[i];
   }
   col = col * strength * key * 0.1 + 0.5;
   
   gl_FragColor = vec4(col, key);
}