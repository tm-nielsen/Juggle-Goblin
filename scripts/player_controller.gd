extends CharacterBody2D

@export var input_enabled := true

@export var max_speed = 750.0
@export var max_jump_velocity = -450.0
@export var speed_multiplier = 150.0
@export var dash_multiplier = 3

@onready var accel_timer = $AccelerateTimer
@onready var dash_timer = $DashTimer
@onready var cooldown_timer = $CooldownTimer

var speed : float
var jump_velocity : float
var last_direction : int


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if input_enabled:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = max_jump_velocity
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
		
