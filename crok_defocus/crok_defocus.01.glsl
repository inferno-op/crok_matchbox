
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D front, matte;


void main()
{
   vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 col = clamp(vec3( texture2D(front, uv).rgb), 0.0, 10000000000.0);
   float matte = texture2D(matte, uv).b;
   col *= matte;
   gl_FragColor = vec4(col, matte);
}
