class_name JugglingController
extends Area2D

@export var hold_position_node: Node2D
@export var charge_rate := 10.0

var overlapping_bodies: Array[BallController]
var held_ball: BallController
var held_charge: float


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	overlapping_bodies = []


func _physics_process(delta):
	var is_holding_ball = is_instance_valid(held_ball)
	if is_holding_ball:
		held_charge += charge_rate * delta
		held_ball.global_position = hold_position_node.global_position
	
	if (Input.is_action_just_pressed("grab_ball")
			&& !overlapping_bodies.is_empty()):
		grab_ball(overlapping_bodies.pop_front())
		
	if is_holding_ball && Input.is_action_just_released("grab_ball"):
		throw_held_ball()


func grab_ball(ball_controller: BallController):
	held_ball = ball_controller
	held_ball.is_held = true
	held_ball.global_position = hold_position_node.global_position
	
func throw_held_ball():
	var mouse_position = get_global_mouse_position()
	var throw_direction = mouse_position - held_ball.global_position
	held_ball.throw(throw_direction * held_charge)
	overlapping_bodies.append(held_ball)
	held_ball = null
	held_charge = 0
	

func _on_body_entered(body):
	if Input.is_action_pressed("grab_ball"):
		grab_ball(body)
	else:
		overlapping_bodies.append(body)
	
func _on_body_exited(body):
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)
	
