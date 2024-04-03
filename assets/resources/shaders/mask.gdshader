shader_type canvas_item;

uniform sampler2D mask_tex;

void fragment() {
	vec3 mask = texture(mask_tex, UV).rgb;
	float a = 1. - mask.r < 1. ? 0. : 1.;
	COLOR = vec4(mask, a);
}