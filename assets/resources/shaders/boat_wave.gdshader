shader_type spatial;
render_mode cull_disabled;

uniform float z_disp_scale : hint_range(0.0, 1.0, 0.01) = 1.;
uniform sampler2D albedo_tex;
uniform sampler2D color_ramp;

float remap(float value, float old_min, float old_max, float new_min, float new_max) {
	return ( (value - old_min) / (old_max - old_min) ) * (new_max - new_min) + new_min;
}

float ease_out_cubic(float x) {
	return 1. - pow(1. - x, 3.);
}

void vertex() {
	float x_n_vertex = remap(VERTEX.x, -3., 3., 0., 1.);
	float y_n_vertex = remap(VERTEX.y, -3., 3., 0., 1.);
	float z_offset = ease_out_cubic(x_n_vertex);
	z_offset = pow(z_offset, 5.);
	VERTEX.z += z_offset * z_disp_scale;
}

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