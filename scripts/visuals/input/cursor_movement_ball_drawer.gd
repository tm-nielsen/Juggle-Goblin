@tool
extends StretchedBallDrawer

@export var mouse_delta_multiplier: float = 0.02
@export var offset_multiplier: float = 2
@export var acceleration_offset_multiplier: float = 0.2
@export var acceleration_scale: float = 40
@export_range(0, 1) var minimum_scale: float = 0.1

var last_mouse_delta: Vector2


func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.screen_relative)


func _handle_mouse_movement(mouse_delta: Vector2):
  mouse_delta *= mouse_delta_multiplier
  var mouse_acceleration = mouse_delta - last_mouse_delta
  last_mouse_delta = mouse_delta

  var acceleration_offset = acceleration_scale - mouse_acceleration.length()
  draw_scale =  clampf(acceleration_offset / acceleration_scale, minimum_scale, INF)
  draw_offset = mouse_delta + mouse_acceleration * acceleration_offset_multiplier