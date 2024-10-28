extends Node

func _ready():
  if Settings.input_mode != Settings.TRACKBALL_INPUT:
    queue_free()