class_name DashController
extends Node

signal dash_triggered
signal directional_dash_triggered(direction: float)

enum DashState {ABLE, ACTIVE, COOLDOWN}
const ABLE := DashState.ABLE
const ACTIVE := DashState.ACTIVE
const COOLDOWN := DashState.COOLDOWN

@export var active_timer: Timer
@export var cooldown_timer: Timer

@export_subgroup('track ball')
@export var acceleration_threshold: float = 1

var is_dashing: bool: get = _get_is_dashing
var dash_state: DashState

var last_mouse_delta: Vector2
var mouse_acceleration: Vector2
var last_mouse_acceleration: Vector2


func _ready():
  active_timer.timeout.connect(_on_active_timer_timeout)
  cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func _process(_delta):
  if dash_state != ABLE: return

  if Input.is_action_just_pressed('dash'):
    _start_dash()
    dash_triggered.emit()

  elif Settings.input_mode == Settings.TRACKBALL_INPUT && _track_ball_threshold_met():
    _start_dash()
    directional_dash_triggered.emit(sign(mouse_acceleration.x))

  last_mouse_acceleration = mouse_acceleration


func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.screen_relative)

func _handle_mouse_movement(mouse_delta: Vector2):
    mouse_acceleration = mouse_delta - last_mouse_delta
    last_mouse_delta = mouse_delta


func _start_dash():
  dash_state = ACTIVE
  active_timer.start()


func _track_ball_threshold_met() -> bool:
  return abs(mouse_acceleration.x) > acceleration_threshold \
  && mouse_acceleration.y > 0 && last_mouse_delta.y > 0 \
  && abs(mouse_acceleration.x) > abs(last_mouse_acceleration.x)


func _on_active_timer_timeout():
  dash_state = COOLDOWN
  cooldown_timer.start()

func _on_cooldown_timer_timeout():
  dash_state = ABLE


func _get_is_dashing() -> bool:
  return dash_state == ACTIVE