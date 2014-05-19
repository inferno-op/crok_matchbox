uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Source;
uniform float Exposure;
uniform float Amount;
uniform float Saturation;
uniform vec3 RGB_lum;
uniform bool tc1, tc2, tc3, tc4;

const vec3 lumcoeff = vec3(0.2126,0.7152,0.0722);

const vec4 redfilter_tc1 		= vec4(1.0, 0.0, 0.0, 0.0);
const vec4 bluegreenfilter_tc1 	= vec4(0.0, 1.0, 0.7, 0.0);

const vec4 redfilter_tc2		= vec4(1.0, 0.0, 0.0, 0.0);
const vec4 bluegreenfilter_tc2 	= vec4(0.0, 1.0, 1.0, 0.0);
const vec4 cyanfilter_tc2		= vec4(0.0, 1.0, 0.5, 0.0);
const vec4 magentafilter_tc2	= vec4(1.0, 0.0, 0.25, 0.0);

const vec4 redfilter_tc3 		= vec4(1.0, 0.0, 0.0, 0.0);
const vec4 greenfilter_tc3 		= vec4(0.0, 1.0, 0.0, 0.0);
const vec4 bluefilter_tc3		= vec4(0.0, 0.0, 1.0, 0.0);
const vec4 redorangefilter_tc3 	= vec4(.99, 0.263, 0.0, 0.0);
const vec4 cyanfilter_tc3		= vec4(0.0, 1.0, 1.0, 0.0);
const vec4 magentafilter_tc3	= vec4(1.0, 0.0, 1.0, 0.0);
const vec4 yellowfilter_tc3 	= vec4(1.0, 1.0, 0.0, 0.0);

void main(void)
{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec4 tc = texture2D(Source, uv);

	vec4 RGB_lum = vec4(lumcoeff * RGB_lum, 0.0 );
	float lum = dot(tc,RGB_lum);
	vec4 luma = vec4(lum);
	
	vec4 col = vec4 (0.0, 0.0, 0.0, 0.0);
	gl_FragColor = tc;
		
	if ( tc1 )
	{
	vec4 redrecord = tc * redfilter_tc1;
	vec4 bluegreenrecord = tc * bluegreenfilter_tc1;
	vec4 rednegative = vec4(redrecord.r);
	vec4 bluegreennegative = vec4((bluegreenrecord.g + bluegreenrecord.b)/2.0);
	vec4 redoutput = rednegative * redfilter_tc1;
	vec4 bluegreenoutput = bluegreennegative * bluegreenfilter_tc1;
	vec4 result = redoutput + bluegreenoutput;
	col = mix(tc, result, Amount);
}

	if ( tc2 )
	{
	vec4 redrecord = tc * redfilter_tc2;
	vec4 bluegreenrecord = tc * bluegreenfilter_tc2;
	vec4 rednegative = vec4(redrecord.r);
	vec4 bluegreennegative = vec4((bluegreenrecord.g + bluegreenrecord.b)/2.0);
	vec4 redoutput = rednegative + cyanfilter_tc2;
	vec4 bluegreenoutput = bluegreennegative + magentafilter_tc2;
	vec4 result = redoutput * bluegreenoutput;
	col = mix(tc, result, Amount);
}

	if ( tc3 )
	{
	vec4 greenrecord = (tc) * greenfilter_tc3;
	vec4 bluerecord = (tc) * magentafilter_tc3;
	vec4 redrecord = (tc) * redorangefilter_tc3;
	vec4 rednegative = vec4((redrecord.r + redrecord.g + redrecord.b)/3.0);
	vec4 greennegative = vec4((greenrecord.r + greenrecord.g + greenrecord.b)/3.0);
	vec4 bluenegative = vec4((bluerecord.r+ bluerecord.g + bluerecord.b)/3.0);
	vec4 redoutput = rednegative + cyanfilter_tc3;
	vec4 greenoutput = greennegative + magentafilter_tc3;
	vec4 blueoutput = bluenegative + yellowfilter_tc3;
	vec4 result = redoutput * greenoutput * blueoutput;
	col = mix(tc, result, Amount);

}
	if ( tc4 )
	{
	vec3 redmatte = vec3(tc.r - ((tc.g + tc.b)/2.0));
	vec3 greenmatte = vec3(tc.g - ((tc.r + tc.b)/2.0));
	vec3 bluematte = vec3(tc.b - ((tc.r + tc.g)/2.0));
	redmatte = 1.0 - redmatte;
	greenmatte = 1.0 - greenmatte;
	bluematte = 1.0 - bluematte;
	vec3 red =  greenmatte * bluematte * tc.r;
	vec3 green = redmatte * bluematte * tc.g;
	vec3 blue = redmatte * greenmatte * tc.b;
	vec4 result = vec4(red.r, green.g, blue.b, tc.a);
	col = mix(tc, result, Amount);

}
	gl_FragColor = mix(col, luma, Saturation) * Exposure;
}

