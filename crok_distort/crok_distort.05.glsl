//#version 120
#extension GL_ARB_shader_texture_lod : enable

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Source, adsk_results_pass4, adsk_results_pass2;
uniform float glossy, softness, amount, height, d_amount, l_amount, blend;

uniform float aspect, spacing;
uniform bool enable_aa;
uniform int oversamples;
uniform int style;
uniform vec3 offset, light;

uniform float filterwidth, filtersharpness;
uniform int texellimit; // = 128;


float strength(vec2 uv)
{
	return texture2D(adsk_results_pass2, uv).r;
}


float lens(vec2 uv)
{
	float l_a = texture2D(adsk_results_pass4, uv).r;
	float s_a = strength(uv);
	return mix(l_a, l_a * s_a, blend);

}

vec2 norm(vec2 uv)
{
    vec2 e = vec2(0.001 * height, 0.0);
    return vec2(lens(uv+e.xy)-lens(uv-e.xy), lens(uv+e.yx)-lens(uv-e.yx));
}

vec3 color(vec2 p)
{
	vec3 c = vec3(0.0);
	if ( enable_aa )
	{
           for( int m=0; m<oversamples; m++ )
           for( int n=0; n<oversamples; n++ )
           {
		   		vec2 resolution = vec2(adsk_result_w, adsk_result_h);
				vec2 of = vec2( float(m), float(n) ) / float(oversamples);
			   vec2 uv = (gl_FragCoord.xy + of) / resolution;
		       
			   float w = lens(uv);
		       vec3 nn = normalize(vec3(norm(uv),w*w/4.));
		       vec3 o = vec3(uv,w);
		       vec3 off = normalize(vec3(0.5 - offset));
		       off = refract(off,nn,0.13);
		       o += off*w/20. * d_amount;
		       off = refract(off,vec3(nn.xy,-nn.z),0.76);
		   	   vec3 base = texture2D(Source, vec2(o.xy)).rgb;
		       float highlite = abs(pow(max(0.,dot(normalize(0.5 - light),nn)),8. / l_amount));
			   c += base + highlite;
		   }
		   c /= float(oversamples * oversamples);
	}
	else
	{
	    float w = lens(p);
	    vec3 n = normalize(vec3(norm(p),w*w/4.));
	    vec3 o = vec3(p,w);
	    vec3 off = normalize(vec3(0.5 - offset));
	    off = refract(off,n,0.13);
	    o += off*w/20. * d_amount;
	    off = refract(off,vec3(n.xy,-n.z),0.76);
		vec3 base = texture2D(Source, vec2(o.xy)).rgb;
	    float highlite = abs(pow(max(0.,dot(normalize(0.5 - light),n)),8. / l_amount));
	    c = base + highlite;
	}
	return c;
}

void main(void)
{
	vec2 resolution = vec2(adsk_result_w, adsk_result_h);
	vec2 uv = gl_FragCoord.xy / resolution;

	float distort = lens(uv);
	vec3 d = vec3 (0.0);
	vec3 col = vec3(0.0);

	if ( style == 1 )
	{
		col = color(uv);
	}

	if ( style == 0 )
	{
		if ( enable_aa )
		{
	           for( int m=0; m<oversamples; m++ )
	           for( int n=0; n<oversamples; n++ )
	           {
	               vec2 offf = vec2( float(m), float(n) ) / float(oversamples);
				   vec2 p = (gl_FragCoord.xy + offf) / resolution;
				   d = normalize(vec3(distort - lens(p+vec2(0.001 * glossy * aspect, 0.0)), distort - lens(p+vec2(0.0, 0.001 / aspect)), softness * 0.1));
				   p += d.xy * - amount * 0.1;
				   col += texture2D(Source, p).rgb;
			   }
			   col /= float(oversamples * oversamples);
		}


		else
		{
			d = normalize(vec3(distort - lens(uv+vec2(0.001 * glossy * aspect, 0.0)), distort - lens(uv+vec2(0.0, 0.001 / aspect)), softness * 0.1));
			uv += d.xy * - amount * 0.1;
			col = texture2D(Source, uv).rgb;
		}
	}

	gl_FragColor = vec4(col, 1.0);
}
