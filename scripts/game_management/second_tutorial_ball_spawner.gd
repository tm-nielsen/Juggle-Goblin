extends Node2D

@export var juggling_ball_prefab: PackedScene
@export var checkpoint_spawn_index: int
@export var spawn_velocity := Vector2(10, -120)
@export var checkpoint_manager: CheckpointManager
@export var second_ball_label: RichTextLabel

var second_ball: BallController


func _ready():
  checkpoint_manager.new_checkpoint_entered.connect(_on_potential_checkpoint_entered)
  LevelSignalBus.reset_triggered.connect(_on_reset_triggered)
  second_ball_label.hide()

func _on_potential_checkpoint_entered():
  if _is_active_checkpoint_relevant() && !second_ball:
    _spawn_second_ball()
    second_ball_label.show()

func _spawn_second_ball():
  second_ball = juggling_ball_prefab.instantiate()
  add_sibling(second_ball)
  second_ball.position = position
  second_ball.rotation = rotation
  second_ball.throw(spawn_velocity)


func _on_reset_triggered(_reset_position):
  if _is_active_checkpoint_relevant() && second_ball:
    second_ball.queue_free()
    second_ball = null
    second_ball_label.hide()

func _is_active_checkpoint_relevant():
  return checkpoint_manager.active_checkpoint_index == checkpoint_spawn_index - 1