#version 120
// version 120 is to make it work on Mac

//resolution controls
uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);


//Node's inputs
// Front
uniform sampler2D adsk_results_pass1;
// Back
uniform sampler2D adsk_results_pass2;
// Matte
uniform sampler2D adsk_results_pass3;
// pixelspread and matte
uniform sampler2D adsk_results_pass4;
// Blurred pixelspread and Matte
uniform sampler2D adsk_results_pass6;
// clean Reference Frame
uniform sampler2D reference;
// Holdout Matte
uniform sampler2D adsk_results_pass7;
// Holdout Matte
uniform sampler2D org_fg;


uniform bool show_pixelspread;
uniform bool output_bg;
uniform bool clamp_output;
uniform bool invert_holdout;
uniform bool joel_add;

//Variables (These are the controls we will have in the matchbox)
uniform float desat_highs;
uniform float desat_darks;
uniform float bgmix_highs;
uniform float bgmix_darks;
uniform float mix_highs;
uniform float mix_darks;
uniform float mix_global;
uniform float bias_adj;
uniform float gamma;
uniform float offset;

uniform int output_opt;

const vec3 lumc = vec3(0.2125, 0.7154, 0.0721);


//define functions
vec3 subtract( vec3 s, vec3 d )
{
	return s - d;
}

vec3 desaturate(vec3 color, float amount)
{
    vec3 gray = vec3(dot(vec3(0.2126,0.7152,0.0722), color));
    return vec3(mix(color, gray, amount));
}

vec3 divide ( vec4 col )
{
	return col.rgb / vec3(col.a);
}

vec3 lighten( vec3 front, vec3 back )
{
	return max(front, back);
}

vec3 difference( vec3 s, vec3 d )
{
	return abs(d - s);
}

vec3 multiply( vec3 s, vec3 d )
{
	return s*d;
}

vec3 saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

float bias(float x, float b) 
{
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}

//vec3 despill(){}
// TODO complete with a code for despill of your choice, I think you already have one on Logik
//Ideally a slider to control how much we despill would be nice.

//Main loop
void main(void)
{
	//Not sure what this is doing exactly, but it seems needed to get the matchbox to work
    vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	
    //Get our inputs
	vec3 f = texture2D(adsk_results_pass1, uv).rgb;  // front
	vec3 b = texture2D(adsk_results_pass2, uv).rgb;  // back
	vec3 m = texture2D(adsk_results_pass3, uv).rgb;  // matte
	vec3 p = texture2D(adsk_results_pass4, uv).rgb;  // pixelspread
	// I assume the reference is the clean FG
	vec3 r_ext = texture2D(reference, uv).rgb;
	vec4 b_fg_m = texture2D(adsk_results_pass6, uv).rgba;  // blurred FG and Matte
	vec3 h_m = texture2D(adsk_results_pass7, uv).rgb;  // holdout Matte
	vec3 o_f = texture2D(org_fg, uv).rgb; // original Greensccreen FG without Despill
	

	vec3 c = vec3(0.0);
	vec3 sub = vec3(0.0);
	vec3 r = vec3(0.0);
	vec3 org_f = f;
	vec3 org_b = b;
	vec3 matte_out = vec3(0.0);
	
	// Do the despill first, on both front and reference, with the slider that decides how much to despill
	// TODO


	if ( joel_add )
	{
		// diffeence between despilled FG and original greenscreen FG
	    // adjust gamma on BG
		b = pow(abs(b), vec3(1.0/gamma));
		// adjust offset on BG
		b = b + offset;
		
		c = difference ( f, o_f);
		c = vec3(dot(c, lumc));
		c = min(max(c - vec3(0.0), vec3(0.0)) / (vec3(1.0) - vec3(0.0)), vec3(1.0));
	    c = mix(vec3(0.0), vec3(bias_adj), c);
		
		// multiply histo FG by BG
		c = multiply ( vec3(c), b );
		
		// add despilled FG over processed BG
		c = f + c; 	
		
		
	}
	
	else
	{
		// check if there is an external reference clip
		if ( r_ext != vec3(1.0) )
		{
			r = r_ext;
		}
		else
		{
			// divide blurred fg by blurred matte
			r = divide ( b_fg_m );
			r = lighten ( p, r);
		}
	
	
		// subtract operation
		sub = sub + subtract(f, r);
		// Max 0.0 to get all the positives
		vec3 highs = max(sub, 0.0);
		// And min for the negatives
		vec3 darks = min(sub, 0.0);
		//Give an option to desaturate the highlights and the darks separately, each with a SLIDER (0 to 1)
		highs = desaturate(highs, desat_highs);
		darks = desaturate(darks, desat_darks);
		//get the luminance of the BG 
		vec3 bg_lum = desaturate(b, 1.0);

		//and let the user decide by how much they want to multiply the darks and highlights by the BG luma, with SLIDERS.
		// I don't know how to write the mix so I might be completely wrong
		// highs = mix(highs, highs*bg_lum, bgmix_highs);
		// darks = mix(darks, darks*bg_lum, bgmix_darks);
		//Finally, let them decide how much of the darks and highlights they want to add, there are multiple ways to do that, the easiest I think is to put a simple multiplier, 0 would kill the values, 1 would be normal, above 1 would make it more intense. If you want to go overkill you could separate that in R,G and B gain.
		highs = highs * mix_highs;
		darks = darks * mix_darks;

		// Blend all together for the final comp on top of old bg.
		org_f = vec3(m * f + (1.0 - m) * b);
	
		//Now we add both the darks and highlishts to the BG plate (since the darks are negative values, it gets darker)
		b = mix(b, b + highs + darks, mix_global);
		// risk of negative values, maybe need a neg clamp

		// Blend all together for the final comp on top of new back.
		c = vec3(m * f + (1.0 - m) * b);
	}

	
	//Finally output the result
	if ( output_bg )
		c = b;

	h_m = 1.0 - h_m;
	
	if ( invert_holdout )
		h_m = 1.0 - h_m;
	
	c = vec3(h_m * org_f + (1.0 - h_m) * c);


	if ( show_pixelspread )
		c = r;

	if ( clamp_output )
		c = clamp( c, 0.0, 1.0);
	
	m += clamp((b - org_b), 0.0, 1.0);
	m = clamp(m, 0.0, 1.0);
	
	if ( output_opt == 0)
		matte_out = m;
	if ( output_opt == 1 )
		matte_out = m * (1.0 - h_m);
	
    gl_FragColor = vec4(c, matte_out);
}

//Front input needs to be unpremultiplied, otherwise it won't be able to exract any info and you'll just get a big black BG.
//We could improve this matchbox by Providing a color picker instead of asking for a color reference. It would be easier to use, but a little bit less powerful.