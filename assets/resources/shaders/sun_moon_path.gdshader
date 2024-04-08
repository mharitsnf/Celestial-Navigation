shader_type spatial;
render_mode unshaded;

uniform vec4 albedo_color : source_color;
uniform sampler2D albedo_tex;
uniform sampler2D noise_tex;
uniform float alpha_scissor : hint_range(0.0, 1.0, 0.01);
uniform float cutoff : hint_range(0.0, 1.0, 0.01);
uniform float smooth_size : hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec4 alb = texture(albedo_tex, UV);
	vec3 color = alb.rgb * albedo_color.rgb;
	float alpha = alb.a > (1. - alpha_scissor) ? 1. : 0.;
	
	float noise = texture(noise_tex, UV).r;
	float transition_weight = smoothstep(cutoff, cutoff + smooth_size, noise);
	float final_alpha = mix(0., alpha, 1. - transition_weight);
	
	ALBEDO = color;
	ALPHA = final_alpha;
}
