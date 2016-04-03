#version 120
// blur Result of Beauty Comp Vertical to get a shine
uniform float blur_s, adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass12;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(blur_s);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 blur_bgy = vec4(0.0);
   
   for( int y = -f0int; y <= f0int; y++)
   {
      vec2 currentCoord = vec2(coords.x, coords.y+float(y)/adsk_result_h);
      vec4 aSample = texture2D(adsk_results_pass12, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(y)) / blur_s);
      energy += anEnergy;
      accu+= aSample * anEnergy;
  }
   
   blur_bgy = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass12, coords).rgba;
                     
   gl_FragColor = vec4( blur_bgy );
}