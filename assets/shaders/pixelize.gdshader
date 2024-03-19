shader_type canvas_item;

uniform sampler2D main_tex;
uniform int pixel_size = 5;

void fragment() {
	ivec2 i_tex_size = textureSize(main_tex,0);
	vec2 tex_size = vec2(i_tex_size);
	
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);
	
	x = floor(float(pixel_size) / 2.) - x;
	y = floor(float(pixel_size) / 2.) - y;
	
	x = FRAGCOORD.x + x;
	y = FRAGCOORD.y + y;
	
	COLOR = texture(main_tex, vec2(x,y) / tex_size);
}