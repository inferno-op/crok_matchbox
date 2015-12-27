uniform sampler2D adsk_results_pass3, Matte;
uniform float blur_matte, adsk_result_w, adsk_result_h;


void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(blur_matte);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 blur_colorx = vec4(0.0);
   
   for( int x = -f0int; x <= f0int; x++)
   {
      vec2 currentCoord = vec2(coords.x+float(x)/adsk_result_w, coords.y);
      vec4 aSample = texture2D(adsk_results_pass3, currentCoord).rgba;
   	  aSample *= texture2D(Matte, currentCoord).rgba;
	  float anEnergy = 1.0 - ( abs(float(x)) / blur_matte);
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }
   
   blur_colorx = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass3, coords).rgba;
                     
   gl_FragColor = vec4( blur_colorx );
}