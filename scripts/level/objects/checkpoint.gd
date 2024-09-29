class_name Checkpoint
extends Node2D

signal passed
signal exited

enum CheckpointState {INACTIVE, PASSED, PARTIALLY_VALIDATED, VALIDATED}

@export var pass_threshold_offset: float = -8
@export var reset_offset: Vector2

var reset_position: get = _get_reset_position
var state: CheckpointState

func check_threshold(player_position: Vector2):
  if state == CheckpointState.VALIDATED:
    return
  var threshold = global_position.x + pass_threshold_offset
  var threshold_reached = player_position.x > threshold
  if threshold_reached && state == CheckpointState.INACTIVE:
    state = CheckpointState.PASSED
    _display_passed()
    passed.emit()
  elif !threshold_reached && state != CheckpointState.INACTIVE:
    invalidate()
    exited.emit()


func _display_passed(): pass

func partially_validate():
  _update_state(CheckpointState.PARTIALLY_VALIDATED, _display_partially_validated)
func _display_partially_validated(): pass

func validate():
  _update_state(CheckpointState.VALIDATED, _display_validated)
func _display_validated(): pass

func invalidate():
  _update_state(CheckpointState.INACTIVE, _display_invalidated)
func _display_invalidated(): pass


func _update_state(new_state: CheckpointState, display_function: Callable):
  if state != new_state:
    state = new_state
    display_function.call()

func _get_reset_position() -> Vector2:
  return global_position + reset_offset