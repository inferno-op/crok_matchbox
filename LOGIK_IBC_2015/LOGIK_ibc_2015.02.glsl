#version 120

// Plasma demo effect based on https://www.shadertoy.com/view/XsfSW2  by twitchingace
// Amiga BoingBall effect based on https://www.shadertoy.com/view/4ssGWn by UnitZeroOne
// starDust effect based on https://www.shadertoy.com/view/4sSSWz by and
// Groovymap effect based on http://glslsandbox.com/e#26453.3 by Jonathan Proxy
// C64 Logo effect based on http://glslsandbox.com/e#26313.0 by Sander and gigatron
// CheckerTube effect based on http://glslsandbox.com/e#25880.0
// FlowerPlasma effect based on https://www.shadertoy.com/view/Xdf3zH by epsilum 
//	
//
//                       _                                       _ _ _ _ _ _ _ 
//       /\             (_)                                     | | | | | | | |
//      /  \   _ __ ___  _  __ _  __ _  __ _  __ _  __ _  __ _  | | | | | | | |
//     / /\ \ | '_ ` _ \| |/ _` |/ _` |/ _` |/ _` |/ _` |/ _` | | | | | | | | |
//    / ____ \| | | | | | | (_| | (_| | (_| | (_| | (_| | (_| | |_|_|_|_|_|_|_|
//   /_/    \_\_| |_| |_|_|\__, |\__,_|\__,_|\__,_|\__,_|\__,_| (_|_|_|_|_|_|_)
//                          __/ |                                              
//                         |___/

//By @unitzeroone
//Check out http://www.youtube.com/watch?feature=player_detailpage&v=ZmIf-5MuQ7c#t=26s for context.
//Decyphering the code&magic numbers and optimizing is left as excercise to the reader ;-)

uniform sampler2D adsk_results_pass1, adsk_results_pass2; 
uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);

float time = adsk_time *.05;

const float offset = 0.0;

#define PI 3.1415926535897932384626433832795
#define TWOPI 6.28318530718
#define startup_sequence 1.0

// begin Groovymap const
const float _periodX = 6.;
const float _periodY = 7.;
// end Groovymap const

// begin Amiga Boing ball const
const vec2 am_res = vec2(320.0,200.0);
const mat3 am_mRot = mat3(0.9553, -0.2955, 0.0, 0.2955, 0.9553, 0.0, 0.0, 0.0, 1.0);
const vec3 am_ro = vec3(0.0,0.0,-4.0);
const vec3 am_cRed = vec3(1.0,0.0,0.0);
const vec3 am_cWhite = vec3(1.0);
const vec3 am_cGrey = vec3(0.66);
const vec3 am_cPurple = vec3(0.51,0.29,0.51);
const float am_maxx = 0.378;
// end Amiga Boing Ball const

// begin C64 Logo const
const float wave = 3.0;
const vec3 black = vec3(0);
const vec3 white = vec3(1);
const vec3 blue = vec3(0,0,192./255.);
const vec3 red = vec3(1,40./255.,0);
// end C64 Logo const

float plasma ( vec2 uv )
{
	float v = 0.0;
	vec2 u_k = vec2(0.002,0.03);
    vec2 c = gl_FragCoord.xy * u_k * 0.2;
	c /= vec2(sin(time*3.17),cos(time*2.3));
	
    v += sin(c.x * 5.4 + time);
	v += sin(c.y * sin((c.x + time)/0.5) + c.x * cos(time - c.y) + time);
	v += 0.0;
	c.x += sin(time / 10.21235);
	c.y += cos(time / 22.12361);
	v += sin(sqrt(4.0 * (c.x * c.x +c.y * c.y) + 1.0) + time);
	return v;
}
float plasma_zoom ( vec2 uv )
{
	float v = 0.0;
	vec2 u_k = vec2(0.003,0.02);
    vec2 c = ((2.0 *gl_FragCoord.xy) -0.5) * u_k * sin(time) * .50 + 2.;
	c *= vec2(sin(time*.7),+sin(time*1.3));
    v += sin(c.x * 5.4 + time);
	v += sin(c.y * sin((c.x + time)/0.9) + c.x * cos(time - c.y) + time);
	v += 0.0;
	c.x += sin(time / 15.21235);
	c.y += cos(time / 12.12361);
	v += sin(sqrt(3.0 * (c.x * c.x +c.y * c.y) + 1.0) + time);
	return v;
}
vec3 plasma_stretch ( vec2 uv)
{
    float v1 = sin(uv.x*5.0 + time);
    float v2 = sin(5.0*(uv.x*sin(time / 2.0) + uv.y*cos(time/3.0)) + time);
    
    // v3
    float cx = uv.x + sin(time / 5.0)*5.0;
    float cy = uv.y + sin(time / 3.0)*5.0;
    float v3 = sin(sqrt(100.0*(cx*cx + cy*cy)) + time);
    
    float vf = v1 + v2 + v3;
    float r  = cos(vf*PI);
    float g  = sin(vf*PI + 6.0*PI/3.0);
    float b  = cos(vf*PI + 4.0*PI/3.0);
	return vec3(r,g,b);
}
float state_of_the_art( vec2 uv )
{
	// Fragment coords relative to the center of viewport, in a 1 by 1 coords sytem.
	uv = -1.0 + 2.0* gl_FragCoord.xy / res.xy;
	
	// But I want circles, not ovales, so I adjust y with x resolution.
	vec2 homoCoords = vec2( uv.x, 2.0* gl_FragCoord.y/res.x );
	
	// Sin of distance from a moving origin to current fragment will give us..... 
	vec2 movingOrigin1 = vec2(sin(time*.7),+sin(time*1.7));
	
	// ...numerous... 
	float frequencyBoost = sin(time) * 50.; 
	
	// ... awesome concentric circles.
	float wavePoint1 = sin(distance(movingOrigin1, homoCoords)*frequencyBoost);
	
	// I want sharp circles, not blurry ones.
	float blackOrWhite1 = sign(wavePoint1);
	
	// That was cool ! Let's do it again ! (No, I dont want to write a function today, I'm tired).
	vec2 movingOrigin2 = vec2(-cos(time*2.0),-sin(time*3.0));
	float wavePoint2 = sin(distance(movingOrigin2, homoCoords)*frequencyBoost);
	float blackOrWhite2 = sign(wavePoint2);
	
	// XOR virtual machine.
	float composite = blackOrWhite1 * blackOrWhite2;

	return composite;
}

// start SGI Logo
vec3 rY(float a,vec3 v)
{
	return vec3(cos(a)*v.x+sin(a)*v.z,v.y,cos(a)*v.z-sin(a)*v.x);
}
float cyl(vec3 p,vec3 dir,float l)
{
	float d=dot(p,dir);
	return max(-d,max(d-l,distance(p,dir*d)-0.13));
}
float sph(vec3 p)
{
	return length(p)-0.13;
}
float side(vec3 p)
{
	float l0=1.0,l1=0.7;
	vec2 l=vec2(-l0,0.0);
	return min(min(min(min(min(cyl(p,vec3(-1.0,0.0,0.0),l0),cyl(p-l.xyy,vec3(0.0,-1.0,0.0),l0)),
	     cyl(p-l.xxy,vec3(1.0,0.0,0.0),l1)),sph(p)),sph(p-l.xyy)),sph(p-l.xxy));
}
float s(vec3 p)
{
	float d=1e3;
	for(int i=0;i<6;++i)
	{
		d=min(d,side(p));
		p = (p-vec3(-0.3,-1.0,0.0)).zxy;
		p.z=-p.z;
	}
	return d;
}
vec3 cam(vec3 v)
{
	float t=mod(time,10.0),w=smoothstep(1.0,2.5,t)-smoothstep(10.0,10.,t);
	return rY(-PI*0.25+sin(time*2.0)*0.5*w,rY(PI*0.19+cos(time*2.0)*0.1*w,v.yxz).yxz);
}
vec3 sceneNorm(vec3 rp)
{
	vec3 e=vec3(1e-3,0.0,0.0);
	float d0=s(rp);
	return normalize(vec3(s(rp+e)-d0,s(rp+e.yxy)-d0,s(rp+e.yyx)-d0));
}
// end SGI Logo

// start starDust
float saturate(float x)
{
    return clamp(x, 0.0, 1.0);
}
float isectPlane(vec3 n, float d, vec3 org, vec3 dir)
{
    float t = -(dot(org, n) + d) / dot(dir, n);

    return t;
}
vec3 drawEffect(vec2 coord, float time)
{
    vec3 clr = vec3(0.0);
    const float far_dist = 10000.0;

    float mtime = time * 2.0;
    vec2 uv = coord.xy / res.xy;

    vec3 org = vec3(0.0);
    vec3 dir = vec3(uv.xy * 2.0 - 1.0, 1.0);

    // Animate tilt
    float ang = sin(time * 0.2) * 0.2;
    vec3 odir = dir;
    dir.x = cos(ang) * odir.x + sin(ang) * odir.y;
    dir.y = sin(ang) * odir.x - cos(ang) * odir.y;

    // Animate FOV and aspect ratio
    dir.x *= 1.5 + 0.5 * sin(time * 0.125);
    dir.y *= 1.5 + 0.5 * cos(time * 0.25 + 0.5);

    // Animate view direction
    dir.x += 0.25 * sin(time * 0.3);
    dir.y += 0.25 * sin(time * 0.7);

    // Bend it like this
    dir.xy = mix(vec2(dir.x + 0.2 * cos(dir.y) - 0.1, dir.y), dir.xy,
        smoothstep(0.0, 1.0, saturate(0.5 * abs(mtime - 50.0))));

    // Bend it like that
    dir.xy = mix(vec2(dir.x + 0.1 * sin(4.0 * (dir.x + time)), dir.y), dir.xy,
        smoothstep(0.0, 1.0, saturate(0.5 * abs(mtime - 58.0))));

    // Cycle between long blurry and short sharp particles
    vec2 param = mix(vec2(60.0, 0.8), vec2(800.0, 3.0),
        pow(0.5 + 0.5 * sin(time * 0.2), 2.0));

    float lt = fract(mtime / 4.0) * 4.0;
    vec2 mutes = vec2(0.0);

    for (int k = 0; k < 2; k++)
    for (int i = 0; i < 32; i++)
    {

        vec3 pn = vec3(k > 0 ? -1.0 : 1.0, 0.0, 0.0);
        float t = isectPlane(pn, 100.0 + float(i) * 20.0, org, dir);

        if (t <= 0.0 || t >= far_dist) continue;

        vec3 p = org + dir * t;
        vec3 vdir = normalize(-p);

        // Create particle lanes by quantizing position
        vec3 pp = ceil(p / 100.0) * 100.0;

        // Pseudo-random variables
        float n = pp.y + float(i) + float(k) * 123.0;
        float q = fract(sin(n * 123.456) * 234.345);
        float q2= fract(sin(n * 234.123) * 345.234);

        q = sin(p.z * 0.0003 + 1.0 * time * (0.25 + 0.75 * q2) + q * 12.0);

        // Smooth particle edges out
        q = saturate(q * param.x - param.x + 1.0) * param.y;
        q *= saturate(4.0 - 8.0 * abs(-50.0 + pp.y - p.y) / 100.0);

        // Fade out based on distance
        q *= 1.0 - saturate(pow(t / far_dist, 5.0));

        // Fade out based on view angle
        float fn = 1.0 - pow(1.0 - dot(vdir, pn), 2.0);
        q *= 2.0 * smoothstep(0.0, 1.0, fn);

        // Flash fade left or right plane
        q *= 1.0 - 0.9 * (k == 0 ? mutes.x : mutes.y);

        // Cycle palettes
        const vec3 orange = vec3(1.0, 0.7, 0.4);
        const vec3 blue   = vec3(0.4, 0.7, 1.0);
        clr += q * mix(orange, blue, 0.5 + 0.5 * sin(time * 0.5 + q2));

        // Flash some particles in sync with bass drum
        float population = mtime < 16.0 ? 0.0 : 0.97;

        if (mtime >= 8.0 && q2 > population)
        {
            float a = mtime >= 62.0 ? 8.0 : 1.0;
            float b = mtime <  16.0 ? 2.0 : a;

            clr += q * (mtime < 16.0 ? 2.0 : 8.0)
                * max(0.0, fract(-mtime * b) * 2.0 - 1.0);
        }
    }

    clr *= 0.2;

    // Cycle gammas
    clr.r = pow(clr.r, 0.75 + 0.35 * sin(time * 0.5));
    clr.b = pow(clr.b, 0.75 - 0.35 * sin(time * 0.5));


    // Vignette in linear space (looks better)
    clr *= clr;
    clr *= 1.4;
    clr *= 1.0 - 1.5 * dot(uv - 0.5, uv - 0.5);
    clr = sqrt(max(vec3(0.0), clr));

    return clr;
}
// end starDust

// start Groovymap
vec2 cmul(const vec2 a, const vec2 b) {
  return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
vec2 csq(const vec2 v) {
  return vec2(v.x*v.x - v.y*v.y, 2.*v.x*v.y);
}
vec2 cinv(const vec2 v) {
  return vec2(v[0],-v[1]) / dot(v, v);
}
vec2 cln(const vec2 z) {
  return vec2(log(length(z)), atan(z.y, z.x)); // +2k pi
}
vec2 perturbedNewton(in vec2 z) {
  float a=1.2;
  mat2 rot=mat2(cos(a),-sin(a),sin(a),cos(a));  
  for(int i=0; i<1; ++i) {
    z = rot * (2.*z + cinv(csq(z))) / 6.;
  }
  return z;
}
vec2 pentaplexify(const vec2 z) {
  vec2 y = z;
  for(float i=0.; i<TWOPI-0.1; i+=TWOPI/5.) {
    y = cmul(y, z-vec2(cos(i+.1*time), sin(i+.1*time)));
  }
  return y;
}
vec2 infundibularize(in vec2 z) {
  vec2 lnz = cln(z) / TWOPI;
  return vec2(_periodX*(lnz.y) + _periodY*(lnz.x), _periodX*(lnz.x) - _periodY*(lnz.y));
}
vec3 hsv(float h, float s, float v) {
  return v * mix(
    vec3(1.0),
    clamp((abs(fract(h+vec3(3.0, 2.0, 1.0)/3.0)*6.0-3.0)-1.0), 0.0, 1.0), 
    s);
}
vec4 rainbowJam(in vec2 z) {
  vec2 uv = fract(vec2(z[0]/_periodX, z[1]/_periodY))*vec2(_periodX, _periodY);
  vec2 iz = floor(uv);
  vec2 wz = uv - iz;
  float rad = 0.26 + sin(time-z.y*0.2-z.x*0.25) * 0.25;
  return vec4(hsv(pow(iz[0]/_periodX, 1.5),0.9,smoothstep(rad+0.02,rad,length(wz-vec2(0.5)))), 1.);
}
// end Groovymap

// start C64 LOGO
bool cosign(vec2 t) {
	return (t.x > 0. && t.x < 49. && t.y > 0. && t.y < 23.) &&
		! (t.x > 26. && (t.x - 26.) > t.y);
}
vec3 commodore(vec2 p) {
	
	if(length(p) < 62.0 && length(p) > 34.0 && p.x < 17.0) {
		return blue;
	}
	
	vec2 t = p - vec2(20., 2.);
	if(cosign(t)) {
		return blue;
	}

	p.y *= -1.;
	
	vec2 t2 = p - vec2(20., 2.);
	if(cosign(t2)) {
		return red;
	}
	return black;
}
// end C64 Logo

// CheckerTube
vec3 checkerboard(vec2 p, float freq, vec3 first, vec3 second)
{
	return 	mix(first, second, max(0.0, sign(sin(p.x * 6.283*freq)) * sign(sin(p.y * 6.283 * freq))));
}
// end CheckerTube

// start FlowerPlasma
float addFlower(float x, float y, float ax, float ay, float fx, float fy)
{
	float xx=(x+sin(time*fx)*ax)*8.0;
   	float yy=(y+cos(time*fy)*ay)*8.0;
	float angle = atan(yy,xx);
	float zz = 1.5*(cos(18.0*angle)*0.5+0.5) / (0.7 * 3.141592) + 1.2*(sin(15.0*angle)*0.5+0.5)/ (0.7 * 3.141592);
	
	return zz;
}



void main()
{
 	vec2 uv = gl_FragCoord.xy/res.xy;
	vec4 star_col = texture2D(adsk_results_pass1, uv);
	vec4 logik_col = texture2D(adsk_results_pass2, uv);
	vec4 logik_small_col = texture2D(adsk_results_pass2, (uv - vec2(0.025, 0.8)) * 3.);
	vec4 col = vec4(0.0);
    float startup_time = max(0.0, time - startup_sequence);
	startup_time = clamp(startup_time, 0.0, 1.0);

	// start plasma
	float v = plasma( uv );
	vec3 plasma_col = vec3(sin(v) + 0.5, sin(PI * v), cos(PI * v));
	plasma_col *= 0.5 + 0.5;
	// end plasma
	
	// start zoom plasma
	float zv = plasma_zoom( uv );
	vec3 zoom_plasma_col = vec3(sin(zv*time), cos(zv+time), zv);
	zoom_plasma_col *= 0.5 + 0.5;
	// end zoom plasma
	
	// start stretch plasma
	vec3 stretch_plasma_col = plasma_stretch ( uv );
	// end stretch plasma
	
	// start state_of_the_art
	float s = state_of_the_art(uv);
	vec3 state_col = vec3(sin(s+time), s, s);
	// end state_of_the_art
	
	// start SGI Logo
	vec3 sgi_uv = gl_FragCoord.xyy/res.xyy,ro=vec3(0.0,0.3, sin(time + 26.95 + 10.8)*2.5 + 9.5),rd=normalize(vec3((sgi_uv.x-0.5)*2.0*res.x/res.y,sgi_uv.y*2.0-1.0,-5.0)),rp=vec3(0.0);
	ro=cam(ro)-vec3(1.3/2.0);
	rd=cam(rd);
	float t=0.0,d;
	for(int i=0;i<60;++i)
	{
		rp=ro+rd*t;
		d = s(rp);
		if(d < 1e-2)
			break;
		t += d;
	}
	vec4 sgi_col = vec4(1.0-t*.1)*1.7 + 0.1;
	//end SGI Logo
	
	// start Amiga BoingBall
	float asp = res.y/res.x;
	vec2 am_uv = (gl_FragCoord.xy / res.xy);
	vec2 uvR = floor(uv*am_res);
	vec2 g = step(2.0,mod(uvR,16.0));
	vec3 bgcol = mix(am_cPurple,mix(am_cPurple,am_cGrey,g.x),g.y);
	am_uv = uvR/am_res;
	float xt = mod(time+1.0,6.0);
	float am_dir = (step(xt,3.0)-.5)*-2.0;
	am_uv.x -= (am_maxx*2.0*am_dir)*mod(xt,3.0)/3.0+(-am_maxx*am_dir);
	am_uv.y -= abs(sin(4.5+time*1.3))*0.5-0.3;
	bgcol = mix(bgcol,bgcol-vec3(0.2),1.0-step(0.12,length(vec2(am_uv.x,am_uv.y*asp)-vec2(0.57,0.29))));
	vec3 am_rd = normalize(vec3((am_uv*2.0-1.0)*vec2(1.0,asp),1.5));
	float b = dot(am_rd, am_ro);
	float t1 = b*b-15.6;
	float t2 = -b-sqrt(t1);
	vec3 nor = normalize(am_ro+am_rd*t2)*am_mRot;
	vec2 tuv = floor(vec2(atan(nor.x,nor.z)/PI+((floor((time*-am_dir)*60.0)/60.0)*0.5),acos(nor.y)/PI)*8.0);
	vec3 am_col = vec3(mix(bgcol,mix(am_cRed, am_cWhite,clamp(mod(tuv.x+tuv.y,2.0),0.0,1.0)),1.0-step(t1,0.0)));
	// end Amiga BoingBall
	
	// start starDust
    vec3 starDust_col = drawEffect(gl_FragCoord.xy, time);
	// end starDust
	
	// start Groovymap
    vec4 groovy_col = rainbowJam(infundibularize(pentaplexify(perturbedNewton(3.*(2.*gl_FragCoord.xy-res.xy) / res.y))) + 0.4 - time * 3. + time * -0.2);
	// end Groovymap
	
	// start C64 Logo
	vec2 c64_p = (gl_FragCoord.xy/res.xy)-vec2(0.5);
	c64_p.x *= res.x/res.y;
	vec2 zp = c64_p * 150.;
	vec2 displace = vec2( sin(time*2. - (c64_p.y*wave)), -cos(time*2. - (c64_p.x*wave)) );
	zp += 5. * displace;
	vec3 c64_logo_col = commodore(zp);
	// end C64 Logo
	
	// start CheckerTube
	vec2 position = ( gl_FragCoord.xy / res.xy * 2.0 - 1.0 );
	position.x *= res.x / res.y;
	position.y += sin(time)*0.35;
	position.x += cos(time)*0.1;
	vec2 p;
	float r, a;
	r = sqrt(length(pow(position, vec2(1.0))));
	a = atan(position.y, position.x) /3.1415;
	p.x = 0.5 / r + time*0.5;
	p.y = a+time*0.2;
	vec3 checker_tube_col = checkerboard(p, 4.0, vec3(1.0, 1.0, 1.), vec3(0.8, 0., 0.)) * min(1.0, (pow(r, 2.5)));
	// end CheckerTube
	
	// start FlowerPlasma
   	float x=uv.x;
   	float y=uv.y;
	float p1 = addFlower(x, y, 0.8, 0.9, 0.95, 0.85);
	float p2 = addFlower(x, y, 0.7, 0.9, 0.42, 0.71);
	float p3 = addFlower(x, y, 0.5, 1.0, 0.23, 0.97);
	float p4 = addFlower(x, y, 0.8, 0.5, 0.81, 1.91);
	float f_p=clamp((p1+p2+p3+p4)*0.25, 0.0, 1.0);

	vec4 flower_col;
	if (f_p < 0.5)
		flower_col=vec4(mix(0.0,1.0,f_p*2.0), mix(0.0,0.63,f_p*2.0), 0.0, 1.0);
	else if (f_p >= 0.5 && f_p <= 0.75)
		flower_col=vec4(mix(1.0, 1.0-0.32, (f_p-0.5)*4.0), mix(0.63, 0.0, (f_p-0.5)*4.0), mix(0.0,0.24,(f_p-0.5)*4.0), 1.0);
	else
		flower_col=vec4(mix(0.68, 0.0, (f_p-0.75)*4.0), 0.0, mix(0.24, 0.0, (f_p-0.75)*4.0), 1.0);
	// end FlowerPlasma
	
	// create a demo mode which switch every x seconds to a new mode
	/*
	int mode = int(mod(.1*time,11.));
	if      (mode==0) col = plasma_col;
	else if (mode==1) col = state_col;
	else if (mode==2) col = zoom_plasma_col;
	else if (mode==3) col = am_col.rgb;
	else if (mode==4) col = stretch_plasma_col;
	else if (mode==5) col = sgi_col.rgb;
	else if (mode==6) col = starDust_col;
	else if (mode==7) col = groovy_col.rgb;
	else if (mode==8) col = c64_logo_col;
	else if (mode==9) col = checker_tube_col;
	else if (mode==10) col = 1.0 - flower_col.rgb;
	*/

	// opening
	col = mix(vec4(0.0), col, startup_time);
	float cut_time = time * 20;


	// fade in stars
	if (cut_time <= 200. ) col = mix(vec4(0.0), star_col, smoothstep(0.0, 100., cut_time));
    // fade-out stars
    if (cut_time >= 200.0 ) col = mix(star_col, vec4(0.0), smoothstep(200, 250., cut_time));

	if (cut_time >= 250.+ offset) col.rgb = mix(vec3(0.0), groovy_col.rgb, smoothstep(250.+ offset, 275.0, cut_time));
	
	if (cut_time >= 250. + offset)
	{
		// comp LOGIK logo ontop
		col.rgb = mix(vec3(0.0), vec3(logik_col.a * logik_col.rgb + (1.0 - logik_col.a) * col.rgb)	, smoothstep(250.+ offset, 275.0, cut_time));
	    //col.rgb = vec3(logik_col.a * logik_col.rgb + (1.0 - logik_col.a) * col.rgb);
	}
	
	
	// LOGIK Logo 
    // fade-in
    //if (cut_time >= 250.+ offset) col += mix(vec4(0.0), logik_col, smoothstep(250.+ offset, 275.0, cut_time));
    // fade-out
    // if (cut_time >= 340.0.+ offset) col = mix(logik_col, vec4(0.0), smoothstep(340.0+ offset, 365., cut_time));

	//if (cut_time >= 366. + offset) col.rgb = flower_col.rgb;
		
		
	if (cut_time >= 490. + offset) col.rgb = state_col;
	if (cut_time >= 550. + offset) col.rgb = plasma_col;
	if (cut_time >= 609. + offset) col.rgb = state_col;
	if (cut_time >= 696. + offset) col.rgb = checker_tube_col;
	if (cut_time >= 722. + offset) col.rgb = groovy_col.rgb;
		
	
	if (cut_time >= 736. ) col.rgb = mix(vec3(0.0), c64_logo_col, smoothstep(736., 748., cut_time));
    if (cut_time >= 764. ) col.rgb = mix(c64_logo_col, vec3(0.0), smoothstep(774., 786., cut_time));
	
	if (cut_time >= 787. + offset) col.rgb = sgi_col.rgb;
	
	
	if (cut_time >= 900. ) col.rgb = mix(vec3(0.0), am_col.rgb, smoothstep(900., 912., cut_time));
    if (cut_time >= 968. ) col.rgb = mix(am_col.rgb, vec3(0.0), smoothstep(968., 980., cut_time));

	
	
	if (cut_time >= 980. + offset) col.rgb = state_col;
	if (cut_time >= 1012. + offset) col.rgb = plasma_col;
	if (cut_time >= 1040. + offset) col.rgb = state_col;
	
	if (cut_time >= 1082. + offset) col.rgb = flower_col.rgb;
	if (cut_time >= 1135. + offset) col.rgb = starDust_col;
	if (cut_time >= 1166. + offset) col.rgb = checker_tube_col;
	if (cut_time >= 1204. + offset) col.rgb = state_col;
	if (cut_time >= 1230. + offset) col.rgb = zoom_plasma_col;
	if (cut_time >= 1258. + offset) col.rgb = state_col;
	if (cut_time >= 1300. + offset) col.rgb = plasma_col;
	if (cut_time >= 1343. + offset) col.rgb = zoom_plasma_col;
	if (cut_time >= 1382. + offset) col.rgb = state_col;
	if (cut_time >= 1411. + offset) col.rgb = zoom_plasma_col;	
	
	
	// end part
	if (cut_time >= 1429. + offset) col.rgb = groovy_col.rgb;
	if (cut_time >= 1439. + offset) col.rgb = state_col;
	if (cut_time >= 1450. + offset) col.rgb = plasma_col;
	if (cut_time >= 1454. + offset) col.rgb = state_col;
	if (cut_time >= 1458. + offset) col.rgb = am_col.rgb;
	if (cut_time >= 1462. + offset) col.rgb = state_col;
	if (cut_time >= 1466. + offset) col.rgb = sgi_col.rgb;
	if (cut_time >= 1470. + offset) col.rgb = stretch_plasma_col;
	if (cut_time >= 1474. + offset) col.rgb = zoom_plasma_col;
	if (cut_time >= 1478. + offset) col.rgb = groovy_col.rgb;
	if (cut_time >= 1495. + offset) col.rgb = state_col;
	if (cut_time >= 1499. + offset) col.rgb = checker_tube_col;
	if (cut_time >= 1503. + offset) col.rgb = stretch_plasma_col;
	if (cut_time >= 1512. + offset) col.rgb = plasma_col;
	if (cut_time >= 1516. + offset) col.rgb = state_col;

	if (cut_time >= 490. + offset)
	{
		// comp LOGIK logo ontop
	    col.rgb = vec3(logik_small_col.a * logik_small_col.rgb + (1.0 - logik_small_col.a) * col.rgb);	
	}
	
	
	col = clamp(col, 0.0, 1.0);
    gl_FragColor = vec4(col.rgb, 1.0);
}