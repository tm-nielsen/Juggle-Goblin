shader_type canvas_item;

uniform float effect_level: hint_range(0, 1) = 0.5;

void fragment() {
	float g = dot(COLOR.rgb, vec3(0.21, 0.72, 0.07));
	COLOR.rgb = mix(COLOR.rgb, vec3(g), effect_level);
}