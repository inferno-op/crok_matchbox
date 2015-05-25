// https://github.com/glslio/glsl-transition/tree/master/example/transitions

uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform float adsk_result_frameratio;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time * 0.05;

// General parameters
uniform sampler2D from;
uniform sampler2D to;
uniform float progress;
uniform int transition;
uniform float smoothness;
const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 boundMin = vec2(0.0, 0.0);
const vec2 boundMax = vec2(1.0, 1.0);
const float PI = 3.141592653589793;
float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


// circle_open
uniform bool opening;
uniform float circle_smoothness;
const vec2 center = vec2(0.5, 0.5);
const float SQRT_2 = 1.414213562373;
uniform float circle_aspect;

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
uniform float squares_size;
uniform float squares_smoothness;
uniform float squares_aspect;

	
// wipe
// uniform vec2 wipe_direction;
uniform float wipe_smoothness;
uniform float angle;

// morph
uniform float morph_strength;
	
// cross zoom
uniform float cz_strength;

// dreamy
uniform float amount;
uniform float detail;
uniform float speed;
uniform int wave_direction;

float Linear_ease(in float begin, in float change, in float duration, in float time) {
    return change * time / duration + begin;
}

float Exponential_easeInOut(in float begin, in float change, in float duration, in float time) {
    if (time == 0.0)
        return begin;
    else if (time == duration)
        return begin + change;
    time = time / (duration / 2.0);
    if (time < 1.0)
        return change / 2.0 * pow(2.0, 10.0 * (time - 1.0)) + begin;
    return change / 2.0 * (-pow(2.0, -10.0 * (time - 1.0)) + 2.0) + begin;
}

float Sinusoidal_easeInOut(in float begin, in float change, in float duration, in float time) {
    return -change / 2.0 * (cos(PI * time / duration) - 1.0) + begin;
}

/* random number between 0 and 1 */
float random(in vec3 scale, in float seed) {
    /* use the fragment position for randomness */
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec3 crossFade(in vec2 uv, in float dissolve) {
    return mix(texture2D(from, uv).rgb, texture2D(to, uv).rgb, dissolve);
}

// Slide
uniform int slide_direction;

// Radial
uniform int radial_center;
uniform float radial_smoothness;

// Simple Flip
uniform int flip_direction;

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

// morph		
  else if ( transition == 6)
  {
	  vec4 ca = texture2D(from, p);
	  vec4 cb = texture2D(to, p);
  
	  vec2 oa = (((ca.rg+ca.b)*0.5)*2.0-1.0);
	  vec2 ob = (((cb.rg+cb.b)*0.5)*2.0-1.0);
	  vec2 oc = mix(oa,ob,0.5)*morph_strength;
  
	  float w0 = progress;
	  float w1 = 1.0-w0;
	  gl_FragColor = mix(texture2D(from, p+oc*w0), texture2D(to, p-oc*w1), progress);
  }

// cross zoom
  else if ( transition == 7)
  {
	  vec2 center = vec2(Linear_ease(0.25, 0.5, 1.0, progress), 0.5);
	  float dissolve = Exponential_easeInOut(0.0, 1.0, 1.0, progress);
	  float strength = Sinusoidal_easeInOut(0.0, cz_strength, 0.5, progress);
	  vec3 color = vec3(0.0);
	  float total = 0.0;
	  vec2 toCenter = center - p;
	  float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);

	  for (float t = 0.0; t <= 40.0; t++) {
		  float percent = (t + offset) / 40.0;
		  float weight = 4.0 * (percent - percent * percent);
		  color += crossFade(p + toCenter * percent * strength, dissolve) * weight;
		  total += weight;
		  gl_FragColor = vec4(color / total, 1.0);
	  }
  }

// Slide
  else if ( transition == 8)
  {
	  float translateX = 0.0; 
	  float translateY = -1.0;
	  
	  if ( slide_direction == 0 ) // Slide Down
	  {
		  translateX = 0.0;
		  translateY = -1.0;
	  }
	  if ( slide_direction == 1 ) // Slide Left
	  {
		  translateX = -1.0;
		  translateY = 0.0;
	  }
	  if ( slide_direction == 2 ) // Slide Right
	  {
		  translateX = 1.0;
		  translateY = 0.0;
	  }
	  if ( slide_direction == 3 ) // Slide Up
	  {
		  translateX = 0.0;
		  translateY = 1.0;
	  }
	 	 
	  float x = progress * translateX;
	  float y = progress * translateY;

	  if (x >= 0.0 && y >= 0.0) {
		  if (p.x >= x && p.y >= y) {
			  gl_FragColor = texture2D(from, p - vec2(x, y));
		  }
		  else {
			  vec2 uv;
			  if (x > 0.0)
				  uv = vec2(x - 1.0, y);
			  else if (y > 0.0)
				  uv = vec2(x, y - 1.0);
			  gl_FragColor = texture2D(to, p - uv);
        }
    }
	else if (x <= 0.0 && y <= 0.0) {
		if (p.x <= (1.0 + x) && p.y <= (1.0 + y))
			gl_FragColor = texture2D(from, p - vec2(x, y));
		else {
			vec2 uv;
			if (x < 0.0)
				uv = vec2(x + 1.0, y);
			else if (y < 0.0)
				uv = vec2(x, y + 1.0);
			gl_FragColor = texture2D(to, p - uv);
		}
    }
	else
		gl_FragColor = vec4(0.0);
}

// Radial
	else if ( transition == 9)
	{
		vec2 rp = p*2.-2.;
		float a = atan(rp.y, rp.x);
		 
 		if ( radial_center == 0 )  // center
		{
			rp = p*-2.+1.;
			a = atan(rp.x, rp.y);
		}
		else if ( radial_center == 1 )  // bottom left corner
		{
			rp = p;
			a = atan(rp.x, rp.y);
		}
		else if ( radial_center == 2 )  // bottom left corner invert 
		{
			rp = p;
			a = atan(rp.y, rp.x);
		}
		else if ( radial_center == 3 )  // top right corner
		{
			rp = p*1.-1.;
			a = atan(rp.x, rp.y);
		}
		else if ( radial_center == 4 )  // top right corner invert
		{
			rp = p*1.-1.;
			a = atan(rp.y, rp.x);
		}
		else if ( radial_center == 5 )  // Soft L / R
		{
			rp = p*1.+1.;
			a = atan(rp.x, rp.y);
		}
		else if ( radial_center == 6 )  // Soft R / L
		{
			rp = p*1.+1.;
			a = atan(rp.y, rp.x);
		}

		float pa = progress*PI*2.5-PI*1.25;
		vec4 fromc = texture2D(from, p);
		vec4 toc = texture2D(to, p);
		if(a>pa) {
			gl_FragColor = mix(toc, fromc, smoothstep(0.0, 0.009 + radial_smoothness, (a-pa)));
		} else {
			gl_FragColor = toc;
		}
	}
// Simple Flip
    else if ( transition == 10)
    {
		vec2 q = p;
	
		if ( flip_direction == 0 )
		{
			p.y = (p.y - 0.5)/abs(progress - 0.5)*0.5 + 0.5;
			vec4 a = texture2D(from, p);
			vec4 b = texture2D(to, p);
			gl_FragColor = vec4(mix(a, b, step(0.5, progress)).rgb * step(abs(q.y - 0.5), abs(progress - 0.5)), 1.0);
		}
		else if ( flip_direction == 1 )
		{
		     p.x = (p.x - 0.5)/abs(progress - 0.5)*0.5 + 0.5;
		     vec4 a = texture2D(from, p);
		     vec4 b = texture2D(to, p);
		     gl_FragColor = vec4(mix(a, b, step(0.5, progress)).rgb * step(abs(q.x - 0.5), abs(progress - 0.5)), 1.0);
		}
	}


// squares
  else if ( transition == 11)
  {
	  vec2 sq_size = vec2(squares_size);
	  vec2 a_size = vec2(sq_size.x * adsk_result_frameratio / squares_aspect, sq_size.x );
	  float r = rand(floor(vec2(a_size) * p));
	  float m = smoothstep(0.0, -squares_smoothness, r - (progress * (1.0 + squares_smoothness)));
	  gl_FragColor = mix(texture2D(from, p), texture2D(to, p), m);
  }
		
// wipe
    else if ( transition == 15)
	{
		vec2 wipe_direction = vec2(cos(angle), sin(angle));
		vec2 v = normalize(wipe_direction);
	    v /= abs(v.x)+abs(v.y);
	    float d = v.x * center.x + v.y * center.y;
	    float m = smoothstep(- wipe_smoothness, 0.0, v.x * p.x + v.y * p.y - (d-0.5+progress*(1.0+ wipe_smoothness)));
	    gl_FragColor = mix(texture2D(to, p), texture2D(from, p), m);
	}
	
// dreamy
    else if ( transition == 16)
	{
		if ( wave_direction == 0 )
		{
			float y = sin((p.y + time * speed *.1) * amount ) * detail *0.0118 * sin( progress / 0.32 );
			gl_FragColor = mix(texture2D(from, (p + vec2(y, 0.0))), texture2D(to, (p + vec2(y, 0.0))), progress);
		}
		else if ( wave_direction == 1 )
		{
			float x = sin((p.x + time * speed *.1) * amount ) * detail *0.0118 * sin( progress / 0.32 );
			gl_FragColor = mix(texture2D(from, (p + vec2(0.0, x))), texture2D(to, (p + vec2(0.0, x))), progress);
		}

	}
}