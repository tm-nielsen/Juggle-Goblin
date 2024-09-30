class_name DashController
extends Node

enum DashState {ABLE, ACTIVE, COOLDOWN}
const ABLE := DashState.ABLE
const ACTIVE := DashState.ACTIVE
const COOLDOWN := DashState.COOLDOWN

@export var active_timer: Timer
@export var cooldown_timer: Timer

var should_dash: bool: get = _get_should_dash
var is_dashing: bool: get = _get_is_dashing
var dash_state: DashState


func _ready():
  active_timer.timeout.connect(_on_active_timer_timeout)
  cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func start_dash():
  dash_state = ACTIVE
  active_timer.start()


func _on_active_timer_timeout():
  dash_state = COOLDOWN
  cooldown_timer.start()

func _on_cooldown_timer_timeout():
  dash_state = ABLE


func _get_should_dash() -> bool:
  if dash_state != ABLE: return false
  return Input.is_action_just_pressed('dash')

func _get_is_dashing() -> bool:
  return dash_state == ACTIVE