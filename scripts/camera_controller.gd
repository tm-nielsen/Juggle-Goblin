class_name CameraController
extends Camera2D

@export var player: CharacterBody2D
@export var follow_offset := Vector2(0, -12)
@export_range(0, 1) var y_lerp := 0.2
@export var slope_offset_factor := 10.0

func _process(_delta):
	var target_position = player.global_position + follow_offset
	
	global_position.x = target_position.x
	if global_position.x < 0:
		global_position.x = 0
		
	if player.is_on_floor():
		var slope_offset = _get_slope_offset()
		global_position.y -= slope_offset
		global_position.y = lerp(global_position.y, target_position.y, y_lerp)
		global_position.y += slope_offset
		

func _get_slope_offset() -> float:
	var floor_normal = player.get_floor_normal()
	return slope_offset_factor * floor_normal.x
	
