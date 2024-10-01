shader_type canvas_item;

uniform sampler2D colour_texture: filter_nearest, repeat_disable, hint_default_black;
uniform float texture_slide_amount: hint_range(0, 1) = 0.5;

uniform float right_edge: hint_range(0, 1) = 0.75;
uniform float left_edge: hint_range(0, 1) = 0.25;
uniform float slant = 0.25;

void fragment() {
	float sampling_offset = 1.0 - (left_edge + right_edge);
	sampling_offset *= texture_slide_amount;
	COLOR *= texture(colour_texture, UV + vec2(sampling_offset, 0.0));
	
	float t = (UV.x + UV.y * slant) / (1.0 + slant);
	float right_step = step(t - right_edge, 0.0);
	float left_step = step(0.0, t - left_edge);
	COLOR.a *= right_step * left_step;
}