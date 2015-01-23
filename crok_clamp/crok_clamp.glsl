uniform sampler2D source;
uniform float c_sat, c_lum;

const vec3 lumcoeff = vec3(0.2126,0.7152,0.0722);


// RGB to Rec709 YPbPr
vec3 yuv(vec3 rgb) {
    return mat3(0.2215, -0.1145, 0.5016, 0.7154, -0.3855, -0.4556, 0.0721, 0.5, -0.0459) * rgb;
}

// Rec709 YPbPr to RGB
vec3 rgb(vec3 yuv) {
    return mat3(1.0, 1.0, 1.0, 0.0, -0.1870, 1.8556, 1.5701, -0.4664, 0.0) * yuv;
}


void main(void)
{
	vec2 uv = gl_TexCoord[0].xy;
	vec3 col = texture2D(source, uv).rgb;
	vec3 luma = vec3(dot(col.rgb, lumcoeff));

	// convert to HSV to seperate the saturation
	col = yuv(col);
	
	// clamp the saturation
	col.gb /= max(length(col.gb)/c_sat*2., 1.0);
	
	// clamp the luminance
	col.r /= max(col.r/c_lum, 1.0);
	
		
	// convert back to RGB 
	col = rgb(col);
  
	gl_FragColor = vec4(col.rgb, col.r);
}