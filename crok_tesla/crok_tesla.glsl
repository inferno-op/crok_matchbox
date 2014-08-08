#version 120
	
uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform float Offset, amp, speed, l_scale, h_scale, y_scale, noOfBolts;
uniform float p1, p2, p3, Gamma;
uniform float gamma, brightness, saturation, tint, contrast;
uniform bool locked;
uniform vec3 tint_col;


const int iteration = 7;

float time = adsk_time *.01 * speed + Offset;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);

// https://www.shadertoy.com/view/Mds3W7

// Lightning shader
// rand,noise,fmb functions from https://www.shadertoy.com/view/Xsl3zN
// jerome

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 n) {
    vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i < iteration; i++) {
        total += noise(n) * amplitude;
        n += n;
        amplitude *= 0.5 * amp;
    }
    return total;
}

float bolt(float shift){
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 t = uv * vec2(2.0,1.0) - (time + shift * 10.0)*3.0;
    float ycenter = fbm(t)*0.5;
        if ( locked ){
        ycenter = mix( 0.5 *p1, 0.25*p2 + 0.25*fbm( t ), uv.x * y_scale);
        }
    float diff = abs(uv.y - ycenter);
//    return clamp ((0.5 - diff  / scale * 100.), 0.0, 1.0);
    float hi_col = clamp ((0.5 - diff  / h_scale * 100.), 0.0, 1.0);
	float low_col = clamp ((0.5 - diff  / l_scale * 10.), 0.0, 1.0);
	return mix(low_col, hi_col, 0.5 );

    }

void main(void){

float lightning = 0.0;

for(float i = 0.0; i < noOfBolts; i++){
    lightning += bolt(i);
}

vec3 avg_lum = vec3(0.5, 0.5, 0.5);

vec3 col = pow(vec3(lightning), vec3(1.0 / (Gamma - 0.5)));
vec3 intensity = vec3(dot(col.rgb, LumCoeff));
vec3 con_color = mix(avg_lum, intensity, contrast);
vec3 brt_color = con_color - 1.0 + brightness;
vec3 fin_color = mix(brt_color, brt_color * tint_col, tint);

gl_FragColor = vec4(fin_color * 5., 1.0);









//	vec3 col = pow(vec3(lightning), vec3(1.0 / (Gamma - 0.5)));
 
//    gl_FragColor = vec4(col * tint, 1.0);
}