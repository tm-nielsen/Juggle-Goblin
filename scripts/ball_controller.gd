class_name BallController
extends CharacterBody2D

enum ThrowState { FROZEN, JUST_THROWN, FREE}

signal caught
signal dropped

@export var gravity := 2
@export var friction := 0.01
@export var thrown_spin_multiplier := -0.1
@export var reset_offset := Vector2(5, -5)
@export var reset_rotation := 90

@export_subgroup("Sfx")
@export var grab_sound: AudioStreamPlayer2D
@export var throw_sound: AudioStreamPlayer2D

var angular_velocity: float
var state: ThrowState


func _physics_process(delta):
	if state == ThrowState.FROZEN:
		return
	
	velocity += gravity * Vector2.DOWN
	velocity *= (1 - friction)
	
	rotation += angular_velocity * delta
	move_and_slide()
	
	if state == ThrowState.JUST_THROWN:
		if velocity.y > 0:
			state = ThrowState.FREE
	elif is_on_floor():
		dropped.emit()
			
			
func on_grabbed():
	caught.emit()
	state = ThrowState.FROZEN
	collision_mask = 0
	grab_sound.play()
		
func throw(p_velocity: Vector2):
	velocity = p_velocity
	angular_velocity = thrown_spin_multiplier * p_velocity.length()
	state = ThrowState.FREE if velocity.y >= 0 else ThrowState.JUST_THROWN
	collision_mask = 1
	throw_sound.play()
	
func reset_to_checkpoint(checkpoint_position: Vector2):
	state = ThrowState.FROZEN
	collision_mask = 0
	position = checkpoint_position + reset_offset
	rotation_degrees = reset_rotation
	velocity = Vector2.ZERO
	angular_velocity = 0
