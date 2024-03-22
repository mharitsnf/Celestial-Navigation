shader_type spatial;

uniform sampler2D albedo_tex;
uniform sampler2D color_ramp;

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
}

void light() {
	float dotnl = clamp(dot(NORMAL, LIGHT), -0.95, 0.95);
	float sample_position = clamp((dotnl + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 ramp_light = texture(color_ramp, vec2(sample_position, 0.0));
	DIFFUSE_LIGHT = ramp_light.rgb;
}