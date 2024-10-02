class_name PlayerAnimator
extends AnimatedSprite2D

enum PlayerState { IDLE, WALKING, AIRBORNE, LANDING, CELEBRATING }
const IDLE = PlayerState.IDLE
const WALKING = PlayerState.WALKING
const AIRBORNE = PlayerState.AIRBORNE
const LANDING = PlayerState.LANDING
const CELEBRATING = PlayerState.CELEBRATING

@export var player_controller: PlayerController

@export_subgroup("run animation")
@export var minimum_speed_scale := 0.75
@export var maximum_speed_scale := 1.5
@export var flip_threshold := 1

var player_state: PlayerState
var is_playing_dash_animation: bool: get = _get_is_playing_dash_animation
var level_completed: bool


func _ready():
	animation_finished.connect(_on_animation_finished)
	player_controller.dashed.connect(_on_player_dashed)
	LevelSignalBus.level_completed.connect(_on_level_completed)


func _physics_process(_delta):
	if level_completed: return

	if player_controller.velocity.x > flip_threshold:
		flip_h = false
	elif player_controller.velocity.x < -flip_threshold:
		flip_h = true

	if player_state == AIRBORNE:
		if player_controller.is_on_floor():
			player_state = LANDING
			play("Land")
			
	else:
		if Input.is_action_just_pressed("jump"):
			player_state = AIRBORNE
			speed_scale = 1.0
			play("Jump")
		
		var input_direction = Input.get_axis("left", "right")
		if player_state == IDLE:
			if input_direction != 0:
				player_state = WALKING
				play("Walk")
		
		if player_state == WALKING:
			if input_direction == 0:
				speed_scale = 1.0
				player_state = IDLE
				play("Idle")
			elif !is_playing_dash_animation:
				scale_walk_animation_speed()
				
func scale_walk_animation_speed():
	var horizontal_speed = abs(player_controller.velocity.x)
	var speed_ratio = horizontal_speed / player_controller.maximum_speed
	speed_scale = remap(speed_ratio, 0, 1, minimum_speed_scale, maximum_speed_scale)
	
	
func _on_player_dashed():
	speed_scale = 1.0
	play("Dash")


func _on_level_completed():
	level_completed = true
	player_state = CELEBRATING
	play("Celebrate")


func _on_animation_finished():
	if player_state == LANDING || player_state == CELEBRATING:
		player_state = IDLE
		play("Idle")
	if is_playing_dash_animation:
		if player_state == AIRBORNE:
			play("Jump")
			frame = 2
		else:
			player_state = IDLE
			play("Idle")

func _get_is_playing_dash_animation() -> bool:
	return animation == 'Dash'