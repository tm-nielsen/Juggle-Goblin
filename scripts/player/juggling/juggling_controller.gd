class_name JugglingController
extends Area2D

static var instance: JugglingController

@export_subgroup("Animation")
@export var hold_position_node: Node2D
@export var animator: AnimationPlayer

@export_subgroup('throw speed', 'throw_speed')
@export var throw_speed_minimum := 10.0
@export var throw_speed_maximum := 100.0

var overlapping_bodies: Array[BallController]
var held_ball: BallController
var time_held: float

var is_holding_ball: get = _is_holding_ball


func _ready():
	instance = self
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	hold_position_node.hide()
	overlapping_bodies = []

func _physics_process(delta):
	if is_holding_ball:
		process_held_ball(delta)
	elif should_catch():
		grab_ball(overlapping_bodies.pop_front())
		is_holding_ball = true
	
	if should_throw():
		throw_held_ball()


func grab_ball(ball_controller: BallController):
	held_ball = ball_controller
	held_ball.on_grabbed()
	process_held_ball(0)
	
func throw_held_ball():
	var throw_velocity = get_throw_velocity()
	held_ball.throw(throw_velocity)
	if overlaps_body(held_ball) && !overlapping_bodies.has(held_ball):
		overlapping_bodies.append(held_ball)
	held_ball = null
	time_held = 0
	
	
func process_held_ball(delta):
	time_held += delta
	animator.seek(get_animation_time(), true)
	held_ball.global_position = hold_position_node.global_position
	held_ball.rotation = hold_position_node.rotation
	

static func on_balls_reset():
	instance._on_balls_reset()

func _on_balls_reset():
	if is_instance_valid(held_ball):
		if overlaps_body(held_ball):
			overlapping_bodies.append(held_ball)
		held_ball = null
	

func get_throw_velocity() -> Vector2: return Vector2.UP * throw_speed_maximum
func get_animation_time() -> float: return time_held

func should_catch() -> bool: return !overlapping_bodies.is_empty()
func should_catch_on_body_entered() -> bool: return false
func should_throw() -> bool: return is_holding_ball

func _is_holding_ball() -> bool: return is_instance_valid(held_ball)

func _on_body_entered(body):
	if !is_instance_valid(held_ball) && should_catch_on_body_entered():
		grab_ball(body)
	else:
		overlapping_bodies.append(body)
	
func _on_body_exited(body):
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)