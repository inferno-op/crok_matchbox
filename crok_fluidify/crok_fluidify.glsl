#version 120

// based on https://www.shadertoy.com/view/MdKXRy
// created by florian berger (flockaroo) - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// single pass CFD
// ---------------
// this is some "computational flockarooid dynamics" ;)
// the self-advection is done purely rotational on all scales.
// therefore i dont need any divergence-free velocity field.
// with stochastic sampling i get the proper "mean values" of rotations
// over time for higher order scales.
//

uniform sampler2D adsk_accum_texture, source;
uniform float adsk_result_w, adsk_result_h, adsk_time, detail;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time *.05;
#define iFrame adsk_time
#define angRnd 0.0

uniform int RotNum;
uniform float posRnd;

float ang = 2.0*3.1415926535/float(RotNum);
mat2 m = mat2(cos(ang),sin(ang),-sin(ang),cos(ang));

float hash(float seed) { return fract(sin(seed)*158.5453 ); }
vec4 getRand4(float seed) { return vec4(hash(seed),hash(seed+123.21),hash(seed+234.32),hash(seed+453.54)); }
vec4 randS(vec2 uv)
{
    return getRand4(uv.y+uv.x*1234.567)-vec4(0.5);
}

float getRot(vec2 uv, float sc)
{
    float ang2 = angRnd*randS(uv).x*ang;
    vec2 p = vec2(cos(ang2),sin(ang2));
    float rot=0.0;
    for(int i=0;i<RotNum;i++)
    {
        vec2 p2 = (p+posRnd * 0.1 *randS(uv+p*sc).xy)*sc;
        vec2 v = texture2D(adsk_accum_texture,fract(uv+p2)).xy-vec2(0.5);
        rot+=cross(vec3(v,0.0),vec3(p2,0.0)).z/dot(p2,p2);
        p = m*p;
    }
    rot/=float(RotNum);
    return rot;
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 scr=uv*2.0-vec2(1.0);

    vec3 front = texture2D(source, uv).rgb;

    float sc=1.0/max(iResolution.x,iResolution.y);
    vec2 v=vec2(0);
    for(int level=0;level<20;level++)
    {
        if ( sc > 0.7 ) break;
        float ang2 = angRnd*ang*randS(uv).y;
        vec2 p = vec2(cos(ang2),sin(ang2));
        for(int i=0;i<RotNum;i++)
        {
            vec2 p2=p*sc;
            float rot=getRot(uv+p2,sc);
            v+=p2.yx*rot*vec2(-1.0, 1.0);
            p = m*p;
        }
      	sc*=2.0;
    }

    v /= float(RotNum) * detail *.15;

    gl_FragColor = texture2D(adsk_accum_texture,fract(uv+v*3.0 /iResolution.x));

    // add a little "motor" in the center
    //gl_FragColor.xy += (0.01*scr.xy / (dot(scr,scr)/0.1+0.3));

    if(iFrame<=1 ) gl_FragColor = texture2D(source,uv);
}
