#version 120
// blur colour noise in x

uniform sampler2D adsk_results_pass14;
uniform float blur, adsk_result_w, adsk_result_h, size;

void main()
{
    vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   float softness = (1.0 + blur);
   int f0int = int(softness);
   vec4 accu = vec4(0.0);
   float energy = 0.0;
   vec4 finalColor = vec4(0.0);
   
   for( int x = -f0int; x <= f0int; x++)
   {
      vec2 currentCoord = vec2(coords.x+float(x)/adsk_result_w, coords.y);
      vec4 aSample = texture2D(adsk_results_pass14, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(x)) / softness);
      energy += anEnergy;
      accu += aSample * anEnergy;
   }
   
   finalColor = 
	   energy > 0.0 ? (accu / energy) : 
                    texture2D(adsk_results_pass14, coords).rgba;

                     
   gl_FragColor = vec4( finalColor );
}
