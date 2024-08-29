class_name Corpse
extends Node2D

@export var body: RigidBody2D
@export var body_sprite: AnimatedSprite2D
@export var minimum_luanch_speed := 20.0
@export var maximum_launch_speed := 150.0
@export var spread_angle := PI / 4


func launch_body(player_velocity: Vector2):
	var launch_direction = Vector2.UP
	launch_direction = launch_direction.rotated((1 - 2 * randf()) * spread_angle)
	var launch_speed = remap(randf(), 0, 1, minimum_luanch_speed, maximum_launch_speed)
	
	if body_sprite:
		body_sprite.flip_h = launch_direction.x > 0
	
	body.linear_velocity = launch_direction * launch_speed + player_velocity
