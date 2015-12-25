uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Source, Matte;
uniform float glossy, softness, amount;

uniform float aspect, spacing;
uniform bool enable_aa;
uniform int oversamples;

float lens(vec2 uv) 
{
	return texture2D(Matte, uv).r;
}

void main(void)
{
	vec2 resolution = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / resolution;
	float distort = lens(uv);
	vec3 d = vec3 (0.0);
	vec3 col = vec3(0.0);
	
	if ( enable_aa )
	{
           for( int m=0; m<oversamples; m++ )
           for( int n=0; n<oversamples; n++ )
           {
               vec2 off = vec2( float(m), float(n) ) / float(oversamples);
			   vec2 uv = (gl_FragCoord.xy + off * 0.2) / resolution;
			   d = normalize(vec3(distort - lens(uv+vec2(0.001 * glossy * aspect, 0.0)), distort - lens(uv+vec2(0.0, 0.001 / aspect)), softness * 0.1));
			   uv += d.xy * - amount * 0.1;
			   col += texture2D(Source, uv).rgb;
			   col *= d.z;
		   }
		   col /= float(oversamples * oversamples);
	}


	else 
	{
		d = normalize(vec3(distort - lens(uv+vec2(0.001 * glossy * aspect, 0.0)), distort - lens(uv+vec2(0.0, 0.001 / aspect)), softness * 0.1));
		uv += d.xy * - amount * 0.1;
		col = texture2D(Source, uv).rgb;
		col *= d.z;
	}



	gl_FragColor = vec4(col, 1.0);
}