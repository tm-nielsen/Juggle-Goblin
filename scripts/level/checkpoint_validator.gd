class_name CheckpointValidator

signal validated
signal partially_validated

const INACTIVE: int = -1
const NEEDS_ALL: int = 0

var validation_state := INACTIVE


func _init():
  LevelSignalBus.ball_caught.connect(_on_ball_caught)
  LevelSignalBus.ball_dropped.connect(end_validation)
  LevelSignalBus.player_died.connect(end_validation)


func start_validation():
  validation_state = NEEDS_ALL

func end_validation():
  validation_state = INACTIVE


func _on_ball_caught(ball_index: int):
  if validation_state == INACTIVE:
    return
  
  var ball_flag := int(pow(2, ball_index))
  if validation_state & ball_flag:
    return

  validation_state ^= ball_flag
  if validation_state == pow(2, BallController.ball_count) - 1:
    validated.emit()
  else:
    partially_validated.emit()