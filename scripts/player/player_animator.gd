class_name PlayerAnimator
extends AnimatedSprite2D

signal respawn_animation_finished()

enum PlayerState { IDLE, WALKING, AIRBORNE, LANDING, CELEBRATING, RESPAWNING }
const IDLE = PlayerState.IDLE
const WALKING = PlayerState.WALKING
const AIRBORNE = PlayerState.AIRBORNE
const LANDING = PlayerState.LANDING
const CELEBRATING = PlayerState.CELEBRATING
const RESPAWNING = PlayerState.RESPAWNING

@export var player_controller: PlayerController

@export_subgroup("run animation")
@export var minimum_speed_scale := 0.75
@export var maximum_speed_scale := 1.5
@export var flip_threshold := 1

var player_state: PlayerState
var is_playing_dash_animation: bool: get = _get_is_playing_dash_animation
var level_completed: bool


func _ready():
  animation_finished.connect(_on_animation_finished)
  animation_changed.connect(_on_animation_changed)
  player_controller.dashed.connect(_on_player_dashed)
  LevelSignalBus.level_completed.connect(_on_level_completed)
  LevelSignalBus.reset_triggered.connect(_on_reset_triggered)


func _physics_process(_delta):
  if level_completed || player_state == RESPAWNING: return
  _flip_horizontally()

  if player_state == AIRBORNE:
    if player_controller.is_on_floor():
      player_state = LANDING
      play("Land")
  else:
    _process_ground_animation()
    if Input.is_action_just_pressed("jump"):
      player_state = AIRBORNE
      play("Jump")


func _flip_horizontally():
  if player_controller.velocity.x > flip_threshold:
    flip_h = false
  elif player_controller.velocity.x < -flip_threshold:
    flip_h = true

func _process_ground_animation():
  var input_direction = Input.get_axis("left", "right")
  if player_state == IDLE:
    if input_direction != 0:
      player_state = WALKING
      play("Walk")
  
  if player_state == WALKING:
    if input_direction == 0:
      _reset_to_idle()
    elif !is_playing_dash_animation:
      _scale_walk_animation_speed()

func _scale_walk_animation_speed():
  var horizontal_speed = abs(player_controller.velocity.x)
  var speed_ratio = horizontal_speed / player_controller.maximum_speed
  speed_scale = remap(speed_ratio, 0, 1, minimum_speed_scale, maximum_speed_scale)


func _reset_to_idle():
  player_state = IDLE
  play("Idle")
  
  
func _on_player_dashed():
  play("Dash")


func _on_reset_triggered(_position):
  player_state = RESPAWNING
  flip_h = false
  play("Spawn")
  frame = 0


func _on_level_completed():
  level_completed = true
  player_state = CELEBRATING
  play("Celebrate")


func _on_animation_finished():
  if player_state == RESPAWNING:
    respawn_animation_finished.emit()
    _reset_to_idle()
  if player_state == LANDING || player_state == CELEBRATING:
    _reset_to_idle()
  if is_playing_dash_animation:
    if player_state == AIRBORNE:
      play("Jump")
      frame = 2
    else:
      _reset_to_idle()

func _on_animation_changed():
  if player_state != WALKING:
    speed_scale = 1.0


func _get_is_playing_dash_animation() -> bool:
  return animation == 'Dash'