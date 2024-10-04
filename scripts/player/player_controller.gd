class_name PlayerController
extends CharacterBody2D

signal dashed

@export var input_enabled := true
@export var dash_controller: DashController
@export var respawn_offset := Vector2(0, -8)

@export_subgroup('horizontal movement')
@export var move_force: float = 10
@export var acceleration_period : float = 0.1
@export_range(0, 1) var friction: float = 0.1
@export var maximum_speed: float = 100
@export var dash_speed: float = 200

@export_subgroup('jumping')
@export var jump_velocity: float = 200
@export var gravity: float = 10

@export_subgroup("Sfx")
@export var jump_sound: AudioStreamPlayer2D
@export var dash_sound: AudioStreamPlayer2D

var acceleration: float
var last_nonzero_input_direction: float = 1


func _ready():
	LevelSignalBus.reset_triggered.connect(_reset_to_checkpoint)
	LevelSignalBus.level_completed.connect(_disable_input)
	dash_controller.dash_triggered.connect(_on_dash_triggered)
	dash_controller.directional_dash_triggered.connect(_dash)


func _physics_process(delta):
	var delta_scale = delta * Engine.physics_ticks_per_second

	velocity.y += gravity * delta_scale
	velocity.x *= (1 - friction * delta_scale)

	if input_enabled:
		var input_direction = Input.get_axis("left", "right")
		if input_direction:
			last_nonzero_input_direction = input_direction

		if dash_controller.is_dashing:
			_apply_dash_velocity(input_direction)
			
		else:
			if input_direction:
				if input_direction * velocity.x < 0:
					velocity.x = 0
					acceleration = 0

				acceleration = lerpf(acceleration, move_force, delta / acceleration_period)
				velocity.x += acceleration * input_direction * delta_scale
				velocity.x = clampf(velocity.x, -maximum_speed, maximum_speed)
			else:
				acceleration = 0

		if Input.is_action_just_pressed("jump") && is_on_floor():
			_jump(input_direction)
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = 0

	move_and_slide()


func _on_dash_triggered():
	if input_enabled:
		_dash(last_nonzero_input_direction)

func _dash(input_direction: float):
	last_nonzero_input_direction = input_direction
	_apply_dash_velocity(input_direction)
	if velocity.y > 0: velocity.y = 0
	acceleration = move_force
	dashed.emit()
	dash_sound.play()

func _apply_dash_velocity(input_direction: float):
	if input_direction == 0:
		input_direction = last_nonzero_input_direction
	velocity.x = input_direction * dash_speed


func _jump(input_direction: float):
	velocity.y = -jump_velocity
	if input_direction:
		velocity.x = maximum_speed * input_direction
	jump_sound.play()


func _reset_to_checkpoint(checkpoint_position: Vector2):
	position = checkpoint_position + respawn_offset
	velocity = Vector2.ZERO
	_disable_input()

func _disable_input():
	input_enabled = false

func _enable_input():
	input_enabled = true


func _on_hurtbox_entered(_body):
	LevelSignalBus.notify_player_died()