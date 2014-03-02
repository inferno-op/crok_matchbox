uniform float adsk_result_w, adsk_result_h, adsk_time, speed, offset, detail, noise_x, noise_y, fractal_x, fractal_y, random_x, random_y;
uniform int itterations;
uniform vec3 color;

vec2 resolution = vec2(adsk_result_w, adsk_result_h);

float time = adsk_time*.025 * speed + offset;
float getGas(vec2 p){
	return (cos(p.y * detail + time)+1.0)*0.5+(sin(time))*0.0+0.1;
}

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	vec2 p=position;
	for(int i=1;i<itterations;i++){
		vec2 newp=p;
		
//		newp.x+=(0.4/(float(i)))*(sin(p.y*(10.0+time*0.0001))*0.2*sin(p.x*30.0)*0.8);
//		newp.y+=(0.4/(float(i)))*(cos(p.x*(20.0+time*0.0001))*0.2*sin(p.x*5.0)+time*0.1);

		newp.x+=(noise_x / (float(i)))*(sin(p.y*(fractal_x + time * 0.0001))*0.2*sin(p.x * random_x)*0.8);
		newp.y+=(noise_y / (float(i)))*(cos(p.x*(fractal_y + time * 0.0001))*0.2*sin(p.x * random_y)+time*0.1);
		p=newp;
	}

	vec3 clr=vec3(color.r * .2 ,color.g *.2 , color.b * .2);
	clr/=getGas(p);

	gl_FragColor = vec4( clr, 1.0 );

}