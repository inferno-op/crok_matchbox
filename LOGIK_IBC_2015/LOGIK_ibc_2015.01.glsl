// based on http://glslsandbox.com/e#26585.0
// By @eddbiddulph


uniform float adsk_result_w, adsk_result_h, adsk_time;
// vec2 resolution = vec2(adsk_result_w, adsk_result_h);
vec2 resolution = vec2(960.0, 300.);


const float Pi = 3.14159;
const float kInvPi = 1.0 / 3.141592;

float circle ( float rad, float thick, float length, float off, vec2 p, float c_aspect )
{
    // Define how blurry the circle should be. 
    // A value of 1.0 means 'sharp', larger values
    // will increase the bluriness.
    float bluriness = 1.0;
    
    // In the range (0, 1].
    float radius = rad;
    
    // In the range (0, 1].
    float thickness = thick;
    
    // In the range (0, 1].
    float len = length;
    
    // Optional offset.
    float offset = off;
    
    // Convert from range [0,1] to [-1,1]
    p = 2.0 * p - 1.0;
    
    // Adjust for the aspect ratio. Not necessary if
    // you supplied texture coordinates yourself.
    p.x *= (resolution.x / resolution.y);
	p.x *= c_aspect;
    
    // Calculate distance to (0,0).
    float d = length( p );
    
    // Calculate angle, so we can draw segments, too.
    float angle = atan( p.x, p.y ) * kInvPi * 0.5;
	angle = fract( angle - offset );
    
    // Create an anti-aliased circle.
    float w = bluriness * fwidth( d );
    float circle = smoothstep( radius + w, radius - w, d );
    
    // Optionally, you could create a hole in it:
    float inner = radius - thickness;
    circle -= smoothstep( inner + w, inner - w, d );
    
    // Or only draw a portion (segment) of the circle.
    float segment = smoothstep( len + 0.002, len, angle );
	segment *= smoothstep( 0.0, 0.002, angle );    
    circle *= mix( segment, 1.0, step( 1.0, len ) );
	
	return circle; 
}

// return 1.0 when e0 < x < e1, otherwise return 0.0
float box(float e0, float e1, float x)
{
    return step(e0, x) - step(e1, x);
}

// return 1.0 when p is within a given trapezium, otherwise return 0.0
float section(  float y0, float y1, float dxdy0, float dxdy1,
                float x0_ofs, float x1_ofs, vec2 p)
{
    float x0 = dxdy0 * p.y + x0_ofs, x1 = dxdy1 * p.y + x1_ofs;
    return box(y0, y1, p.y) * box(x0, x1, p.x);
}

void main()
{
    vec2 tex_resolution = vec2(320.0, 200.0);
	vec2 uv = gl_FragCoord.xy / resolution;
    vec2 position = gl_FragCoord.xy * tex_resolution / resolution;
    position.y = tex_resolution.y - position.y; // flip image
    
	// L
	float mask = section(34.58, 143.6, 0.0, 0.0, 31.04, 51.11, position);
	mask += section(108.08, 143.6, 0.0, 0.0, 50.98, 68.15, position);

	// O
	mask += circle(0.62, 0.34, 1.0, 0.0, uv + vec2(0.18, -0.05), 0.95);
	
	// G
	mask += section(107.11, 79.99, -0.46 * .1, 0.0, 203.490, 167.03, position);
	mask += circle(0.59, 0.35, 0.91, 0.24, uv + vec2(-0.028, -0.05), 0.96);
	
	// I
	mask += section(36.0, 145.86, 0.0, 0.0, 207.14, 227.99, position);

	// K
	mask += section(36.25, 146.06, 0.0, 0.0, 237.11, 256.68, position);
	mask += section(36.01, 90.26, -2.69 *.1, -3.18 *.1, 278.35, 302.40, position);
	mask += section(88.95, 146.14, 2.85 *.1, 3.32 *.1, 227.37, 244.25, position);
		
	mask = clamp(mask,0.0,1.0);
	vec4 col = vec4(vec3(1.0, 0.12, 0.1) * mask, mask);
	
    gl_FragColor = col;
}