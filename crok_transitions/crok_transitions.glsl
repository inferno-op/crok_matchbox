// https://github.com/glslio/glsl-transition/tree/master/example/transitions

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

// General parameters
uniform sampler2D from;
uniform sampler2D to;
uniform float progress;
uniform int transition;
uniform float smoothness;
const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 boundMin = vec2(0.0, 0.0);
const vec2 boundMax = vec2(1.0, 1.0);
float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// circle_open
uniform bool opening;
uniform float circle_smoothness;
const vec2 center = vec2(0.5, 0.5);
const float SQRT_2 = 1.414213562373;

// blur
uniform int BLUR_QUALITY;
uniform float blur_size;
const float GOLDEN_ANGLE = 2.399963229728653; // PI * (3.0 - sqrt(5.0))
vec4 blur(sampler2D t, vec2 c, float radius) {
  vec4 sum = vec4(0.0);
  float q = float(BLUR_QUALITY);
  // Using a "spiral" to propagate points.
  for (int i=0; i<BLUR_QUALITY; ++i) {
    float fi = float(i);
    float a = fi * GOLDEN_ANGLE;
    float r = sqrt(fi / q) * radius;
    vec2 p = c + r * vec2(cos(a), sin(a));
    sum += texture2D(t, p);
  }
  return sum / q;
}

// fade grayscale
uniform float grayPhase; // if 0.0, the image directly turn grayscale, if 0.9, the grayscale transition phase is very important
vec3 grayscale (vec3 color) {
  return vec3(0.2126*color.r + 0.7152*color.g + 0.0722*color.b);
}

// fade to color
uniform vec3 color;
uniform float colorPhase; // if 0.0, there is no black phase, if 0.9, the black phase is very important

// flash
uniform float flashPhase; // if 0.0, the image directly turn grayscale, if 0.9, the grayscale transition phase is very important
uniform float flashIntensity;
uniform float flashZoomEffect;
uniform vec3 flashColor; // vec3(1.0, 0.8, 0.3)
uniform float flashVelocity; // 3.0


// squares
	uniform vec2 squares_size;
	uniform float squares_smoothness;

	
// wipe
	uniform vec2 wipe_direction;
	uniform float wipe_smoothness;





void main() {
  vec2 p = gl_FragCoord.xy / resolution.xy;
  vec2 center = vec2(.5);
  vec4 fc = texture2D(from, p);
  vec4 tc = texture2D(to, p);

// fade
  if ( transition == 0)
  {
	  gl_FragColor = mix(texture2D(from, p), texture2D(to, p), progress);
  }

// fade grayscale
  else if ( transition == 1)
  {
	  gl_FragColor = mix(mix(vec4(grayscale(fc.rgb), 1.0), texture2D(from, p), smoothstep(1.0-grayPhase, 0.0, progress)), mix(vec4(grayscale(tc.rgb), 1.0), texture2D(to, p), smoothstep(grayPhase, 1.0, progress)), progress);
  }

// fade to color
  else if ( transition == 2)
	  gl_FragColor = mix(mix(vec4(color, 1.0), texture2D(from, p), smoothstep(1.0-colorPhase, 0.0, progress)), mix(vec4(color, 1.0), texture2D(to, p), smoothstep(colorPhase, 1.0, progress)), progress);

// flash
  else if ( transition == 3)
  {
	  float intensity = mix(1.0, 2.0*distance(p, vec2(0.5, 0.5)), flashZoomEffect) * flashIntensity * pow(smoothstep(flashPhase, 0.0, distance(0.5, progress)), flashVelocity);
	  vec4 c = mix(texture2D(from, p), texture2D(to, p), smoothstep(0.5*(1.0-flashPhase), 0.5*(1.0+flashPhase), progress));
	  c += intensity * vec4(flashColor, 1.0);
	  gl_FragColor = c;
  }

// blur
  else if ( transition == 4)
  {
	  float inv = 1.-progress;
	  gl_FragColor = inv*blur(from, p, progress*blur_size * .01) + progress*blur(to, p, inv*blur_size * .01);
  }

// circle open		
  else if ( transition == 5)
  {
	  float x = opening ? progress : 1.-progress;
	  float m = smoothstep(- circle_smoothness, 0.0, SQRT_2*distance(center, p) - x*(1.+circle_smoothness));
	  gl_FragColor = mix(texture2D(from, p), texture2D(to, p), opening ? 1.-m : m);
  }

// squares
  else if ( transition == 11)
  {
	  float r = rand(floor(squares_size * p));
	  float m = smoothstep(0.0, -squares_smoothness, r - (progress * (1.0 + squares_smoothness)));
	  gl_FragColor = mix(texture2D(from, p), texture2D(to, p), m);
  }
		
// wipe
    else if ( transition == 15)
	{
	    vec2 v = normalize(wipe_direction);
	    v /= abs(v.x)+abs(v.y);
	    float d = v.x * center.x + v.y * center.y;
	    float m = smoothstep(- wipe_smoothness, 0.0, v.x * p.x + v.y * p.y - (d-0.5+progress*(1.+ wipe_smoothness)));
	    gl_FragColor = mix(texture2D(to, p), texture2D(from, p), m);
	}
}