#version 120
// based on https://www.shadertoy.com/view/4s2GRR by SanchYESS
// Inspired by http://stackoverflow.com/questions/6030814/add-fisheye-effect-to-images-at-runtime-using-opengl-es 

uniform sampler2D source;
uniform float adsk_result_w, adsk_result_h, distortion;

void main()
{
	vec2 resolution = vec2(adsk_result_w, adsk_result_h);
	vec2 p = gl_FragCoord.xy / resolution.x;
	float aspect = resolution.x / resolution.y;
	vec2 m = vec2(0.5, 0.5 / aspect);
	vec2 d = p - m;
	float r = sqrt(dot(d, d));
	float power = ( 2.0 * 3.141592 / (2.0 * sqrt(dot(m, m))) ) * (resolution.x / (1.-distortion)  * .5 / resolution.x - 0.5);
	float bind;//radius of 1:1 effect
	if (power > 0.0) bind = sqrt(dot(m, m));//stick to corners
	else 
	{
		if (aspect < 1.0) bind = m.x;
		else bind = m.y;
	} //stick to borders

	vec2 uv;
	if (power > 0.0)//fisheye
		uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
	else if (power < 0.0)//antifisheye
		uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
	else uv = p;//no effect for power = 1.0
	vec3 col = texture2D(source, vec2(uv.x, uv.y * aspect)).xyz;//Second part of cheat for round effect, not elliptical
	gl_FragColor = vec4(col, 1.0);
}