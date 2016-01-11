#version 120
// applying x blur on desplilled fg and matte

uniform sampler2D adsk_results_pass4;
uniform float blur, adsk_result_w, adsk_result_h;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(blur);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 finalColor = vec4(0.0);
   
   for( int x = -f0int; x <= f0int; x++)
   {
      vec2 currentCoord = vec2(coords.x+float(x)/adsk_result_w, coords.y);
      vec3 front_blur = texture2D(adsk_results_pass4, currentCoord).rgb;
      float matte_blur = texture2D(adsk_results_pass4, currentCoord).a;
	  vec4 aSample = vec4(front_blur, matte_blur);
      float anEnergy = 1.0 - ( abs(float(x)) / blur );
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }
   
   finalColor = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass4, coords).rgba;

                     
   gl_FragColor = vec4( finalColor );
}
