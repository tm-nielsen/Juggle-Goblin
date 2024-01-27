class_name BallController
extends CharacterBody2D

@export var gravity := 8.0
@export var thrown_spin_multiplier := -0.1

var angular_velocity: float
var is_held: bool


func _physics_process(delta):
	if is_held:
		return
	velocity += gravity * Vector2.DOWN
	rotation += angular_velocity * delta
	move_and_slide()
	
	if is_on_floor():
		velocity = Vector2.ZERO
		angular_velocity = 0
		rotation = PI / 4
		pass
		
func throw(p_velocity: Vector2):
	velocity = p_velocity
	angular_velocity = thrown_spin_multiplier * p_velocity.length()
	is_held = false
