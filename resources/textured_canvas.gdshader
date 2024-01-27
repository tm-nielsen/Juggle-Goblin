shader_type canvas_item;

uniform sampler2D colour_texture: filter_nearest, repeat_enable;
uniform vec2 uv_offset;
uniform vec2 uv_scale;


void fragment() {
	vec4 colour = texture(colour_texture, UV * uv_scale + uv_offset);
	COLOR = colour;
}
