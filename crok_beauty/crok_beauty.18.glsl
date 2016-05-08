#version 120
// Regrain cleaned Skin

// original skin, cleaned skin, degrained skin
uniform sampler2D adsk_results_pass1, adsk_results_pass15, adsk_results_pass17;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec4 source = texture2D(adsk_results_pass1, uv);
   vec4 c_skin = texture2D(adsk_results_pass15, uv);
   vec4 degrain_source = texture2D(adsk_results_pass17, uv);
   vec4 col = vec4(0.0);
   vec3 grain = source.rgb - degrain_source.rgb;
   col.rgb = grain + c_skin.rgb;
   col.rgb = c_skin.a * col.rgb + (1.0 - c_skin.a) * c_skin.rgb;
   
	
   //col.rgb = c_skin.a * col.rgb + (1.0 - c_skin.a) * c_skin.rgb;
   //c = vec3(matte * c + (1.0 - matte) * original);
                    
   gl_FragColor = vec4(col.rgb, c_skin.a) ;
}