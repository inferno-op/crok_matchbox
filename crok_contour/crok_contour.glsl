// Contour and Valley detection using GLSL
// http://www.forceflow.be/2010/04/14/contour-and-valley-detection-using-glsl/
#version 120
uniform sampler2D color;
uniform int radius;
uniform int renderwidth;

float intensity(in vec4 color)
{
	return sqrt((color.x*color.x)+(color.y*color.y)+(color.z*color.z));
}

vec3 simple_edge_detection(in float step, in vec2 center)
{
	float center_intensity = intensity(texture2D(color, center));
	int darker_count = 0;
	float max_intensity = center_intensity;
	for(int i = -radius; i <= radius; i++)
	{
		for(int j = -radius; j<= radius; j++)
		{
			vec2 current_location = center + vec2(i*step, j*step);
			float current_intensity = intensity(texture2D(color,current_location));
			if(current_intensity < center_intensity) 			{ 				darker_count++; 			} 			if(current_intensity > max_intensity)
			{
				max_intensity = current_intensity;
			}
		}
	}
	if((max_intensity - center_intensity) > 0.01*radius)
	{
		if(darker_count/(radius*radius) < (1-(1/radius)))
		{
			return vec3(0.0,0.0,0.0);
		}
	}
	return vec3(1.0,1.0,1.0);
}

void main(void)
{
	float step = 1.0/renderwidth;
	vec2 center_color = gl_TexCoord[0].st;
	gl_FragColor.rgb = simple_edge_detection(step,center_color);
}