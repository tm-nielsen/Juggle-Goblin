extends Control

@export var cursor_speed_hide_threshold: float = 2
@export var threshold_met_colour: Color
@export var threshold_met_sound: AudioStreamPlayer

@export_subgroup('fade_tween', 'fade')
@export var fade_delay: float = 1
@export var fade_duration: float = 0.5
@export var fade_easing: Tween.EaseType
@export var fade_transition: Tween.TransitionType

var threshold_met: bool


func _ready():
  if Settings.input_mode == Settings.TRACKBALL_INPUT:
    get_tree().paused = true
    CursorMovement.cursor_moved.connect(_on_cursor_moved)
  else:
    queue_free()


func _on_cursor_moved(velocity: Vector2, _acceleration: Vector2):
  if threshold_met:
    return
  if velocity.length() > cursor_speed_hide_threshold:
    threshold_met = true
    modulate = threshold_met_colour
    threshold_met_sound.play()
    _start_fade_tween()

func _start_fade_tween():
  var fade_tween = create_tween()
  fade_tween.tween_interval(fade_delay)
  fade_tween.tween_callback(_unpause)
  fade_tween.set_ease(fade_easing)
  fade_tween.set_trans(fade_transition)
  fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
  fade_tween.tween_callback(queue_free)

func _unpause():
  get_tree().paused = false