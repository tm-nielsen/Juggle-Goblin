shader_type canvas_item;

void fragment() {
	vec2 uv = UV - vec2(0.5f);
	COLOR.a = step(length(uv), 0.5f);
}