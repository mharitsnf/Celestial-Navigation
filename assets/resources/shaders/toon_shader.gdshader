shader_type spatial;

uniform sampler2D albedo_tex;
uniform sampler2D color_ramp;
uniform float levels = 10.;

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
}

void light() {
	float dotnl = clamp(dot(NORMAL, LIGHT), -0.95, 0.95);
	float sample_position = clamp((dotnl + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 ramp_light = texture(color_ramp, vec2(sample_position, 0.0));
	vec3 diffuse_light = ramp_light.rgb * clamp(LIGHT_COLOR * ATTENUATION, vec3(0,0,0), vec3(1,1,1));
	DIFFUSE_LIGHT += max(diffuse_light, DIFFUSE_LIGHT);
}