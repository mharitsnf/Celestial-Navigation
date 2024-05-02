shader_type canvas_item;

uniform sampler2D noise_tex;
uniform sampler2D main_tex;
uniform float noise_amount = .05;
uniform bool enabled = true;

float rand(vec2 co){
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float amount = noise_amount;
	vec4 col = texture(main_tex, UV);
	if (enabled) {
		amount *= texture(noise_tex, UV + rand(UV + vec2(TIME))).x;
		col.rgb += amount;
	}
	COLOR = col;
}
