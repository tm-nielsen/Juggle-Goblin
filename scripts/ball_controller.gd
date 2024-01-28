class_name BallController
extends CharacterBody2D

signal caught
signal dropped

@export var gravity := 2
@export var friction := 0.01
@export var thrown_spin_multiplier := -0.1
@export var reset_offset := Vector2(5, -5)
@export var reset_rotation := 90

var last_velocity_y: float
var angular_velocity: float
var is_frozen: bool


func _physics_process(delta):
	if is_frozen:
		return
	
	velocity += gravity * Vector2.DOWN
	velocity *= (1 - friction)
	
	rotation += angular_velocity * delta
	move_and_slide()
	
	if is_on_floor():
		dropped.emit()
			
			
func on_grabbed():
	caught.emit()
	is_frozen = true
	collision_mask = 0
		
func throw(p_velocity: Vector2):
	velocity = p_velocity
	angular_velocity = thrown_spin_multiplier * p_velocity.length()
	is_frozen = false
	collision_mask = 1
	
func reset_to_checkpoint(checkpoint_position: Vector2):
	is_frozen = true
	collision_mask = 0
	position = checkpoint_position + reset_offset
	rotation_degrees = reset_rotation
	velocity = Vector2.ZERO
	angular_velocity = 0
