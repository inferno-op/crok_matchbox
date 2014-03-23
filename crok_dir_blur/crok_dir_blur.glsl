uniform sampler2D image;
uniform float adsk_result_w, adsk_result_h;
uniform float gain;
uniform float iterations;
uniform float blur_x;
uniform float blur_y;

float random(vec3 scale, float seed) {
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 8643.5453 + seed);
}

void main(void) {
	vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec2 direction;
	direction = vec2(blur_x,blur_y);
    float noise = random(vec3(543.12341, 74.30434, 13123.4234234), 2.0);
    vec4 color = vec4(0.0);
    float ws = 0.0;

	for(float steps = -iterations; steps <= iterations; steps++) {
        float p = (steps + noise - 0.5) / 16.0;
        float w = 1.0 - abs(p);
        color += texture2D(image, uv + direction*.02 * p) * w;
        ws += w;
    }
	gl_FragColor = vec4(color.rgb / ws * gain, 1.0);

}