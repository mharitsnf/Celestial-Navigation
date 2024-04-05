shader_type canvas_item;

uniform float cutoff : hint_range(0.0, 1.0, 0.01);
uniform float smooth_size : hint_range(0.0, 1.0, 0.01);
uniform sampler2D camera_mask_tex;
uniform sampler2D sextant_mask_tex;
uniform sampler2D transition_noise_tex;

void fragment() {
	vec3 camera_mask = texture(camera_mask_tex, UV).rgb;
	vec3 sextant_mask = texture(sextant_mask_tex, UV).rgb;
	float transition_noise = texture(transition_noise_tex, UV).r;
	float transition_weight = smoothstep(cutoff, cutoff + smooth_size, transition_noise);
	
	vec4 final_mask = vec4(mix(camera_mask, sextant_mask, transition_weight), 1.);
	float a = 1. - final_mask.r < 1. ? 0. : 1.;
	COLOR = vec4(final_mask.rgb, a);
}