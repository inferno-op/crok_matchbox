#version 120
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
/*
vec4 texture2DEWA(vec2 p0)
{
    vec2 du = dFdx(p0);
    vec2 dv = dFdy(p0);
    float scale = adsk_result_w;

    p0 -=vec2(0.5,0.5)/scale;
    vec2 p = scale * p0;

    float ux = filterwidth * du.s * scale;
    float vx = filterwidth * du.t * scale;
    float uy = filterwidth * dv.s * scale;
    float vy = filterwidth * dv.t * scale;

    // compute ellipse coefficients
    // A*x*x + B*x*y + C*y*y = F.
    float A = vx*vx+vy*vy+1.0;
    float B = -2.0*(ux*vx+uy*vy);
    float C = ux*ux+uy*uy+1.0;
    float F = A*C-B*B/4.0;

    // Compute the ellipse's (u,v) bounding box in texture space
    float bbox_du = 2.0 / (-B*B+4.0*C*A) * sqrt((-B*B+4.0*C*A)*C*F);
    float bbox_dv = 2.0 / (-B*B+4.0*C*A) * sqrt(A*(-B*B+4.0*C*A)*F);

    // Clamp the ellipse so that the bbox includes at most TEXEL_LIMIT texels.
    // This is necessary in order to bound the run-time, since the ellipse can be arbitrarily large
    // Note that here we are actually clamping the bbox directly instead of the ellipse.
    if(bbox_du*bbox_dv>float(texellimit)) {
        float ll = sqrt(bbox_du*bbox_dv / float(texellimit));
        bbox_du/=ll;
        bbox_dv/ll;
    }

    // The ellipse bbox
    int u0 = int(floor(p.s - bbox_du));
    int u1 = int(ceil (p.s + bbox_du));
    int v0 = int(floor(p.t - bbox_dv));
    int v1 = int(ceil (p.t + bbox_dv));

    // Heckbert MS thesis, p. 59; scan over the bounding box of the ellipse
    // and incrementally update the value of Ax^2+Bxy*Cy^2; when this
    // value, q, is less than F, we're inside the ellipse so we filter
    // away...
    vec4 num= vec4(0.0, 0.0, 0.0, 1.0);
    float den = 0.0;
    float ddq = 2.0 * A;
    float U = float(u0) - p.s;

    for (int v = v0; v <= v1; ++v) {
        float V = float(v) - p.t;
        float dq = A*(2.0*U+1.0) + B*V;
        float q = (C*V + B*U)*V + A*U*U;
        for (int u = u0; u <= u1; ++u) {
            if (q < F) {
                float r2 = q / F;
                // Gaussian filter weights
                float weight = exp(-filtersharpness * r2);

                num += weight * texture2D(Source, vec2(float(u)+0.5,float(v)+0.5)/scale);
                den += weight;
            }
            q += dq;
            dq += ddq;
        }
    }
    vec4 color = num*(1./den);
    return color;
}
*/

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

vec3 color(vec2 uv)
{
    float w = lens(uv);
    vec3 n = normalize(vec3(norm(uv),w*w/4.));
    vec3 o = vec3(uv,-w);
    vec3 off = vec3((0.5 - offset) * 25.0);
    off = refract(off,n,0.13);
    o += off*w/20. * d_amount;
    off = refract(off,vec3(n.xy,-n.z),0.76);
    //vec3 base = texture2DEWA(vec2(o.xy)).rgb;
		vec3 base = texture2D(Source, vec2(o.xy)).rgb;

    float highlite = pow(max(0.,dot(normalize(0.5 - light),n)),8. / l_amount);
    return base + highlite;
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
	               vec2 of = vec2( float(m), float(n) ) / float(oversamples);
				   vec2 uv = (gl_FragCoord.xy + of * 0.2) / resolution;
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
	}

	gl_FragColor = vec4(col, 1.0);
}
