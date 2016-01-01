#version 120
// Displace Matte low frequecny blur in x 

uniform sampler2D Displace;
uniform float blur_low, adsk_result_w, adsk_result_h;
uniform bool external_matte;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   float softness = blur_low;
   int f0int = int(softness);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 finalColor = vec4(0.0);


   for( int x = -f0int; x <= f0int; x++)
   {
      vec2 currentCoord = vec2(coords.x+float(x)/adsk_result_w, coords.y);
      vec4 aSample = texture2D(Displace, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(x)) / softness);
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }

   finalColor = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(Displace, coords).rgba;
               
   gl_FragColor = vec4( finalColor );
}
