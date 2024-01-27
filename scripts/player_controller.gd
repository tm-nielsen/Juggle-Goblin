extends CharacterBody2D

const MAX_SPEED = 350.0
const MAX_JUMP_VELOCITY = -400.0
const SPEED_MULTIPLIER = 5

@onready var accel_timer = $AccelerateTimer
var speed : float
var jump_velocity : float
var last_direction : int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = speed
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if(direction != 0):
		last_direction = direction
	if direction:
		if(speed < MAX_SPEED and accel_timer.is_stopped()):
			_on_accelerate_timer_timeout(direction)
		velocity.x = direction * speed
		if Input.is_action_just_pressed("slide") and is_on_floor():
			velocity.x = direction * speed * 3.0
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
