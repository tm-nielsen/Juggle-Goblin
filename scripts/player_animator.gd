class_name PlayerAnimator
extends AnimatedSprite2D

enum PlayerState { IDLE, WALKING, AIRBORNE, LANDING }

@export var parent_body: CharacterBody2D

@export_subgroup("run animation")
@export var minimum_speed_scale := 0.75
@export var maximum_speed_scale := 1.5

var player_state: PlayerState


func _ready():
	animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	if player_state == PlayerState.AIRBORNE:
		if parent_body.is_on_floor():
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
				flip_h = input_direction < 0
				play("Walk")
		
		if player_state == PlayerState.WALKING:
			if input_direction == 0:
				speed_scale = 1.0
				player_state = PlayerState.IDLE
				play("Idle")
			else:
				flip_h = input_direction < 0
				scale_walk_animation_speed()
				
func scale_walk_animation_speed():
	var horizontal_speed = abs(parent_body.velocity.x)
	var speed_portion = horizontal_speed / parent_body.max_speed
	speed_scale = remap(speed_portion, 0, 1, minimum_speed_scale, maximum_speed_scale)
			
			
func _on_animation_finished():
	if player_state == PlayerState.LANDING:
		player_state = PlayerState.IDLE
		play("Idle")
