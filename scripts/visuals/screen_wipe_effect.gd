class_name ScreenWipeEffect
extends CanvasItem

const RIGHT := 'right'
const LEFT := 'left'

@export var edge_wipe_duration: float = 0.5
@export var easing: Tween.EaseType
@export var transition: Tween.TransitionType

func _ready():
  _reset_edges()


func start_on_wipe(completion_delay: float = 0):
  _reset_edges()
  var wipe_tween = _create_eased_tween()
  wipe_tween.tween_interval(completion_delay - edge_wipe_duration)
  _tween_edge(RIGHT, wipe_tween)

func start_off_wipe():
  _tween_edge(LEFT)


func _create_eased_tween() -> Tween:
  var tween = create_tween()
  tween.set_ease(easing)
  tween.set_trans(transition)
  return tween

func _tween_edge(edge_name: String, tween: Tween = _create_eased_tween()):
  tween.tween_method(_set_edge.bind(edge_name), 0.0, 1.0, edge_wipe_duration)

func _reset_edges():
  _set_edge(0, RIGHT)
  _set_edge(0, LEFT)

func _set_edge(value: float, edge_name: String):
  material.set_shader_parameter(edge_name + '_edge', value)