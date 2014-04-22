// Add the adsk_result_w and adsk_result_h uniform to normalize the coords between 0 and 1. 
// That way, 0 and 1 will map to any clip resolution, including the Proxy resolution

uniform float sizeProp, lineProp, rotation, rotationCentre, adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform bool propwidth, propgridsize;

// Changing Line and Size to vec2 instead of float so we can modify the x and y values individually
uniform vec2 line, size;

// Adding User-definable colors for the Grid and Background
uniform vec3 gridcolor, backcolor;

void main( void ) {

// Normalize the coords by dividing it by the Node Resolution
        vec2 position = gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);  
        
//Check if the Prop button is enabled or not
        float sizeValueX = propgridsize ? sizeProp : size.x;
        float lineValueX = propwidth ? lineProp : line.x;
        float sizeValueY = propgridsize ? sizeProp : size.y;
        float lineValueY = propwidth ? lineProp : line.y;
        
// Define OutputColor, which is used for the gl_FragColor at the end
        vec3 OutputColor;

// Rotation Matrix
   mat2 rotationMatrice = mat2( cos(-rotation), -sin(-rotation), 
                          sin(-rotation), cos(-rotation) );

   //We remove 0.5 from the coords to apply the rotation.
   position -= vec2(rotationCentre);
   
   //We multiply the X value by the frame ratio before applying the rotation.
   position.x *= adsk_result_frameratio;
   
   //We apply the rotation
   position *= rotationMatrice;

   //We divide the X value by the frame ratio after applying the rotation.
   position.x /= adsk_result_frameratio;
   
   //We add the 0.5 we substracted back to the coords before applying the rotation.
   position += vec2(rotationCentre);

// Divide sizeValue and lineValue so the manipulation in the numeric makes more sense
	if(mod(position.x, sizeValueX / 10.0) <= lineValueX / adsk_result_w)
	{
		OutputColor = gridcolor;
	}
	else if(mod(position.y, sizeValueY / 10.0) <= lineValueY / adsk_result_h)
	{
		OutputColor = gridcolor;
	}
	else
	{
		OutputColor = backcolor;
	}

	gl_FragColor = vec4( OutputColor, 1.0 );
}
