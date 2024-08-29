extends MeshInstance2D

@export var target_material: ShaderMaterial
@export var offset_scale := 1.0


func _physics_process(_delta):
	var uv_offset = global_position * offset_scale
	target_material.set_shader_parameter("uv_offset", uv_offset)
