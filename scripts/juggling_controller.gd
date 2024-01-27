class_name JugglingController
extends Area2D

@export_subgroup("Animation")
@export var hold_position_node: Node2D
@export var animator: AnimationPlayer

@export_subgroup("Charge Parameters")
@export var charge_period := 1.0
@export var charge_rate_curve: Curve
@export var minimum_throw_speed := 10.0
@export var maximum_throw_speed := 100.0

static var instance: JugglingController

var overlapping_bodies: Array[BallController]
var held_ball: BallController
var time_held: float


func _ready():
	instance = self
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	overlapping_bodies = []


func _physics_process(delta):
	var is_holding_ball = is_instance_valid(held_ball)
	if is_holding_ball:
		process_held_ball(delta)
	elif (Input.is_action_just_pressed("grab_ball")
			&& !overlapping_bodies.is_empty()):
		grab_ball(overlapping_bodies.pop_front())
		
	if is_holding_ball && Input.is_action_just_released("grab_ball"):
		throw_held_ball()


func grab_ball(ball_controller: BallController):
	held_ball = ball_controller
	held_ball.on_grabbed()
	process_held_ball(0)
	
func throw_held_ball():
	var mouse_position = get_global_mouse_position()
	var throw_direction = (mouse_position - global_position).normalized()
	var charge_strength = _get_normalized_charge_strength()
	var throw_speed = remap(charge_strength, 0, 1, minimum_throw_speed, maximum_throw_speed)
	held_ball.throw(throw_direction * throw_speed)
	overlapping_bodies.append(held_ball)
	held_ball = null
	time_held = 0
	
	
func process_held_ball(delta):
	time_held += delta
	animator.seek(_get_normalized_charge_strength(), true)
	held_ball.global_position = hold_position_node.global_position
	held_ball.rotation = hold_position_node.rotation
	

static func on_balls_reset():
	instance._on_balls_reset()

func _on_balls_reset():
	if is_instance_valid(held_ball):
		if overlaps_body(held_ball):
			overlapping_bodies.append(held_ball)
		held_ball = null
	
	
func _get_normalized_charge_strength() -> float:
	var t = time_held / charge_period
	return charge_rate_curve.sample(t)


func _on_body_entered(body):
	if !is_instance_valid(held_ball) && Input.is_action_pressed("grab_ball"):
		grab_ball(body)
	else:
		overlapping_bodies.append(body)
	
func _on_body_exited(body):
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)
	
