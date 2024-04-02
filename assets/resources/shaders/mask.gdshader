shader_type canvas_item;

uniform sampler2D mask_tex;
uniform float alpha : hint_range(0.0, 1.0, 0.1);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 mask = texture(mask_tex, UV).rgb;
	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;
	COLOR = vec4(mask * screen, alpha);
}