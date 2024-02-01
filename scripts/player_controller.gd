extends CharacterBody2D

signal dashed

@export var input_enabled := true

@export var max_speed = 750.0
@export var max_jump_velocity = -450.0
@export var speed_multiplier = 150.0
@export var dash_multiplier = 3

@export_subgroup("Sfx")
@export var jump_sound: AudioStreamPlayer2D
@export var dash_sound: AudioStreamPlayer2D

@onready var accel_timer = $AccelerateTimer
@onready var dash_timer = $DashTimer
@onready var cooldown_timer = $CooldownTimer

var speed : float
var jump_velocity : float
var last_direction : int


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	var input_vector = Vector2.ZERO
	var viewport_width = get_viewport_rect().size[0]
	var viewport_height = get_viewport_rect().size[1]
	input_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	input_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		var new_position = get_viewport().get_mouse_position() + input_vector
		new_position.x = clamp(new_position.x, 0, viewport_width)
		new_position.y = clamp(new_position.y, 0, viewport_height)
		get_viewport().warp_mouse(new_position)
		


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if input_enabled:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = max_jump_velocity
			jump_sound.play()
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = 0
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")

		if direction:
			
			# Accelerates character by speed multiplier on accel timer interval
			if(speed < max_speed and accel_timer.is_stopped()):
				_on_accelerate_timer_timeout(direction)
			
			# Sets speed to initial_speed if direction changes while moving
			if(direction != last_direction or speed == 0):
				speed = 0
			
			# Starts dash timer and cooldown timer
			if(Input.is_action_just_pressed("dash") and dash_timer.is_stopped()
			 and cooldown_timer.is_stopped()):
				dash_timer.start()
				cooldown_timer.start()
				dashed.emit()
				dash_sound.play()
			
			# Use dash speed if dash timer is greater than zero
			if(dash_timer.time_left > 0):
				velocity.x = direction * speed * dash_multiplier
			# Otherwise stick to regular speed
			else:
				velocity.x = direction * speed
			
			# Stores last direction
			last_direction = direction
			
		else:
			if(speed > 0):
				_on_accelerate_timer_timeout(0)
				velocity.x = last_direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	

func _on_accelerate_timer_timeout(direction):
	if(direction != 0):
		speed += speed_multiplier
	else:
		speed -= speed_multiplier
		if(speed < 0):
			speed = 0
	return speed
		
