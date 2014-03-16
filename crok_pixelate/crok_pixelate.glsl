uniform sampler2D image;
uniform sampler2D alpha;
uniform float adsk_result_w, adsk_result_h;
uniform float Detail;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 pixel = floor( uv * Detail );
	gl_FragColor = texture2D(alpha, pixel / Detail) * (texture2D(image, pixel / Detail )) + (1.0 - texture2D(alpha, pixel / Detail)) * (texture2D(image, uv ));
}

