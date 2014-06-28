uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Speed_red, Offset_red, Speed_green, Offset_green, Speed_blue, Offset_blue, Speed_alpha;
uniform float zoom, zoom_red, zoom_green, zoom_blue;
uniform float brightness;
uniform float contrast;
uniform float saturation;
uniform float tint;
uniform vec3 tint_col;

	
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.05;

const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);

// http://pixelshaders.com/examples/noise.html


float random(float p) {
  return fract(sin(p)*10000.);
}

float noise(vec2 p) {
  return random(p.x + p.y*10000.);
}

vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

float smoothNoise(vec2 p) {
  vec2 inter = smoothstep(0. , 1., fract(p));
  float s = mix(noise(sw(p)), noise(se(p)), inter.x);
  float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
  return mix(s, n, inter.y);
  return noise(nw(p));
}

float movingNoise_red(vec2 p) {
  float total = 0.0;
  total += smoothNoise(p     - time * Speed_red + Offset_red);
  total += smoothNoise(p*2.  + time * Speed_red + Offset_red) / 2.;
  total += smoothNoise(p*4.  - time * Speed_red + Offset_red) / 4.;
  total += smoothNoise(p*8.  + time * Speed_red + Offset_red) / 8.;
  total += smoothNoise(p*16. - time * Speed_red + Offset_red) / 16.;
  total += smoothNoise(p*32. + time * Speed_red + Offset_red) / 32.;
  total += smoothNoise(p*64. - time * Speed_red + Offset_red) / 64.;
  total += smoothNoise(p*128. + time * Speed_red + Offset_red) / 128.;

  total /= 1. + 1./2. + 1./4. + 1./8. + 1./16. + 1./32. + 1./64. + 1./128.;
  return total;
}

float nestedNoise_red(vec2 p) 
{
  float x = movingNoise_red(p);
  float y = movingNoise_red(p + 10.);
  return movingNoise_red(p + vec2(x, y));
}

float movingNoise_green(vec2 p) {
  float total = 0.0;
  total += smoothNoise(p     - time * Speed_green + Offset_green);
  total += smoothNoise(p*2.  + time * Speed_green + Offset_green) / 2.;
  total += smoothNoise(p*4.  - time * Speed_green + Offset_green) / 4.;
  total += smoothNoise(p*8.  + time * Speed_green + Offset_green) / 8.;
  total += smoothNoise(p*16. - time * Speed_green + Offset_green) / 16.;
  total += smoothNoise(p*32. + time * Speed_green + Offset_green) / 32.;
  total += smoothNoise(p*64. - time * Speed_green + Offset_green) / 64.;
  total += smoothNoise(p*128. + time * Speed_green + Offset_green) / 128.;

  total /= 1. + 1./2. + 1./4. + 1./8. + 1./16. + 1./32. + 1./64. + 1./128.;
  return total;
}

float nestedNoise_green(vec2 p) 
{
  float x = movingNoise_green(p);
  float y = movingNoise_green(p + 10.);
  return movingNoise_green(p + vec2(x, y));
}

float movingNoise_blue(vec2 p) {
  float total = 0.0;
  total += smoothNoise(p     - time * Speed_blue + Offset_blue);
  total += smoothNoise(p*2.  + time * Speed_blue + Offset_blue) / 2.;
  total += smoothNoise(p*4.  - time * Speed_blue + Offset_blue) / 4.;
  total += smoothNoise(p*8.  + time * Speed_blue + Offset_blue) / 8.;
  total += smoothNoise(p*16. - time * Speed_blue + Offset_blue) / 16.;
  total += smoothNoise(p*32. + time * Speed_blue + Offset_blue) / 32.;
  total += smoothNoise(p*64. - time * Speed_blue + Offset_blue) / 64.;
  total += smoothNoise(p*128. + time * Speed_blue + Offset_blue) / 128.;

  total /= 1. + 1./2. + 1./4. + 1./8. + 1./16. + 1./32. + 1./64. + 1./128.;
  return total;
}

float nestedNoise_blue(vec2 p) 
{
  float x = movingNoise_blue(p);
  float y = movingNoise_blue(p + 10.);
  return movingNoise_blue(p + vec2(x, y));
}

void main() 
{
	vec2 uv = (gl_FragCoord.xy / iResolution.xy);
    vec3 avg_lum = vec3(0.5, 0.5, 0.5);
	
	float col_red = nestedNoise_red(2.0 * (uv - 0.5) * zoom_red);
	float col_green = nestedNoise_green( 2.0 * (uv - 0.5) * zoom_green);
	float col_blue = nestedNoise_blue( 2.0 * (uv - 0.5) * zoom_blue);
	
	vec3 intensity = vec3(dot(vec3(col_red, col_green, col_blue), LumCoeff));
	vec3 sat_color = mix(intensity, vec3(col_red, col_green, col_blue ), saturation);
    vec3 con_color = mix(avg_lum, sat_color, contrast);
	vec3 brt_color = con_color - 1.0 + brightness;
	vec3 fin_color = mix(brt_color, brt_color * tint_col, tint);
	
		
    gl_FragColor = vec4(fin_color, 1.0);

}