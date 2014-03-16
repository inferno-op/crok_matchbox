uniform sampler2D image;
uniform sampler2D alpha;
uniform float adsk_result_w, adsk_result_h;
uniform float Detail;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 pixel = floor( uv * Detail );
	vec4 pixel_img = vec4( texture2D(image, pixel / Detail ).rgb * texture2D(alpha, pixel / Detail).rgb, texture2D(alpha, pixel / Detail).b);
	vec4 normal_img = vec4( texture2D(image, uv));

	gl_FragColor = vec4 ( mix(normal_img.rgba, pixel_img.rgba, 1.0));
}