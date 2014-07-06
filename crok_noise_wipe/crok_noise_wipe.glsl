uniform sampler2D source, target;
uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Speed, Offset;
uniform float Noise, Amplitude, Softness, Rotation;
uniform bool Dissolve, Invert, Horizontal;
 
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

float time = adsk_time *.065 * Speed + Offset - 1.2;

// http://glsl.heroku.com/e#17891.7

float Hash( vec2 p)
{
	vec3 p2 = vec3(p.xy,1.0);
    return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*3758.5453123);
}

float noise(in vec2 p)
{
    vec2 i = floor(p);
	vec2 f = fract(p); 
	f *= f * (3.0-2.0*f);

    return mix(mix(Hash(i + vec2(0.,0.)), Hash(i + vec2(1.,0.)),f.x),
			mix(Hash(i + vec2(0.,1.)), Hash(i + vec2(1.,1.)),f.x),
			f.y);
		}

float fbm(vec2 p) {
	float v = 0.0;
	v += noise(p*1.)*.5;
	v += noise(p*2.)*.25;
	v += noise(p*4.)*.125;
	return v;
}

void main(void) {

	vec2 pos = 2.0 * ((gl_FragCoord.xy / resolution.xy) - 0.5);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 color = vec3(0.0);
	float dis = 0.0;
	
    if ( Dissolve )
	{
		dis = pos.x * 0.0 + pos.y * 0.0;
		dis+= fbm(pos * Noise) * Amplitude ;
		if ( Invert )
		{
			dis+= time * - 0.35 - 0.41;
			color = clamp((color+(dis) / Softness * - 3.0 ),0.0,1.0);
		}
		else
		{
			dis+= time * 0.35 - 0.47;
			color = clamp((color+(dis) / Softness * 3.0 ),0.0,1.0);
		}
	}
    else if ( Horizontal )
	{
		dis = pos.y + pos.x * Rotation;
		dis+= fbm(pos * Noise) * Amplitude ;
		
		if ( Invert )
		{
			dis+= time * -1.0;
			color = clamp((color+(dis) / Softness * - 3.0 ),0.0,1.0);
		}
		else
		{
			dis+= time - 0.8;
			color = clamp((color+(dis) / Softness * 3.0 ),0.0,1.0);
		}
	}
	else
	{

	dis = pos.x + pos.y * Rotation;
	dis+= fbm(pos * Noise) * Amplitude ;
	if ( Invert )
	{
		dis+= time * - 1.0;
		color = clamp((color+(dis) / Softness * - 3.0 ),0.0,1.0);
	}

	else
	{
		dis+= time - 0.75;
		color = clamp((color+(dis) / Softness * 3.0 ),0.0,1.0);
	}
}

	vec4 source_img = texture2D(source, uv);	
	vec4 target_img = texture2D(target, uv);
	vec4 img_blend = vec4( mix(source_img, target_img, 1.0));
	img_blend *= vec4(color, 1.0);
	img_blend += source_img * vec4(1.0 - color, 1.0);
	gl_FragColor = vec4(img_blend.rgb, color.r);
}