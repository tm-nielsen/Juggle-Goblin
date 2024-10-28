class_name TackBallJugglingController
extends JugglingController

enum ThrowState {IDLE, INPUT, THROW_PENDING}

@export_subgroup('throw', 'throw')
@export var throw_acceleration_threshold: float = 5
@export var throw_speed_multiplier: float = 10
@export var throw_input_window: float = 0.05

@export_subgroup('animation')
@export var animation_period: float = 1.0

var pending_throw_velocity: Vector2
var last_cursor_acceleration: Vector2

var throw_state: ThrowState
var total_throw_input: Vector2


func _ready():
  if Settings.input_mode != Settings.TRACKBALL_INPUT:
    queue_free()
  else:
    super()
    CursorMovement.cursor_moved.connect(_on_cursor_moved)


func _process(_delta):
  if !super.should_throw():
    throw_state = ThrowState.IDLE
    pending_throw_velocity = Vector2.ZERO

func _physics_process(delta):
  super(delta)
  last_cursor_acceleration = CursorMovement.acceleration


func grab_ball(ball_controller: BallController):
  super(ball_controller)
  _start_input_window()
  _capture_throw_input(CursorMovement.acceleration)


func _on_cursor_moved(_velocity: Vector2, acceleration: Vector2):
  if throw_state == ThrowState.INPUT:
    _capture_throw_input(acceleration)

func _start_input_window():
  throw_state = ThrowState.INPUT
  total_throw_input = Vector2.ZERO
  var input_window_tween = create_tween()
  input_window_tween.tween_interval(throw_input_window)
  input_window_tween.tween_callback(_end_input_window)

func _end_input_window():
  throw_state = ThrowState.THROW_PENDING
  var throw_direction = total_throw_input.normalized()
  var throw_speed = _get_throw_speed(total_throw_input)
  pending_throw_velocity = throw_direction * throw_speed

  
func _capture_throw_input(input_vector: Vector2):
  if input_vector.y > 0: return
  total_throw_input += input_vector

func _get_throw_speed(input_vector: Vector2) -> float:
  var speed = input_vector.length() * throw_speed_multiplier
  return clampf(speed, throw_speed_minimum, throw_speed_maximum)


func throw_held_ball():
  throw_state = ThrowState.IDLE
  super()
  pending_throw_velocity = Vector2.ZERO

  
func get_throw_velocity() -> Vector2:
  return pending_throw_velocity


func get_animation_time() -> float:
  return clampf(time_held / animation_period, 0, 1)


func should_catch() -> bool:
  return super() && _catch_threshold_met()

func should_catch_on_body_enter() -> bool:
  return _catch_threshold_met()

func _catch_threshold_met() -> bool:
  var cursor_velocity = CursorMovement.velocity
  var cursor_acceleration = CursorMovement.acceleration

  return cursor_acceleration.y < -throw_acceleration_threshold \
  && cursor_acceleration.y < last_cursor_acceleration.y \
  && cursor_velocity.y < 0 \
  && throw_state == ThrowState.IDLE

func should_throw() -> bool:
  return super() && throw_state == ThrowState.THROW_PENDING
