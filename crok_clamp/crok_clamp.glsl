uniform sampler2D source;
uniform float c_sat, c_lum;


// RGB to Rec709 YPbPr
vec3 yuv(vec3 rgb) {
    return mat3(0.2126, -0.0991, 0.615, 0.7152, -0.33609, -0.55861, 0.0722, 0.436, -0.05639) * rgb;
}

// Rec709 YPbPr to RGB
vec3 rgb(vec3 yuv) {
    return mat3(1.0, 1.0, 1.0, 0.0, -0.21482, 2.12798, 1.28033, -0.38059, 0.0) * yuv;
}


void main(void)
{
	vec2 uv = gl_TexCoord[0].xy;
	vec3 col = texture2D(source, uv).rgb;

	// convert to Rec709 YPbPr 
	col = yuv(col);
	
	// clamp the saturation
	col.gb /= max(length(col.gb)/c_sat*2., 1.0);
	
	// clamp the luminance
	col.r /= max(col.r/c_lum, 1.0);
		
	// convert back to RGB 
	col = rgb(col);
  
	gl_FragColor = vec4(col.rgb, col.r);
}