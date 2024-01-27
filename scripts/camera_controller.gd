class_name CameraController
extends Camera2D

@export var player: CharacterBody2D

func _process(delta):
	global_position.x = player.global_position.x
	if global_position.x < 0:
		global_position.x = 0
