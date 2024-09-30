class_name PlayerController
extends CharacterBody2D

enum DashState {CAPABLE, ACTIVE, COOLDOWN}

signal dashed

@export var input_enabled := true

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

@export_subgroup('Timer references')
@export var dash_timer: Timer
@export var dash_cooldown_timer: Timer

var dash_state: DashState
var acceleration: float
var last_nonzero_input_direction: float = 1

# @onready var accel_timer = $AccelerateTimer
# @onready var dash_timer = $DashTimer
# @onready var cooldown_timer = $CooldownTimer

# var speed : float
# var jump_velocity : float
# var last_direction : int

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	LevelSignalBus.reset_triggered.connect(_reset_to_checkpoint)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)

# func _process(_delta):
# 	var input_vector = Vector2.ZERO
# 	var viewport_width = get_viewport_rect().size[0]
# 	var viewport_height = get_viewport_rect().size[1]
# 	input_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
# 	input_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
# 	input_vector.normalized()
	
# 	if input_vector != Vector2.ZERO:
# 		var new_position = get_viewport().get_mouse_position() + input_vector
# 		new_position.x = clamp(new_position.x, 0, viewport_width)
# 		new_position.y = clamp(new_position.y, 0, viewport_height)
# 		get_viewport().warp_mouse(new_position)
		


func _physics_process(delta):
	var delta_scale = delta * Engine.physics_ticks_per_second

	velocity.y += gravity * delta_scale
	velocity.x *= (1 - friction * delta_scale)

	if input_enabled:
		var input_direction = Input.get_axis("left", "right")
		if input_direction:
			last_nonzero_input_direction = input_direction

		if dash_state == DashState.ACTIVE:
			_apply_dash_velocity(input_direction)
		elif dash_state == DashState.CAPABLE && Input.is_action_just_pressed('dash'):
			_dash(input_direction)
			
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

			

		

		# Handle jump.
		if Input.is_action_just_pressed("jump") && is_on_floor():
			_jump(input_direction)
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = 0
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		# var direction = Input.get_axis("left", "right")

		# if direction:
			
		# 	# Accelerates character by speed multiplier on accel timer interval
		# 	if(speed < max_speed and accel_timer.is_stopped()):
		# 		_on_accelerate_timer_timeout(direction)
			
		# 	# Sets speed to initial_speed if direction changes while moving
		# 	if(direction != last_direction or speed == 0):
		# 		speed = 0
			
		# 	# Starts dash timer and cooldown timer
		# 	if(Input.is_action_just_pressed("dash") and dash_timer.is_stopped()
		# 	 and cooldown_timer.is_stopped()):
		# 		dash_timer.start()
		# 		cooldown_timer.start()
		# 		dashed.emit()
		# 		dash_sound.play()
			
		# 	# Use dash speed if dash timer is greater than zero
		# 	if(dash_timer.time_left > 0):
		# 		velocity.x = direction * speed * dash_multiplier
		# 	# Otherwise stick to regular speed
		# 	else:
		# 		velocity.x = direction * speed
			
		# 	# Stores last direction
		# 	last_direction = direction
			
		# else:
		# 	if(speed > 0):
		# 		_on_accelerate_timer_timeout(0)
		# 		velocity.x = last_direction * speed
		# 	else:
		# 		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _dash(input_direction: float):
	_apply_dash_velocity(input_direction)
	if velocity.y > 0: velocity.y = 0
	acceleration = move_force
	dash_state = DashState.ACTIVE
	dash_timer.start()
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

	

# func _on_accelerate_timer_timeout(direction):
# 	if(direction != 0):
# 		speed += speed_multiplier
# 	else:
# 		speed -= speed_multiplier
# 		if(speed < 0):
# 			speed = 0
# 	return speed

func _reset_to_checkpoint(checkpoint_position: Vector2):
	position = checkpoint_position
	velocity = Vector2.ZERO


func _on_dash_timer_timeout():
	dash_state = DashState.COOLDOWN
	dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout():
	dash_state = DashState.CAPABLE


func _on_hurtbox_entered(_body):
	LevelSignalBus.notify_player_died()