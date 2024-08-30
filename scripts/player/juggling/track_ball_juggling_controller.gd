class_name TackBallJugglingController
extends JugglingController

@export_subgroup('throw', 'throw')
@export var throw_acceleration_threshold: float = 5
@export var throw_speed_multiplier: float = 10

@export var catch_speed_threshold: float = 1

@export_subgroup('animation')
@export var animation_period: float = 1.0

var pending_throw_velocity: Vector2

var captured_mouse_position: Vector2
var previous_mouse_delta: Vector2

var throw_pending: bool


func _ready():
  super();
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  captured_mouse_position = get_viewport().get_mouse_position()


func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.relative)

func _process(_delta):
  if !super.should_throw():
    throw_pending = false
    pending_throw_velocity = Vector2.ZERO


func _handle_mouse_movement(mouse_delta: Vector2):
  var mouse_acceleration = mouse_delta - previous_mouse_delta
  previous_mouse_delta = mouse_delta

  if mouse_acceleration.y < -throw_acceleration_threshold:
    _queue_pending_throw(mouse_acceleration)

func _queue_pending_throw(input_vector: Vector2):
  throw_pending = true
  var throw_direction = input_vector.normalized()
  var throw_speed = _get_throw_speed(input_vector)
  var throw_velocity = throw_direction * throw_speed

  if throw_velocity.length_squared() > pending_throw_velocity.length_squared():
    pending_throw_velocity = throw_velocity

func _get_throw_speed(input_vector: Vector2) -> float:
  var speed = input_vector.length() * throw_speed_multiplier
  return clampf(speed, throw_speed_minimum, throw_speed_maximum)


func throw_held_ball():
  throw_pending = false
  super()

  
func get_throw_velocity() -> Vector2:
  var throw_velocity = pending_throw_velocity
  pending_throw_velocity = Vector2.ZERO
  return throw_velocity


func get_animation_time() -> float:
  return clampf(time_held / animation_period, 0, 1)


func should_catch() -> bool:
  return super() && _catch_threshold_met()

func should_catch_on_body_enter() -> bool:
  return _catch_threshold_met()

func _catch_threshold_met() -> bool:
  return previous_mouse_delta.y > -catch_speed_threshold

func should_throw() -> bool:
  return super() && throw_pending