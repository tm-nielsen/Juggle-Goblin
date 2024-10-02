shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 offset = vec2(2, -1);
uniform vec4 shadow_colour: source_color = vec4(vec3(0), 0.4);

void fragment() {
	vec4 base_colour = textureLod(screen_texture, SCREEN_UV, 0.0);

	if (base_colour.a > 0.0001) {
		base_colour.rgb /= base_colour.a;
	}
	
	vec2 offset_uv = SCREEN_UV - offset * SCREEN_PIXEL_SIZE;
	vec4 offset_sample = texture(screen_texture, offset_uv);
	
	float shadow_strength = offset_sample.a;
	
	COLOR.rgb *= mix(shadow_colour.rgb, base_colour.rgb, step(1.0 - base_colour.a, 0));
	COLOR.a *= base_colour.a + shadow_strength * shadow_colour.a;
}
