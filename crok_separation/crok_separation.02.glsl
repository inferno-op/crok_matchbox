#version 120
#extension GL_ARB_shader_texture_lod : enable

uniform float blur_fg, adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   int f0int = int(blur_fg);
   vec4 accu = vec4(0);
   float energy = 0.0;
   vec4 blur_fg_y = vec4(0.0);
   
   for( int y = -f0int; y <= f0int; y++)
   {
      vec2 currentCoord = vec2(coords.x, coords.y+float(y)/adsk_result_h);
      vec4 aSample = texture2D(adsk_results_pass1, currentCoord).rgba;
      float anEnergy = 1.0 - ( abs(float(y)) / blur_fg);
      energy += anEnergy;
      accu+= aSample * anEnergy;
   }
   
   blur_fg_y = 
      energy > 0.0 ? (accu / energy) : 
                     texture2D(adsk_results_pass1, coords).rgba;
                     
   gl_FragColor = vec4( blur_fg_y );
}
