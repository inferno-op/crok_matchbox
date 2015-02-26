
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D front, matte;


void main()
{
   vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   
   gl_FragColor = clamp(vec4( texture2D(front, uv).rgb, texture2D(matte, uv).b ), 0.0, 10000000000.0);
}
