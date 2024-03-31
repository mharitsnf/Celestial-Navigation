shader_type canvas_item;

uniform float levels = 10.;
uniform sampler2D main_tex;

void fragment() {
	vec3 color = texture(main_tex, UV).rgb;
	float grayscale = max(color.r, max(color.g, color.b));
	
	float lower = floor(grayscale * levels) / levels;
	float lower_diff = abs(grayscale - lower);

	float upper = ceil(grayscale * levels) / levels;
	float upper_diff = abs(upper - grayscale);
	
	float level = lower_diff <= upper_diff ? lower : upper;
	float adjustment = level / grayscale;
	
	COLOR = vec4(color.rgb * adjustment, 1.);
}