uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Source;
uniform float Exposure;
uniform float Red;
uniform float Green;
uniform float Blue;

vec3 RGB_lum = vec3(Red, Green, Blue);

const vec3 lumcoeff = vec3(0.2126,0.7152,0.0722);

void main (void) 
{ 		
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec4 tc = texture2D(Source, uv);
	tc = tc * (exp2(tc)*vec4(Exposure));
	vec4 RGB_lum = vec4(lumcoeff * RGB_lum, 0.0 );
	float lum = dot(tc,RGB_lum);
	vec4 luma = vec4(lum);
	gl_FragColor = vec4(luma.rgb,1.0);

} 
