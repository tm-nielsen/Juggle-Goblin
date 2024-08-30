class_name TackBallJugglingController
extends JugglingController

enum ThrowState {IDLE, INPUT, THROW_PENDING}

@export_subgroup('throw', 'throw')
@export var throw_acceleration_threshold: float = 5
@export var throw_speed_multiplier: float = 10
@export var throw_input_window: float = 0.05

@export var catch_speed_threshold: float = 1

@export_subgroup('animation')
@export var animation_period: float = 1.0

var pending_throw_velocity: Vector2

var captured_mouse_position: Vector2
var previous_mouse_delta: Vector2

var throw_state: ThrowState
var input_window_timer: float
var total_throw_input: Vector2


func _ready():
  super();
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  captured_mouse_position = get_viewport().get_mouse_position()


func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.relative)

func _process(delta):
  if throw_state == ThrowState.INPUT:
    input_window_timer += delta
  if !super.should_throw():
    throw_state = ThrowState.IDLE
    pending_throw_velocity = Vector2.ZERO


func _handle_mouse_movement(mouse_delta: Vector2):
  var mouse_acceleration = mouse_delta - previous_mouse_delta
  previous_mouse_delta = mouse_delta

  if throw_state == ThrowState.INPUT:
    _capture_throw_input(mouse_acceleration)
    if input_window_timer > throw_input_window:
      _end_input_window()
  elif mouse_acceleration.y < -throw_acceleration_threshold:
    _start_input_window()
    _capture_throw_input(mouse_acceleration)

func _start_input_window():
  throw_state = ThrowState.INPUT
  total_throw_input = Vector2.ZERO
  input_window_timer = 0

func _end_input_window():
  throw_state = ThrowState.THROW_PENDING
  var throw_direction = total_throw_input.normalized()
  var throw_speed = _get_throw_speed(total_throw_input)
  pending_throw_velocity = throw_direction * throw_speed

  
func _capture_throw_input(input_vector: Vector2):
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
  return previous_mouse_delta.y > -catch_speed_threshold

func should_throw() -> bool:
  return super() && throw_state == ThrowState.THROW_PENDING