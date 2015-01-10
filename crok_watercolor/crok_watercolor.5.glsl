#version 120
// y blur

uniform sampler2D adsk_results_pass4;
uniform float Blur, adsk_result_w, adsk_result_h;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(Blur);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 finalColor = vec4(0.0);
   
   for( int y = -f0int; y <= f0int; y++)
   {
      vec2 currentCoord = vec2(coords.x, coords.y+float(y)/adsk_result_h);
      vec4 aSample = texture2D(adsk_results_pass4, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(y)) / Blur );
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }
   
   finalColor = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass4, coords).rgba;
                     
   gl_FragColor = vec4( finalColor );
}
