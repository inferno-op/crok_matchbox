//TDF2014_summary

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform int Demo;
uniform int Preset; 
uniform float speed;
uniform float offset;
uniform float pp1;
uniform float pp2;
uniform float pp3;

uniform float glitch_pp1, glitch_pp2, glitch_pp3; uniform int glitch_pp4;
uniform float caress_pp1, caress_pp2, caress_pp3; uniform int caress_pp4;
uniform float lins_pp1, lins_pp2, lins_pp3; uniform int lins_pp4;
uniform float geomshape_pp1, geomshape_pp2, geomshape_pp3; uniform int geomshape_pp4;
uniform float lemonade_pp1, lemonade_pp2, lemonade_pp3; uniform int lemonade_pp4;
uniform float tdf4_pp1, tdf4_pp2, tdf4_pp3; uniform int tdf4_pp4;
uniform float glowart_pp1, glowart_pp2, glowart_pp3; uniform int glowart_pp4;
uniform float flash_pp1, flash_pp2, flash_pp3; uniform int flash_pp4;
	
uniform vec2 center;

vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
float iGlobalTime = adsk_time*.01 * speed + offset;
float time=iGlobalTime;
float preset = 1.0;


// TDF2014 caress
float N(vec2 v){return fract(sin(dot(vec2(7., 23.),v)) * caress_pp3);
}
vec2 e=vec2(1.,0.),s,f2,F2;
float M(vec2 v)
{
	F2=floor(v);
	f2=fract(v);
	f2*=f2*(3.-2.*f2);
	return mix(mix(N(F2),N(F2+e.xy),f2.x),mix(N(F2+e.yx),N(F2+e.xx),f2.x),f2.y);
}
float B(vec2 v){return M(v)+.5*M(v*2.)+.2*M(v*8.);
}
float t=time,l=0.,r;


//TDF2014 glitch_07


//#define PRESET_GLITCH_01

#ifdef PRESET_GLITCH_01

#define PRESET1 1.456
#define PRESET2 2.94
#define PRESET3 10.3224
#else
#define PRESET1 0.4
#define PRESET2 0.4
#define PRESET3 0.5
#endif


float m1(vec3 p1)
{
	p1=abs(p1);
	return max(p1.x-6.5,max(p1.y-PRESET1*glitch_pp1,p1.z-PRESET1*glitch_pp1));
}
vec2 r1(vec2 p1)
{
	float a1=mod(atan(p1.x,p1.y),PRESET2*glitch_pp2)-PRESET3*glitch_pp3;
	return vec2(cos(a1),sin(a1))*length(p1);
}
float f1(vec3 p1)
{
	p1.xz*=mat2(sin(time),cos(time),-cos(time),sin(time));
	p1.xz=r1(p1.xz);
	p1.yz=r1(p1.yz);
	p1.xy=r1(p1.xy);
	return (m1(p1));
}

//TDF2014 7-lins
float R,d,a,b,c,D,L;
vec3 O,P,Y,I,A;
vec4 E(vec3 n)
{
	float L=1.-n.y;
	float b=(n.y+.2);
	return vec4(L,L,L+L*b,1.);
}

//TDF2014 flash!
float M7(vec3 p7)
{
	float r7=cos(sin(p7.x))+cos(p7.y)+cos(sin(p7.z));
	p7*=13.*flash_pp3;
	return r7-=cos(cos(p7.x)+cos(p7.y)+cos(p7.z))* -.36*flash_pp2;
}

void main(void)
{
    if( Demo == 0)
	{
	float t=time*.2;
	vec2 uv=gl_FragCoord.xy/iResolution.xy-vec2(center.x,center.y);
	vec3 p=vec3(cos(uv*999.0)/(t*t*t),-5.),d=vec3(uv,.5);
	for(int i=0;i<glitch_pp4;i++)
		{
			p+=d*f1(p);
		}
		gl_FragColor = vec4(min(pow(f1(p-d),.5),1.));
	}
    if( Demo == 1)
	{
	for(int i=0;i<caress_pp4;++i) // i = 99
		{
			vec3 q=vec3(gl_FragCoord.xy/iResolution.xy-.5,1.)*l;
			q.z-=2.*caress_pp1;
			q.x*=1.8;
			r=length(q)-1.;
			s=42.*caress_pp3*(q.xy+M(vec2(r-t*4.))-M(vec2(r-t*4.))*e.xy);
			l+=.4*(r+.2*caress_pp2*B(s));
		}
		gl_FragColor=1.-vec4(B(s),B(s+.1),B(s+.3),1.);
	}
	
    if( Demo == 2)
	{
		A=normalize(vec3(((gl_FragCoord.xy*2.-iResolution)/iResolution.y).xy,-1.));
		R=1.;
		d=sin(time*3.)+3.;
		O=vec3(cos(time*3.),0.,-d);
		a=length(A);
		a*=a;
		b=-2.*dot(A,O);
		c=length(O);
		c*=c;
		c-=R;
		D=b*b-4.*a*c;
		if(D>0.)
		{
			L = (-b-sqrt(D))/(2.*a);
			P = A * L;
			A=P-O;
			L = (R+P.y)/(-A.y);
			I=A*L+P;
		}
		else
		{
			L=-R/A.y;
			I=A*L;
		}
		if(L<0.)
		{
			gl_FragColor=E(A);
		}
		else
		{
			gl_FragColor=vec4(mod(ceil(I.x) + ceil(I.z), 2.0));
		}
	}
		if( Demo == 3)
		{
				vec2 R=iResolution,P=2./R.y*gl_FragCoord.xy-vec2(R.x/R.y,1);
				vec3 C=vec3(0);
				for(float i=2.;
				i<9.;++i)
				{
					float T=time*.2,t=mod(T*.4,1e3)*i,x=P.x-cos(t)*.7,y=P.y-sin(t)*.7,r=t*3.+x*tan(t*1.5)+y*tan(t*2.),s=sin(r),c=cos(r)*geomshape_pp2;
					vec2 d=(2.+cos(T*.2)*.35*geomshape_pp3-abs(vec2(sin(t*.5),cos(t*.5))))*vec2(x*c+y*s,x*s-y*c);
					t=dot(d,d)-.12*geomshape_pp1;
					vec3 u=mod(T*vec3(2,1.9,1.8),1e3)*(i*.1+2.),v=vec3(sin(u.x),cos(u.y),sin(u.z+.8));
					C+=v*v*.02/abs(t);
					if(t<.0)C+=.2*sin(u)+.1;
				}
				gl_FragColor.xyz=C;
			}
			if( Demo == 4)
		{
			float L,l,n,d,A=24.*lemonade_pp1;
			vec2 p4,u=(gl_FragCoord.xy*2.-iResolution)/iResolution.y;
			L=dot(u,u);
			vec3 c=vec3(.9,1.,u.y*.1+.9);
			u+=time*.7;
			p4=abs((fract(u*.8)*2.-1.)*mat2(cos(time),sin(time),-sin(time),cos(time)));
			p4=(p4.x<p4.y)?p4.xy:p4.yx;
			l=length(p4);
			d=smoothstep(.0,.1,(1./(1.+A*p4.x)+1./(1.+A*dot(p4,vec2(-.7,.7)))+1./(1.+A*max(.0,.8-l)))-1.);
			c=mix(vec3(1.,.9,.4),mix(vec3(1.,1.,smoothstep(.9,.8,l)),c,smoothstep(.9,.91,l)),d)*exp(-L*vec3(.05,.03,.2));
			gl_FragColor=vec4(c,1.);
		}
			if( Demo == 5)
		{
			float T5=mod(time*4.,60.)*.7,M=7.*exp(-T5*.25)*cos(T5*.3),N=2.*exp(-T5*.1)*sin(T5),w=T5*.3*N+3.;
			vec2 R5=iResolution,P5=(.5*R5-gl_FragCoord.xy)/min(R5.x,R5.y);
			vec3 c5,p5=vec3(-cos(w)*P5.x-sin(w)*P5.y,sin(w)*P5.x-cos(w)*P5.y,P5.x+P5.y);
			for(int i=0;i<tdf4_pp4;++i) // i = 64
			{
				p5+=vec3(sin(w*.1+p5.y*2.6),cos(w*.1+p5.x*3.5-p5.z*9.),-sin(p5.x*2.))*M;
				if(p5.x>-.3)c5+=p5*floor(mod((p5.y<-.2?.0:p5.y<-0.1?30325.:p5.y<0.?9541.:p5.y<0.1?9591.:p5.y<0.2?9793.:0.)*pow(2.,floor(-5.-p5.x*20.)),2.))*.15;
			}
			gl_FragColor=vec4(abs(c5),1.);
		}
		if( Demo == 6)
		{
			float s6 = 0.;
			vec2 p6=vec2(gl_FragCoord.x,gl_FragCoord.y)/max(iResolution.x,iResolution.y);
			for(int i=0;
			i<glowart_pp4; // i = 30
			i++)
			{
				float t=time*.05;
				float fi=float(i);
				float fr=fract(3.*t*(fi/30.));
				vec2 o6= vec2(fi/30.+.001+sin(t)*.4,fr+sin(fi)+.001);
				s6 +=.002*abs(sin(40.*time*.1+fi))*(1./(pow(p6.x-o6.x,.2*fr))+1./(pow(p6.y-o6.y,.2*fr)))*max(1./length(p6-o6)-1.,0.);
			}
			s6 +=  .03/abs(p6.x-abs(sin(floor(time*2.)*0.2)));
			vec3 c=s6*abs(sin(time))*vec3(1.9+sin(time),1.8+cos(time),.8);
			gl_FragColor=vec4(clamp(c,0.,1.),1.);
		}
		if( Demo == 7)
		{
			float k=adsk_time*.02,q=k,f=exp(1.-fract(k+sin(k))),t=0.,dt=5.*flash_pp1;
			vec3 p=vec3(0,-k*2.-f*f,0),d=normalize(vec3(-1.+2.*(gl_FragCoord.xy/iResolution),1.));
			d/=64.;
			d.xy=vec2(d.x*cos(k)-d.y*sin(k),d.x*sin(k)+d.y*cos(k));
			if(mod(k,4.)<2.)d=-d.yzx;
			for(int i=0;i<flash_pp4;i++)
			{
				if(M7(t*d+p)<.9-abs(.5*sin(q*.5)))
			{
				t-=(dt+.1);dt*=.1;
			}
			t+=dt;
		}
		vec3 c=d+vec3(2,1,3.*sin(q))*M7(t*d+p+.7);
		gl_FragColor=vec4(f*f*c*.1,4);
	}
}