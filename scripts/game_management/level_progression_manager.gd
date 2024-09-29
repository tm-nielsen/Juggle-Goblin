class_name LevelProgressionManager
extends Node

@export var levels: Array[PackedScene]

var active_level_instance: Node
var current_level_index: int = 0


func _ready():
  LevelSignalBus.level_completed.connect(_on_level_completed)
  load_level(0)


func load_level(level_index: int):
  if level_index >= levels.size(): return
  active_level_instance = levels[level_index].instantiate()
  add_child(active_level_instance)
  current_level_index = level_index

func unload_level():
  if is_instance_valid(active_level_instance):
    active_level_instance.queue_free()


func _on_level_completed():
  unload_level()
  BallController.ball_count = 0
  load_level.call_deferred(current_level_index + 1)