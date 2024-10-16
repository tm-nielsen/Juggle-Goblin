class_name Leaderboard
extends Control

@export var entry_prefab: PackedScene


func _ready():
  visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
  if visible:
    _show_entries()

func _show_entries():
  for child in get_children():
    child.queue_free()

  var completion_stats = CompletionStatsIO.get_completions()
  for entry in completion_stats:
    var new_entry = entry_prefab.instantiate()
    new_entry.set_attributes(entry.name, entry.game_time)
    add_child(new_entry)