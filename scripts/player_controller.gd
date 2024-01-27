extends CharacterBody2D

const MAX_SPEED = 350.0
const MAX_JUMP_VELOCITY = -450.0
const SPEED_MULTIPLIER = 10
const MAX_SLIDE_MULTIPLIER = 4

@onready var accel_timer = $AccelerateTimer
var speed : float
var slide_multiplier : float
var jump_velocity : float
var last_direction : int
var sliding_speed : float
var is_sliding = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = MAX_JUMP_VELOCITY
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 0
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")

	if direction:
		if(slide_multiplier == 0):
			if(direction != 0):
				last_direction = direction
			if(speed < MAX_SPEED and accel_timer.is_stopped()):
				_on_accelerate_timer_timeout(direction)
			if Input.is_action_just_pressed("slide") and is_on_floor():
				slide_multiplier = MAX_SLIDE_MULTIPLIER
				_on_slide_timer_timeout()
		# Kept this out of slide just in case you want to suddenly stop sliding
		if(direction != last_direction and last_direction != 0):
			speed = 0
		if(speed < MAX_SPEED and accel_timer.is_stopped()):
			_on_accelerate_timer_timeout(direction)
		if Input.is_action_just_pressed("slide") and is_on_floor() and slide_multiplier == 0:
			slide_multiplier = MAX_SLIDE_MULTIPLIER
			_on_slide_timer_timeout()
		# If we are sliding we will use the velocity.x calculation with the gradually decreasing multiplier
		if(slide_multiplier > 0):
			velocity.x = last_direction * speed * slide_multiplier
		else:
			velocity.x = last_direction * speed
	else:
		if(speed > 0):
			_on_accelerate_timer_timeout(0)
			velocity.x = last_direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_accelerate_timer_timeout(direction):
	if(direction != 0):
		speed += SPEED_MULTIPLIER
	else:
		speed -= SPEED_MULTIPLIER
	return speed
	

func _on_slide_timer_timeout():
	slide_multiplier -= 0.5
	if(slide_multiplier > 0):
		_on_slide_timer_timeout()
	return slide_multiplier
