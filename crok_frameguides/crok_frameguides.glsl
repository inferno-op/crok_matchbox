#version 120
// Shader written by:   Kyle, Miles, Lewis & Ivar

uniform sampler2D Source;

uniform float adsk_result_w, adsk_result_h, adsk_Source_frameratio, adsk_time, adsk_result_pixelratio, adsk_result_frameratio;
uniform float ratio, let_blend, guide_blend, center_blend, size, l_line_blend, l_ratio, offset;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform vec3 tint_action, tint_center, tint_letterbox, tint_l_line;
uniform bool letterbox, guides, center, counter, letterbox_line, relative_guide, t_offset, relative_lines;
uniform vec2 position;

float time = adsk_time;

const float Thickness = 2.0;

float drawLine(vec2 p1, vec2 p2) {
vec2 uv_line = gl_FragCoord.xy / resolution.xy;

float a = abs(distance(p1, uv_line));
float b = abs(distance(p2, uv_line)); 
float c = abs(distance(p1, p2));
if ( a >= c || b >=  c ) return 0.0;
float p = (a + b + c) * 0.5;
float h = 2. / c * sqrt( p * ( p - a) * ( p - b) * ( p - c));


return mix(1.0, 0.0, smoothstep(0.5 * Thickness * 0.001  , 1.5  * Thickness * 0.001, h * adsk_Source_frameratio));
}

// https://www.shadertoy.com/view/4sf3RN
// Number Printing - @P_Malin
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
const float kCharBlank = 12.0;
const float kCharMinus = 11.0;
const float kCharDecimalPoint = 10.0;

float InRect(const in vec2 vUV, const in vec4 vRect)
{
	vec2 vTestMin = step(vRect.xy, vUV.xy);
	vec2 vTestMax = step(vUV.xy, vRect.zw);	
	vec2 vTest = vTestMin * vTestMax;
	return vTest.x * vTest.y;
}

float SampleDigit(const in float fDigit, const in vec2 vUV)
{		
	if(vUV.x < 0.0) return 0.0;
	if(vUV.y < 0.0) return 0.0;
	if(vUV.x >= 1.0) return 0.0;
	if(vUV.y >= 1.0) return 0.0;
	
	// In this version, each digit is made up of a 4x5 array of bits
	float fDigitBinary = 0.0;
	if(fDigit < 0.5) // 0
	{
		fDigitBinary = 7.0 + 5.0 * 16.0 + 5.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 1.5) // 1
	{
		fDigitBinary = 2.0 + 2.0 * 16.0 + 2.0 * 256.0 + 2.0 * 4096.0 + 2.0 * 65536.0;
	}
	else if(fDigit < 2.5) // 2
	{
		fDigitBinary = 7.0 + 1.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 3.5) // 3
	{
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 4.5) // 4
	{
		fDigitBinary = 4.0 + 7.0 * 16.0 + 5.0 * 256.0 + 1.0 * 4096.0 + 1.0 * 65536.0;
	}
	else if(fDigit < 5.5) // 5
	{
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 6.5) // 6
	{
		fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 7.5) // 7
	{
		fDigitBinary = 4.0 + 4.0 * 16.0 + 4.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 8.5) // 8
	{
		fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 9.5) // 9
	{
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	}
	else if(fDigit < 10.5) // '.'
	{
		fDigitBinary = 2.0 + 0.0 * 16.0 + 0.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
	}
	else if(fDigit < 11.5) // '-'
	{
		fDigitBinary = 0.0 + 0.0 * 16.0 + 7.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
	}
	
	vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
	float fIndex = vPixel.x + (vPixel.y * 4.0);
	return mod(floor(fDigitBinary / pow(2.0, fIndex)), 2.0);
}

float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	float fAbsValue = abs(fValue);
	float fStringCharIndex = floor(vStringCharCoords.x);
	float fLog10Value = log2(fAbsValue) / log2(10.0);
	float fBiggestDigitIndex = max(floor(fLog10Value), 0.0);
	
	// This is the character we are going to display for this pixel
	float fDigitCharacter = kCharBlank;
	float fDigitIndex = fMaxDigits - fStringCharIndex;
	if(fDigitIndex > (-fDecimalPlaces - 1.5))
	{
		if(fDigitIndex > fBiggestDigitIndex)
		{
			if(fValue < 0.0)
			{
				if(fDigitIndex < (fBiggestDigitIndex+1.5))
				{
					fDigitCharacter = kCharMinus;
				}
			}
		}
		else
		{		
			if(fDigitIndex == -1.0)
			{
				if(fDecimalPlaces > 0.0)
				{
					fDigitCharacter = kCharDecimalPoint;
				}
			}
			else
			{
				if(fDigitIndex < 0.0)
				{
					// move along one to account for .
					fDigitIndex += 1.0;
				}
				float fDigitValue = (fAbsValue / (pow(10.0, fDigitIndex)));
				// This is inaccurate - I think because I treat each digit independently
				// The value 2.0 gets printed as 2.09 :/
				//fDigitCharacter = mod(floor(fDigitValue), 10.0);
				fDigitCharacter = mod(floor(0.0001+fDigitValue), 10.0); // fix from iq
			}		
		}
	}
	vec2 vCharPos = vec2(fract(vStringCharCoords.x), vStringCharCoords.y);
	return SampleDigit(fDigitCharacter, vCharPos);	
}

float PrintValue(const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	return PrintValue(((gl_FragCoord.xy) - vPixelCoords) / vFontSize, fValue, fMaxDigits, fDecimalPlaces);
}



void main()
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 source = vec3(texture2D(Source, uv).rgb);
	vec3 c_let = vec3(tint_letterbox);
	vec4 c_guide= vec4(0.0);
	vec3 center_alpha = vec3(0.0);
	vec3 guide_alpha = vec3(0.0);
	vec3 l_line_alpha = vec3(0.0);

	vec3 rl_line_alpha = vec3(0.0);
	
	vec3 c_col = vec3(0.0);
	vec4 fin_col = vec4(source, 1.0);
	float r_ratio = ratio;

// Letterbox
	if ( letterbox )
	{
		float lb = ((adsk_result_w / ratio * adsk_result_pixelratio) / adsk_result_h) / 2.;
		float pb = ((adsk_result_h * ratio / adsk_result_pixelratio) / adsk_result_w) / 2.;

		if (ratio < (adsk_result_w / adsk_result_h * adsk_result_pixelratio))
		{
			float dist_x = length(uv.x - 0.5);
			float pillarbox = smoothstep(pb, pb, dist_x);
			fin_col.rgb = mix(fin_col.rgb, c_let, pillarbox * let_blend);
		} else {
			float dist_y = length(uv.y - 0.5);
			float letterbox = smoothstep(lb, lb, dist_y);
			fin_col.rgb = mix(fin_col.rgb, c_let, letterbox * let_blend);
		}
	}

// Letterbox Line
	if ( letterbox_line )
	{
		if (l_ratio < (adsk_result_w / adsk_result_h * adsk_result_pixelratio))
		{
			float l_line = (1.0 - ((adsk_result_h * l_ratio / adsk_result_pixelratio) / adsk_result_w)) / 2.0;
			l_line_alpha += vec3(max(drawLine(vec2(l_line, 0.0), vec2(l_line, 1.0)), drawLine (vec2(1.0 - l_line, 0.0 ), vec2(1.0 - l_line, 1.0))));
		} else {
			float l_line = (1.0 - ((adsk_result_w / l_ratio * adsk_result_pixelratio) / adsk_result_h)) / 2.0;
			l_line_alpha += vec3(max(drawLine(vec2(0.0, l_line), vec2(1.0, l_line)), drawLine (vec2(0.0, 1.0 - l_line), vec2(1.0, 1.0 - l_line))));
		}
	}

// draw center
	if ( center )
	{
		center_alpha += vec3(max(drawLine(vec2(0.47, 0.5), vec2(0.53, 0.5)), drawLine (vec2(0.5, 0.47), vec2(0.5, 0.53))));
	}

// draw action safe
	if ( guides )
	{
		if ( relative_guide )
		{
			if (relative_lines )
				r_ratio = l_ratio;
			
			// draw frame guides in relation to the applied letterbox
			float new_result_h = (adsk_result_w / r_ratio * adsk_result_pixelratio);
			float new_result_a_h = new_result_h - new_result_h * .1;
			float pillar_action_line = new_result_a_h;
			float new_line_h = (1.0 - (new_result_a_h) / adsk_result_h) / 2.0;
			float new_aline_v = (1.0 - ((new_result_a_h * r_ratio / adsk_result_pixelratio) / adsk_result_w)) / 2.0;

			new_result_h -= new_result_h * .2;
			float new_t_line_h = (1.0 - (new_result_h) / adsk_result_h) / 2.0;
			float new_t_line_v = (1.0 - ((new_result_h * r_ratio / adsk_result_pixelratio) / adsk_result_w)) / 2.0;
			
			if (r_ratio < (adsk_result_w / adsk_result_h * adsk_result_pixelratio))
			{
				float pb_line = (1.0 - ((adsk_result_h * r_ratio / adsk_result_pixelratio) / adsk_result_w)) / 2.0;
				float pb_a_line = new_aline_v + (pb_line - pb_line *.1);
				float pb_t_line = new_t_line_v + (pb_line - pb_line * .2);

				// draw relatvie action safe
				guide_alpha += vec3(max(drawLine(vec2(pb_a_line, new_aline_v ), vec2(pb_a_line, 1.0 - new_aline_v )), drawLine (vec2(1.0 - pb_a_line, new_aline_v), vec2(1.0 - pb_a_line, 1.0 - new_aline_v))));
				guide_alpha += vec3(max(drawLine(vec2(pb_a_line, new_aline_v ), vec2(1.0 - pb_a_line, new_aline_v )), drawLine (vec2(pb_a_line, 1.0 - new_aline_v), vec2(1.0 - pb_a_line, 1.0 - new_aline_v))));
				// draw relative title safe
				guide_alpha += vec3(max(drawLine(vec2(pb_t_line, new_t_line_v ), vec2(pb_t_line, 1.0 - new_t_line_v )), drawLine (vec2(1.0 - pb_t_line, new_t_line_v), vec2(1.0 - pb_t_line, 1.0 - new_t_line_v))));
				guide_alpha += vec3(max(drawLine(vec2(pb_t_line, new_t_line_v ), vec2(1.0 - pb_t_line, new_t_line_v )), drawLine (vec2(pb_t_line, 1.0 - new_t_line_v), vec2(1.0 - pb_t_line, 1.0 - new_t_line_v))));
		
			} else {
			
// draw relatvie action safe
			guide_alpha += vec3(max(drawLine(vec2(new_aline_v, new_line_h), vec2(1.0 - new_aline_v, new_line_h)), drawLine (vec2(new_aline_v, 1.0 - new_line_h), vec2(1.0 - new_aline_v, 1.0 - new_line_h))));
			guide_alpha += vec3(max(drawLine(vec2(new_aline_v, new_line_h), vec2(new_aline_v, 1.0 - new_line_h)), drawLine (vec2(1.0 - new_aline_v, new_line_h), vec2(1.0 - new_aline_v, 1.0 - new_line_h))));
// draw relative title safe
			guide_alpha += vec3(max(drawLine(vec2(new_t_line_v, new_t_line_h), vec2(1.0 - new_t_line_v, new_t_line_h)), drawLine (vec2(new_t_line_v, 1.0 - new_t_line_h), vec2(1.0 - new_t_line_v, 1.0 - new_t_line_h))));
			guide_alpha += vec3(max(drawLine(vec2(new_t_line_v, new_t_line_h), vec2(new_t_line_v, 1.0 - new_t_line_h)), drawLine (vec2(1.0 - new_t_line_v, new_t_line_h), vec2(1.0 - new_t_line_v, 1.0 - new_t_line_h))));
			
		}
		
		} else {
// draw action safe
			guide_alpha += vec3(max(drawLine(vec2(0.05, 0.05), vec2(0.05, 0.95)), drawLine (vec2(0.95, 0.05), vec2(0.95, 0.95))));
			guide_alpha += vec3(max(drawLine(vec2(0.05, 0.05), vec2(0.95, 0.05)), drawLine (vec2(0.05, 0.95), vec2(0.95, 0.95))));
	
// draw title safe
			guide_alpha += vec3(max(drawLine(vec2(0.1, 0.1), vec2(0.1, 0.9)), drawLine (vec2(0.9, 0.1), vec2(0.9, 0.9))));
			guide_alpha += vec3(max(drawLine(vec2(0.1, 0.1), vec2(0.9, 0.1)), drawLine (vec2(0.1, 0.9), vec2(0.9, 0.9))));
		}
	}
	
	
	
	
//  frame counter
	if ( counter )
	{
		vec2 vFontSize = vec2(8.0 * size, 15.0 * size);

		if ( t_offset )
			time = adsk_time + offset;

		float fValue2 = time;

		float fDigits = 7.0;
		float fDecimalPlaces = 0.0;
		float fIsDigit2 = PrintValue(position*resolution, vFontSize, fValue2, fDigits, fDecimalPlaces);
		c_col = mix( c_col, vec3(1.0, 1.0, 1.0), fIsDigit2);
	}

// clamp before composite
		guide_alpha = clamp(guide_alpha, 0.0, 1.0);
		center_alpha = clamp(center_alpha, 0.0, 1.0);
		
		fin_col.rgb = mix(fin_col.rgb, tint_action, guide_alpha * guide_blend);
		fin_col.rgb = mix(fin_col.rgb, tint_center, center_alpha * center_blend);
		fin_col.rgb = mix(fin_col.rgb, tint_l_line, l_line_alpha * l_line_blend);
		fin_col.rgb = mix(fin_col.rgb, c_col, c_col);
		
		gl_FragColor = vec4(fin_col);
	}
