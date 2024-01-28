class_name CameraController
extends Camera2D

@export var player: CharacterBody2D
@export var follow_offset := Vector2(0, -12)
@export var y_lerp := 0.2

func _process(_delta):
	var target_position = player.global_position + follow_offset
	
	global_position.x = target_position.x
	if global_position.x < 0:
		global_position.x = 0
	
	global_position.y = lerp(global_position.y, target_position.y, y_lerp)
