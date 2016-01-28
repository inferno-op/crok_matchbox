#version 120
// based on http://glslsandbox.com/e#28291.3 by gigatron
// gigatron gl test. 
// cheap noise based on https://www.shadertoy.com/view/XtsXRn  by dgreensp

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio, adsk_time;
uniform sampler2D texture;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform float offset;

float time = adsk_time *.01 + offset;

 
uniform float speed; //=0.80;
uniform float baseRadius; 
uniform float colorVariation; // 1.0;
uniform float brightnessVariation; // 0.00;
vec3 backgroundColor=vec3(0.0,0.0,0.0);
uniform float variation; //1.08;
uniform float size;
uniform float noise_multiplier;



vec3 n(vec2 x, float t) {
    vec3 v = floor(vec3(x, t));
    vec3 u = vec3(mod(v.xy, variation), v.z);
    vec3 c = fract( u.xyz * (
        vec3(0.16462, 0.84787, 0.98273) +
        u.xyz * vec3(0.24808, 0.75905, 0.13898) +
        u.yzx * vec3(0.31517, 0.62703, 0.26063) +
        u.zxy * vec3(0.47127, 0.58568, 0.37244)
    ) + u.yzx * (
        vec3(0.35425, 0.65187, 0.12423) +
        u.yzx * vec3(0.95238, 0.93187, 0.95213) +
        u.zxy * vec3(0.31526, 0.62512, 0.71837)
    ) + u.zxy * (
        vec3(0.95213, 0.13841, 0.16479) +
        u.zxy * vec3(0.47626, 0.69257, 0.19738)
    ) );
    return v + c;
}


vec3 col(vec2 x, float t) 
{
    return vec3(0.5 + max( brightnessVariation * cos( x.y * x.x ), 0.0 )) + clamp(colorVariation * cos(fract(vec3(x, t)) * 371.0241), vec3( -0.4 ), vec3( 1.0 ));
}

vec2 idx(vec2 x) 
{
    return floor(fract(x * 29.0) * 3.0) - vec2(1.0);
}

float circle(vec2 x, vec2 c, float r) 
{
    return max(0.0, 1.0 - dot(x - c, x - c) / (r * r));
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.-2.*f);
	
    float n = p.x + p.y*157. + 113.*p.z;
    
    vec4 v1 = fract(753.5453123*sin(n + vec4(0., 1., 157., 158.)));
    vec4 v2 = fract(753.5453123*sin(n + vec4(113., 114., 270., 271.)));
    vec4 v3 = mix(v1, v2, f.z);
    vec2 v4 = mix(v3.xy, v3.zw, f.y);
    return mix(v4.x, v4.y, f.x);
}

float fnoise(vec3 p) {
  // random rotation reduces artifacts
  p = mat3(0.28862355854826727, 0.6997227302779844, 0.6535170557707412,
         0.06997493955670424, 0.6653237235314099, -0.7432683571499161,
        -0.9548821651308448, 0.26025457467376617, 0.14306504491456504)*p;
  return dot(vec4(noise(p), noise(p*2.), noise(p*4.), noise(p*8.)),
             vec4(0.5, 0.25, 0.125, 0.06));
}

void main() {
    
    vec2 x =  ((gl_FragCoord.xy / resolution.xy) - 0.5) / size * 5.0;
	x.x *= adsk_result_frameratio;

    float t = time * speed;
    vec4 c = vec4(vec3(0.0), 0.1);
	vec3 p = vec3(x, 0.);
	
    
    for (int N = 0; N < 3; N++) {
        for (int k = -1; k <= 0; k++) {
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    vec2 X = x + vec2(j, i);
                    float t = t + float(N) * 38.0;
                    float T = t + float(k);
                    vec3 a = n(X, T);
                    vec2 o = idx(a.xy);
                    vec3 b = n(X + o, T + 1.0);
                    vec2 m = mix(a.xy, b.xy, (t - a.z) / (b.z - a.z));
                    float r = baseRadius * .2 * sin(3.1415927 * clamp((t - a.z) / (b.z - a.z), 0.0, 1.0));
                    if (length(a.xy - b.xy) / (b.z - a.z) > 2.0) {
                        r = 0.0;
                    }
					//m += noise(p) * noise_multiplier;
                    c += vec4(col(a.xy, a.z), 1.0) * circle(x, m, r);
                }
            }
        }
    }
    
    gl_FragColor = vec4(c.rgb / max(1e-5, c.w) + backgroundColor, 1.0);
    
}