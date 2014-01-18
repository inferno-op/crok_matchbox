uniform float adsk_result_w, adsk_result_h;
uniform sampler2D iChannel0;

uniform int pCellsize;


vec2 iResolution = vec2(adsk_result_w, adsk_result_h);

// RGB display
// created by Daniil in 17/6/2013

float CELL_SIZE_FLOAT = float(pCellsize);
int RED_COLUMNS = int(CELL_SIZE_FLOAT/3.);
int GREEN_COLUMNS = pCellsize-RED_COLUMNS;

void main(void)
{

	vec2 p = floor(gl_FragCoord.xy / CELL_SIZE_FLOAT)*CELL_SIZE_FLOAT;
	int offsetx = int(mod(gl_FragCoord.x,CELL_SIZE_FLOAT));
	int offsety = int(mod(gl_FragCoord.y,CELL_SIZE_FLOAT));

	vec4 sum = texture2D(iChannel0, p / iResolution.xy);
	
	gl_FragColor = vec4(0.,0.,0.,1.);
	if (offsety < pCellsize-1) {		
		if (offsetx < RED_COLUMNS) gl_FragColor.r = sum.r;
		else if (offsetx < GREEN_COLUMNS) gl_FragColor.g = sum.g;
		else gl_FragColor.b = sum.b;
	}
	
}