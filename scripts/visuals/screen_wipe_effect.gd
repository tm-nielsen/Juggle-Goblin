class_name ScreenWipeEffect
extends CanvasItem

const RIGHT := 'right'
const LEFT := 'left'

@export var covered_duration: float = 0.25
@export var edge_wipe_duration: float = 0.5
@export var easing: Tween.EaseType
@export var transition: Tween.TransitionType

func _ready():
  _reset_edges()

func start_wipe(seconds_until_covered: float):
  _reset_edges()
  var wipe_tween = create_tween()
  wipe_tween.set_ease(easing)
  wipe_tween.set_trans(transition)
  wipe_tween.tween_interval(seconds_until_covered - edge_wipe_duration)
  wipe_tween.tween_method(_set_edge.bind(RIGHT), 0.0, 1.0, edge_wipe_duration)
  wipe_tween.tween_interval(covered_duration)
  wipe_tween.tween_method(_set_edge.bind(LEFT), 0.0, 1.0, edge_wipe_duration)

func _reset_edges():
  _set_edge(0, RIGHT)
  _set_edge(0, LEFT)

func _set_edge(value: float, edge_name: String):
  material.set_shader_parameter(edge_name + '_edge', value)