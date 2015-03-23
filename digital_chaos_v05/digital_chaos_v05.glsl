#version 120

// based on http://glslsandbox.com/e#23874.0

//Original code from http://pixelshaders.com/editor/
//Ported to GLSL Sandbox on 3/23/15

uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

const float pi = 3.1415926;

float garb(vec2 v, float m) {
  return (mod(v.x*m + (1.-v.y)*m, (1.-v.x*m)+v.y*m));
}

void main() {
  vec2 pos = ( gl_FragCoord.xy / resolution.xy );
  float a = garb(vec2(pos.y, cos(atan(pos.y+pos.x+1000001.))), cos(time)+1.5);
  float c = garb(vec2(pos.y, sin(tan(pos.x+1000001.+time*.5))), cos(a+time)+1.5);
  gl_FragColor = vec4(.5*a+.15+.5*c,
                      .0*a+.2+.9*c,
                      .01*a+.3+.4*c,
                      1.);
}