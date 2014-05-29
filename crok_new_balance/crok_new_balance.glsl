uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform float level;
uniform int colourspace;
uniform int Computing;
uniform float Amount;


#extension GL_ARB_shader_texture_lod : enable

void main(void)
{
vec2 st = gl_FragCoord.xy / res;

vec4 tc = texture2D(Front, st);

vec4 front = texture2D(Front, st);
vec4 front_a = texture2DLod(Front, st, level - 0.5);

   if( colourspace == 0)  // Rec 709 input is selected
	{  
	  if( Computing == 0)
	  {
		  front /= 2.0 * front_a;
	  }
	   if( Computing == 1)
		   front-=front_a+0.244459-0.918031;

	   if( Computing == 2)
		   front-=front_a-(front_a[0]+front_a[1]+front_a[2])/3.0;
	   
   }
   
   if( colourspace == 1)  // Linear input is selected
	   front /= 2.0 * front_a;


   	front = mix(tc, front, Amount);
	
gl_FragColor = front;

}
