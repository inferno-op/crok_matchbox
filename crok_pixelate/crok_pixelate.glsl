uniform sampler2D image;
uniform sampler2D alpha;
uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform float Detail;
uniform float trans;
uniform bool Aspect;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);


void main(void)
{
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	
	vec2 aspect = vec2(1.0);
	
	if ( Aspect )
	    aspect = vec2(1.0, resolution.x/resolution.y);
			
    vec2 size = vec2(aspect.x/Detail, aspect.y/Detail);
    vec2 pix_uv = uv - mod(uv - 0.5,size);

	vec3 color1 = vec3( texture2D(image, pix_uv ).rgb);	
	vec3 color2 = vec3( texture2D(image, uv).rgb);
	vec3 matte =  vec3( texture2D(alpha, pix_uv).rgb);
	gl_FragColor = vec4 ((matte * color1*trans + (1.0 - matte*trans) *color2) , matte);
}
