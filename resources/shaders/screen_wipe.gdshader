shader_type canvas_item;

uniform float right_edge: hint_range(0, 1) = 0.75;
uniform float left_edge: hint_range(0, 1) = 0.25;
uniform float slant = 0.25;

void fragment() {
	float t = (UV.x + UV.y * slant) / (1.0 + slant);
	float right_step = step(t - right_edge, 0.0);
	float left_step = step(0.0, t - left_edge);
	COLOR.a = right_step * left_step;
}