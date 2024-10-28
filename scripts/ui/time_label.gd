@tool
class_name TimeLabel
extends Label

@export var seconds: float = 60: set = _set_seconds

func _set_seconds(value: float):
  seconds = value
  text = get_clock_string(value)

static func get_clock_string(p_seconds: float) -> String:
  var hours = floor(p_seconds / 3600)
  var minutes = floor(p_seconds / 60) - hours * 60
  var partial_seconds = p_seconds - int(p_seconds)
  p_seconds = floori(p_seconds - minutes * 60 - hours * 3600)
  
  var time_string = "%01d:%02d.%02d"
  var time_values = [minutes, p_seconds, floori(partial_seconds * 100)]
  if hours > 0:
    time_string = "%01d:%02d:%02d.%02d"
    time_values.push_front(hours)
  return time_string % time_values