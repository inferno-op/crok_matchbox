uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;
uniform float r_blur, g_blur, b_blur;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
vec3 blur = vec3(r_blur, g_blur, b_blur);

void main(void)
{
	vec2 uv = gl_FragCoord.xy / resolution;
    int denominator = 0;
    const float intensity = 1.0;
    vec2 pixelWidth = vec2(1.0)/resolution.xy * intensity;
    const int size = 5;
	
	vec3 noise = texture2D(adsk_results_pass1, uv).rgb;
	
	if ( blur != vec3(0.0) )
        {
		    for (int x=-size; x<size; x++) {
		        for (int y=-size; y<size; y++) {
            
		        	float fx_r = float(x) * pixelWidth.x*blur.r;
		           	float fy_r = float(y) * pixelWidth.y*blur.r;
					noise.r += texture2D(adsk_results_pass1, uv + vec2(fx_r,fy_r)).r;
			
		        	float fx_g = float(x) * pixelWidth.x*blur.g;
		           	float fy_g = float(y) * pixelWidth.y*blur.g;
					noise.g += texture2D(adsk_results_pass1, uv + vec2(fx_g,fy_g)).g;
			
		        	float fx_b = float(x) * pixelWidth.x*blur.b;
		           	float fy_b = float(y) * pixelWidth.y*blur.b;
					noise.b += texture2D(adsk_results_pass1, uv + vec2(fx_b,fy_b)).b;  
			      
		        	denominator++;
		        }
		    }
			noise /= float(denominator);
        }
		gl_FragColor.rgb = noise;
	}
