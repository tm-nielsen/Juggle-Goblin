@tool
class_name JugglingExampleCursorMovementDisplay
extends StretchedBallDrawer

@export var reset_interpolation: float = 0.1

@export_subgroup('throw_tween', 'throw')
@export var throw_offset: float = 8
@export var throw_duration: float = 0.2
@export var throw_easing := Tween.EASE_OUT
@export var throw_transition := Tween.TRANS_BACK

var throw_tween: Tween


func _physics_process(delta: float):
  if !(throw_tween && throw_tween.is_running()):
    draw_offset = lerp(draw_offset, Vector2.ZERO, reset_interpolation * delta * 60)


func _on_example_pin_caught():
  throw_tween = create_tween()
  throw_tween.set_ease(throw_easing)
  throw_tween.set_trans(throw_transition)
  throw_tween.tween_property(self, "draw_offset", Vector2.UP * throw_offset, throw_duration)

func _on_example_pin_thrown():
  pass