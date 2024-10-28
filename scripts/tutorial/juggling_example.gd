extends Control

enum VisibilityState {HIDDEN, SHOWING, SHOWN, HIDING}
const HIDDEN = VisibilityState.HIDDEN
const SHOWING = VisibilityState.SHOWING
const SHOWN = VisibilityState.SHOWN
const HIDING = VisibilityState.HIDING

@export var display_delay: float = 8
@export var hide_offset := Vector2(-90, 0)
@export var final_display_checkpoint_index: int

@export var cursor_display: JugglingExampleCursorMovementDisplay

@export_subgroup('show tween', 'show')
@export var show_duration: float = 1.0
@export var show_easing := Tween.EASE_IN_OUT
@export var show_transition := Tween.TRANS_BACK

@export_subgroup('hide tween', 'hide')
@export var hide_duration: float = 0.6
@export var hide_easing := Tween.EASE_IN
@export var hide_transition := Tween.TRANS_CUBIC

@onready var starting_position := position

var show_tween: Tween
var visibility_state: VisibilityState
var timer: float

var checkpoint_index: int = 0


func _ready():
  if Settings.input_mode != Settings.TRACKBALL_INPUT:
    queue_free()
    return
  
  position = starting_position + hide_offset
  visibility_state = HIDDEN
  LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
  LevelSignalBus.new_checkpoint_reached.connect(_on_checkpoint_reached)
  _find_self_juggling_pins(self, _connect_cursor_display_signals)

func _process(delta: float):
  if visibility_state == HIDDEN:
    timer += delta


func _find_self_juggling_pins(parent: Node, method: Callable):
  for child in parent.get_children():
    if child is SelfJugglingPin:
      method.call(child)
    else:
      _find_self_juggling_pins(child, method)

func _connect_cursor_display_signals(pin: SelfJugglingPin):
  pin.caught.connect(cursor_display._on_example_pin_caught)
  pin.thrown.connect(cursor_display._on_example_pin_thrown)



func _start_show_tween():
  visibility_state = SHOWING
  show_tween = _start_position_tween(show_easing, \
      show_transition, starting_position, show_duration)
  show_tween.tween_callback(func(): visibility_state = SHOWN)

func _start_hide_tween(should_free := false):
  visibility_state = HIDING
  var hide_tween = _start_position_tween(hide_easing, \
      hide_transition, starting_position + hide_offset, hide_duration)
  hide_tween.tween_callback(queue_free if should_free else _set_hidden)

func _set_hidden():
  visibility_state = HIDDEN

func _start_position_tween(easing: Tween.EaseType, transition: Tween.TransitionType, \
    final_position: Vector2, duration: float) -> Tween:
  var position_tween = create_tween()
  position_tween.set_ease(easing)
  position_tween.set_trans(transition)
  position_tween.tween_property(self, 'position', final_position, duration)
  return position_tween


func _on_ball_dropped():
  if visibility_state == HIDDEN && timer > display_delay:
    _start_show_tween()

func _on_checkpoint_reached():
  checkpoint_index += 1
  var should_free = checkpoint_index > final_display_checkpoint_index
  match visibility_state:
    SHOWN:
      _start_hide_tween(should_free)
    SHOWING:
      show_tween.kill()
      _start_hide_tween(should_free)
    _:
      if should_free:
        queue_free()