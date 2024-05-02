shader_type canvas_item;

uniform sampler2D white_tex;
uniform sampler2D black_tex;
uniform sampler2D mask_tex;
uniform float cutoff : hint_range(0.0, 1.0, 0.01);
uniform float smooth_size : hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec4 white_col = texture(white_tex, UV);
	vec4 black_col = texture(black_tex, UV);
	float mask = texture(mask_tex, UV).x;
	float transition_weight = smoothstep(cutoff, cutoff + smooth_size, mask);
	COLOR = mix(black_col, white_col, transition_weight);
	//COLOR = vec4(vec3(transition_weight), 1.);
}
