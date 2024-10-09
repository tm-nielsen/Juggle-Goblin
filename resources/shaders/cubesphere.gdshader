shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform float radius = 1;

uniform vec4 albedo: source_color = vec4(1);
uniform sampler2D texture_albedo: source_color;

uniform float roughness: hint_range(0.0, 1.0) = 0.01;
uniform sampler2D texture_roughness: hint_roughness_gray;

uniform float normal_scale: hint_range(-16.0, 16.0) = 5;
uniform sampler2D texture_normal: hint_normal;

uniform vec2 uv_scale = vec2(1);
uniform vec2 uv_offset;


void vertex() {
	UV = UV * uv_scale + uv_offset;

	NORMAL = normalize(VERTEX);
	VERTEX = NORMAL * radius;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float roughness_tex = dot(texture(texture_roughness, UV), vec4(1));
	ROUGHNESS = roughness_tex * roughness;

	NORMAL_MAP = texture(texture_normal, UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}
