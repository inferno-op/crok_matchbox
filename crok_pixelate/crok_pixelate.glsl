uniform sampler2D image;
uniform sampler2D alpha;
uniform float adsk_result_w, adsk_result_h;
uniform float Detail;
uniform float trans;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 pixel = floor( uv * Detail );
	vec3 color1 = vec3( texture2D(image, pixel / Detail ).rgb);	
	vec3 color2 = vec3( texture2D(image, uv).rgb);
	vec3 matte =  vec3( texture2D(alpha, pixel / Detail).rgb);
	gl_FragColor = vec4 ((matte * color1 + (1.0 - matte) *color2) , matte);
}
