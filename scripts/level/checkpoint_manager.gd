class_name CheckpointManager
extends Node2D

signal new_checkpoint_entered
signal potential_checkpoint_exited

const CHECKPOINT_INACTIVE: int = -1
const CHECKPOINT_NEEDS_ALL: int = 0

@export var player: PlayerController

@export_subgroup("Sfx")
@export var half_sound: AudioStreamPlayer2D
@export var full_sound: AudioStreamPlayer2D

var checkpoints: Array[Checkpoint]
var active_checkpoint_index := -1
var active_checkpoint_position: Vector2: get = _get_active_checkpoint_position

var potential_checkpoint_index := -1
var potential_checkpoint: Checkpoint

var check_point_validation_state := CHECKPOINT_INACTIVE


func _ready():
  LevelSignalBus.ball_dropped.connect(_trigger_reset)
  LevelSignalBus.ball_caught.connect(_on_ball_caught)
  LevelSignalBus.player_died.connect(_trigger_reset)

func _process(_delta):
  if !checkpoints:
    _get_checkpoint_references()
    print(checkpoints)

  for checkpoint in checkpoints:
    checkpoint.check_threshold(player.position)


func _get_checkpoint_references():
  checkpoints = []
  for child in get_children():
    if child is AnimatedCheckpoint:
      _add_checkpoint_reference(child)

func _add_checkpoint_reference(child: Checkpoint):
  var index = checkpoints.size()
  child.passed.connect(_on_checkpoint_passed.bind(index))
  child.exited.connect(_on_checkpoint_exited.bind(index))
  checkpoints.append(child)


func _on_ball_caught(ball_index: int):
  if check_point_validation_state == CHECKPOINT_INACTIVE:
    return
  
  var ball_flag := int(pow(2, ball_index))
  if check_point_validation_state & ball_flag:
    return

  check_point_validation_state ^= ball_flag
  if check_point_validation_state == pow(2, BallController.ball_count) - 1:
    _validate_checkpoint()
  else:
    _half_validate_checkpoint()

  
func _half_validate_checkpoint():
  if is_instance_valid(potential_checkpoint):
    potential_checkpoint.half_validate()
    half_sound.play()
  
func _validate_checkpoint():
  active_checkpoint_index = potential_checkpoint_index
  LevelSignalBus.notify_checkpoint_activated(active_checkpoint_index)
  full_sound.play()
  if is_instance_valid(potential_checkpoint):
    potential_checkpoint.validate()
    potential_checkpoint = null
  
func invalidate_checkpoint():
  potential_checkpoint_index = active_checkpoint_index
  if is_instance_valid(potential_checkpoint):
    potential_checkpoint.invalidate()
    potential_checkpoint = null


func _on_checkpoint_passed(checkpoint_index: int):
  if checkpoint_index > active_checkpoint_index && checkpoint_index > potential_checkpoint_index:
    potential_checkpoint_index = checkpoint_index
    potential_checkpoint = checkpoints[checkpoint_index]
    check_point_validation_state = CHECKPOINT_NEEDS_ALL
    new_checkpoint_entered.emit()


func _on_checkpoint_exited(checkpoint_index: int):
  if checkpoint_index == potential_checkpoint_index:
    invalidate_checkpoint()
    check_point_validation_state = CHECKPOINT_INACTIVE
    potential_checkpoint_exited.emit()


func _trigger_reset():
  invalidate_checkpoint()
  LevelSignalBus.trigger_checkpoint_reset(active_checkpoint_position)


func _get_active_checkpoint_position() -> Vector2:
  if active_checkpoint_index >= 0:
    return checkpoints[active_checkpoint_index].reset_position
  return Vector2.ZERO