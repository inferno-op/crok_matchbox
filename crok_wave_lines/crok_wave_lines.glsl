// based on http://glsl.heroku.com/e#13475.0

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
uniform float Lines;  //5.0
uniform float Brightness; // 0.3
uniform float Speed;
uniform float Offset;
uniform float Glow;

uniform vec3 Colour1;  // 1.4, 0.8, 0.4
uniform vec3 Colour2;  // 0.5, 0.9, 1.3
uniform vec3 Colour3;  // 0.9, 1.4, 0.4
uniform vec3 Colour4; // 1.8, 0.4, 0.3

vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time * 0.01 * Speed + Offset;

void main() {
    float x, y, xpos, ypos;
	    float t = time * 10.0;
    vec3 c = vec3(0.0);
    
    xpos = (gl_FragCoord.x / resolution.x);
    ypos = (gl_FragCoord.y / resolution.y);
    
    x = xpos;
    for (float i = 0.0; i < Lines; i += 1.0) {
        for(float j = 0.0; j < 2.0; j += 1.0){
            y = ypos
            + (0.30 * sin(x * 2.000 +( i * 1.5 + j) * 0.2 + t * 0.050)
               + 0.300 * cos(x * 6.350 + (i  + j) * 0.2 + t * 0.050 * j)
               + 0.024 * sin(x * 12.35 + ( i + j * 4.0 ) * 0.8 + t * 0.034 * (8.0 *  j))
               + 0.5);
            
            c += vec3(1.0 - pow(clamp(abs(1.0 - y) * 1. / Glow * 10., 0.0,1.0), 0.25));
        }
    }
    
    c *= mix(
             mix(Colour1, Colour2, xpos)
             , mix(Colour3, Colour4, xpos)
             ,(sin(t * 0.02) + 1.0) * 0.45
             ) * Brightness * .1;
    
    gl_FragColor = vec4(c, 1.0);
}
