extends Node

signal cursor_moved(velocity: Vector2, acceleration: Vector2)

var velocity: Vector2
var acceleration: Vector2

func _input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.screen_relative)

func _handle_mouse_movement(frame_velocity: Vector2):
  frame_velocity *= Settings.mouse_sensitivity
  acceleration = frame_velocity - velocity
  velocity = frame_velocity
  cursor_moved.emit(velocity, acceleration)