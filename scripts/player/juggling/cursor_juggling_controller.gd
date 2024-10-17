class_name CursorJugglingController
extends JugglingController


@export_subgroup("Charge Parameters")
@export var charge_period := 1.0
@export var charge_rate_curve: Curve
@export var maximum_time_held := 0.5


func _ready():
  if Settings.input_mode != Settings.CURSOR_INPUT:
    queue_free()
  else:
    super()


func get_throw_velocity() -> Vector2:
  var mouse_position = get_global_mouse_position()
  var throw_direction = (mouse_position - global_position).normalized()
  var charge_strength = _get_normalized_charge_strength()
  var throw_speed = remap(charge_strength, 0, 1, throw_speed_minimum, throw_speed_maximum)
  return throw_direction * throw_speed

func _get_normalized_charge_strength() -> float:
  var t = time_held / charge_period
  return charge_rate_curve.sample(t)


func get_animation_time() -> float:
  return _get_normalized_charge_strength()


func should_catch() -> bool:
  return super() && Input.is_action_just_pressed("grab_ball")

func should_catch_on_body_entered() -> bool:
  return Input.is_action_pressed("grab_ball")

func should_throw() -> bool:
  var is_input_released = Input.is_action_just_released("grab_ball")
  return super() && (is_input_released || time_held > maximum_time_held)