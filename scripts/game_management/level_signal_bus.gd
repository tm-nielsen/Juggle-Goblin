extends Node

signal ball_dropped
signal ball_caught(ball_index: int)
signal player_died()
signal checkpoint_activated(index: int)
signal reset_triggered(position: Vector2)


func notify_ball_dropped():
  ball_dropped.emit()

func notify_ball_caught(ball_index: int):
  ball_caught.emit(ball_index)

func notify_player_died():
  player_died.emit()


func notify_checkpoint_activated(index: int):
  checkpoint_activated.emit(index)

func trigger_checkpoint_reset(position: Vector2):
  reset_triggered.emit(position)