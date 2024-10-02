@tool
class_name TimeLabel
extends Label

@export var seconds: float = 60: set = _set_seconds

func _set_seconds(value: float):
  seconds = value
  text = get_clock_string(value)

static func get_clock_string(p_seconds: float) -> String:
  var minutes = floor(p_seconds / 60)
  var partial_seconds = p_seconds - int(p_seconds)
  p_seconds = floori(p_seconds - minutes * 60)
  return "%01d:%02d.%02d" % [minutes, p_seconds, floori(partial_seconds * 100)]