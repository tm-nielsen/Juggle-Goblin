class_name BallController
extends CharacterBody2D

@export var gravity := 8.0
@export_range(0, 1) var friction := 0.02

var is_held: bool


func _physics_process(_delta):
	if is_held:
		return
	velocity += gravity * Vector2.DOWN
	velocity *= (1 - friction)
	move_and_slide()
	
	if is_on_floor():
		#ball has been droppped
		pass
		
func throw(p_velocity: Vector2):
	velocity = p_velocity
	is_held = false
