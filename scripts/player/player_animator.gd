class_name PlayerAnimator
extends AnimatedSprite2D

enum PlayerState { IDLE, WALKING, AIRBORNE, LANDING }

@export var player_controller: PlayerController

@export_subgroup("run animation")
@export var minimum_speed_scale := 0.75
@export var maximum_speed_scale := 1.5

var player_state: PlayerState
var is_playing_dash_animation: bool: get = _get_is_playing_dash_animation


func _ready():
	animation_finished.connect(_on_animation_finished)
	player_controller.dashed.connect(_on_player_dashed)


func _physics_process(_delta):
	flip_h = player_controller.velocity.x < 0

	if player_state == PlayerState.AIRBORNE:
		if player_controller.is_on_floor():
			player_state = PlayerState.LANDING
			play("Land")
			
	else:
		if Input.is_action_just_pressed("jump"):
			player_state = PlayerState.AIRBORNE
			speed_scale = 1.0
			play("Jump")
		
		var input_direction = Input.get_axis("left", "right")
		if player_state == PlayerState.IDLE:
			if input_direction != 0:
				player_state = PlayerState.WALKING
				play("Walk")
		
		if player_state == PlayerState.WALKING:
			if input_direction == 0:
				speed_scale = 1.0
				player_state = PlayerState.IDLE
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
			
func _on_animation_finished():
	if player_state == PlayerState.LANDING:
		player_state = PlayerState.IDLE
		play("Idle")
	if is_playing_dash_animation:
		if player_state == PlayerState.AIRBORNE:
			play("Jump")
			frame = 2
		else:
			player_state = PlayerState.IDLE
			play("Idle")

func _get_is_playing_dash_animation() -> bool:
	return animation == 'Dash'