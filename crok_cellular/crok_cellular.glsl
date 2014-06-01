uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Speed;
uniform float Offset;
uniform float Gain;
uniform float Brightness;
uniform int Iterations;
uniform float Scale;
uniform float Zoom;
uniform float Noise;
uniform float Blend;
uniform float Depth;
uniform vec3 tint;



uniform vec2 mouse;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time *.03 * Speed + 100.0 + Offset;
// http://glsl.heroku.com/e#17197.1


vec2    toworld(vec2 uv);
mat2	rmat(float r);
float   hash(float v);
vec2    rhash(vec2 uv);
float   noise(in vec2 uv);
float   voronoi(const in vec2 uv);
float   fvrmf(float a, float f, vec2 uv, const in int it);
vec3	hsv(in float h, in float s, in float v);

void main( void )
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    uv = toworld(uv);
    
    vec2 m = toworld(mouse);
    
    uv = normalize(vec3(uv-m, 2.)).xy;
    
    float a = Gain;
    float f = 5. * Brightness;
  	
    float r = fvrmf(a, f, uv, Iterations);
	
    gl_FragColor = vec4((2.*r)*tint, 1.0);
}

//sphinx

vec2 toworld(vec2 uv){
	uv = uv * 2. - 1.;
	uv.x *= resolution.x/resolution.y;
	return uv;
}

vec3 hsv(in float h, in float s, in float v)
{
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}

mat2 rmat(float r)
{
    float c = cos(r);
    float s = sin(r);
    return mat2(c, s, -s, c);
}

float hash(float v)
{
    return fract(fract(v/1e4)*v-1e6);
}

vec2 rhash(vec2 uv) {
    const mat2 t = mat2(.12121212,.13131313,-.13131313,.12121212);
    const vec2 s = vec2(1e4, 1e6);
    uv *= t;
    uv *= s;
	return  fract(fract(uv/s)*uv);
}

vec2 smooth(vec2 uv)
{
    return uv*uv*(3.-2.*uv);
}

//value noise
float noise(in vec2 uv)
{
    const float k = 257.;
    vec4 l  = vec4(floor(uv),fract(uv));
    float u = l.x + l.y * k;
    vec4 v  = vec4(u, u+1.,u+k, u+k+1.);
    v       = fract(fract(1.23456789*v)*v/.987654321);
    l.zw    = smooth(l.zw);
    l.x     = mix(v.x, v.y, l.z);
    l.y     = mix(v.z, v.w, l.z);
    return    mix(l.x, l.y, l.w);
}

//iq's voronoi
float voronoi(const in vec2 uv)
{
    vec2 p = floor(uv);
    vec2 f = fract(uv);
    float v = 0.;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            vec2 b = vec2(i, j);
            vec2 r = b - f + rhash(p + b);
            v += 1. /pow(dot(r,r),8. *Scale);
        }
    return pow(1./v, 0.0625);
}

//multifractalridgedvoroninoisemultifractalomg
float fvrmf(float a, float f, vec2 uv, const in int it)
{
    float l = 2. * Zoom;
    float r = 0.;
    float t = time * .25;
    for(int i = 0; i < 32; i++)
    {
        if(i<it)
        {
            uv = uv.yx * l;
            float n = voronoi(rmat(t*.25 * Depth)*uv+uv+t*.25 * Depth); 
            n = abs(fract(n-.5 * Noise)-.5 * Noise);
            n *= n * a;
            a = clamp(0.,1., n*2.);
            r += n*pow(f, -1.);
            f *= l;
            f /= max(r, min(1., noise(uv-t-uv*rmat(t*2.)-n)/.5 * Blend));
        }
    }
    return r*8.;
}
