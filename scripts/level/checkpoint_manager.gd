class_name CheckpointManager
extends Node2D

signal new_checkpoint_entered
signal potential_checkpoint_exited

@export var player: PlayerController

@export_subgroup("Sfx")
@export var half_sound: AudioStreamPlayer2D
@export var full_sound: AudioStreamPlayer2D

@export_subgroup('editor overrides')
@export var checkpoint_index_override: int = -1

var checkpoints: Array[Checkpoint]
var active_checkpoint_index := -1
var active_checkpoint_position: Vector2: get = _get_active_checkpoint_position

var potential_checkpoint_index := -1
var potential_checkpoint: Checkpoint

var checkpoint_validator: CheckpointValidator


func _ready():
  checkpoint_validator = CheckpointValidator.new()
  checkpoint_validator.partially_validated.connect(_on_checkpoint_partially_validated)
  checkpoint_validator.validated.connect(_on_checkpoint_validated)
  LevelSignalBus.ball_dropped.connect(_trigger_reset)
  LevelSignalBus.player_died.connect(_trigger_reset)
  if OS.has_feature("editor"):
    active_checkpoint_index = checkpoint_index_override

func _process(_delta):
  if !checkpoints:
    _get_checkpoint_references()

  for checkpoint in checkpoints:
    checkpoint.check_threshold(player.position)


func _get_checkpoint_references():
  checkpoints = []
  for child in get_children():
    if child is AnimatedCheckpoint:
      checkpoints.append(child)

  checkpoints.sort_custom(func(a, b): return a.position.x < b.position.x)
  for i in checkpoints.size():
    _connect_checkpoint_signals(checkpoints[i], i)

func _connect_checkpoint_signals(checkpoint: Checkpoint, index: int):
  checkpoint.passed.connect(_on_checkpoint_passed.bind(index))
  checkpoint.exited.connect(_on_checkpoint_exited.bind(index))

  
func _on_checkpoint_partially_validated():
  if is_instance_valid(potential_checkpoint):
    potential_checkpoint.partially_validate()
    half_sound.play()
  
func _on_checkpoint_validated():
  active_checkpoint_index = potential_checkpoint_index
  LevelSignalBus.notify_checkpoint_validated()
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
    # check_point_validation_state = CHECKPOINT_NEEDS_ALL
    checkpoint_validator.start_validation()
    new_checkpoint_entered.emit()


func _on_checkpoint_exited(checkpoint_index: int):
  if checkpoint_index == potential_checkpoint_index:
    invalidate_checkpoint()
    # check_point_validation_state = CHECKPOINT_INACTIVE
    checkpoint_validator.end_validation()
    potential_checkpoint_exited.emit()


func _trigger_reset():
  invalidate_checkpoint()
  LevelSignalBus.trigger_checkpoint_reset(active_checkpoint_position)


func _get_active_checkpoint_position() -> Vector2:
  if active_checkpoint_index >= 0:
    return checkpoints[active_checkpoint_index].reset_position
  return Vector2.ZERO
