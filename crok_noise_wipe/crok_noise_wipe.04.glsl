#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform float rotation;
uniform float scale;

uniform sampler2D Source, Target, adsk_results_pass3;

void main(void)
{
	vec2 center = vec2(.5);
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec3 source = texture2D(Source, st).rgb;
	vec3 target = texture2D(Target, st).rgb;

    mat2 rotation_matrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

    st -= center;
    st.x *= adsk_result_frameratio;
    st *= rotation_matrice;
	st /= scale;
    st.x /= adsk_result_frameratio;
    st += center;
	

	vec3 matte = texture2D(adsk_results_pass3, st).rgb;

	vec3 comp = mix(source, target, matte);

	gl_FragColor = vec4(comp, matte.r);
}
