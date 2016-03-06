#version 120
// blur comp
uniform float blur_comp, adsk_result_w, adsk_result_h;

uniform sampler2D adsk_results_pass2;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(blur_comp);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 blur_compy = vec4(0.0);
   
   for( int y = -f0int; y <= f0int; y++)
   {
      vec2 currentCoord = vec2(coords.x, coords.y+float(y)/adsk_result_h);
      vec4 aSample = texture2D(adsk_results_pass2, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(y)) / blur_comp);
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }
   
   blur_compy = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass2, coords).rgba;
                     
   gl_FragColor = vec4( blur_compy );
}
