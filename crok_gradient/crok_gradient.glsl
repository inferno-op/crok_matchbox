// based on https://www.shadertoy.com/view/ltjXDt by anastadunbar

uniform float adsk_result_w, adsk_result_h, adsk_time, adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform vec2 point1, point2, point3, point4, point5, point6;
uniform sampler2D source;
uniform bool invert;
uniform int style;
uniform int adskUID_blendModes;
uniform float scale, aspect, bias_adj, blend;
uniform vec3 col1, col2;
vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor ); 


float adsk_getLuminance ( vec3 rgb );
#define PI 3.141592653589793238462

vec2 rotation(float rot,vec2 pos)
{
    mat2 rotation = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
    return vec2(pos*rotation);
}
float gradient_linedist(vec2 uv, vec2 p1, vec2 p2) {
    return abs(((p2.x-p1.x)*(p1.y-uv.y))-((p1.x-uv.x)*(p2.y-p1.y)))/length(p1-p2);
}
float gradient_radial(vec2 uv, vec2 p3, vec2 p4) 
{
    return length(uv-p3)/length(p3-p4);
}
float gradient_diamond(vec2 uv, vec2 p1, vec2 p2) {
    float a = (atan(p1.x-p2.x,p1.y-p2.y)+PI)/(PI*2.);
    vec2 d = rotation((a*PI*2.)+(PI/4.),uv-p1);
    vec2 d2 = rotation((a*PI*2.)+(PI/4.),p1-p2);
    return max(abs(d.x),abs(d.y))/max(abs(d2.x),abs(d2.y));
}
float gradient_angle(vec2 uv, vec2 p1, vec2 p2) {
    float a = (atan(p1.x-p2.x,p1.y-p2.y)+PI)/(PI*2.);
    return fract((atan(p1.x-uv.x,p1.y-uv.y)+PI)/(PI*2.)-a);
}
float gradient_linear(vec2 uv, vec2 p1, vec2 p2) {
    float a = (atan(p1.x-p2.x,p1.y-p2.y)+PI)/(PI*2.);
    uv -= p1;
    uv = uv/length(p1-p2);
    uv = rotation((a*PI*2.)-(PI/2.),uv);
    return uv.x;
}

float bias(float x, float b) 
{
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}

void main() 
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 front = texture2D(source, uv).rgb;
    uv.x *= adsk_result_frameratio * aspect;
	vec2 p_point1 = vec2(point1.x * adsk_result_frameratio, point1.y);
	vec2 p_point2 = vec2(point2.x * adsk_result_frameratio, point2.y);
	vec2 p_point3 = vec2(point3.x * adsk_result_frameratio * aspect, point3.y);
	vec2 p_point4 = vec2(point4.x * adsk_result_frameratio * aspect, point4.y);
	vec2 p_point5 = vec2(point5.x * adsk_result_frameratio, point5.y);
	vec2 p_point6 = vec2(point6.x * adsk_result_frameratio, point6.y);
	
	float drawing = 0.;
    
	if ( style == 0 )
	{
		drawing = gradient_linear(uv,p_point1,p_point2);
		if ( invert )
			drawing = 1.0 - drawing;
	}

	else if ( style == 1 )
	{
		drawing = gradient_radial(uv,p_point3,p_point4);
		if ( invert )
			drawing;
		else
			drawing = 1.0 - drawing;
	}
	
	else if ( style == 2 )
	{
		drawing = gradient_linedist(uv,p_point5,p_point6);
		if ( invert )
			drawing = 1.0 - drawing;
	}

	else if ( style == 3 )
    	drawing = gradient_diamond(uv,p_point1,p_point2);
	
	else if ( style == 4 )
		drawing = gradient_angle(uv,p_point1,p_point2);
    
	// post fx
	drawing = clamp(drawing, 0.0, 1.0);
	drawing = bias(drawing, bias_adj);
	
	vec3 col = vec3(drawing * col1 + (1.0 - drawing) * col2);
	col = adsk_getBlendedValue(adskUID_blendModes, vec4(front,1.0), vec4(col,1.0)).rgb;
	col = mix(front, col, blend );
    gl_FragColor = vec4(col, drawing);
}