class_name FlashingDisplay
extends CanvasItem

@export var on_period: float = 0.6
@export var off_period: float = 0.4
@export var flash_on_start: bool = false

var flash_tween: Tween


func _ready():
  hide()
  if flash_on_start:
    start_flashing()

func start_flashing():
  show()
  flash_tween = create_tween()
  flash_tween.tween_callback(_set_colour.bind(Color.WHITE))
  flash_tween.tween_interval(on_period)
  flash_tween.tween_callback(_set_colour.bind(Color.TRANSPARENT))
  flash_tween.tween_interval(off_period)
  flash_tween.set_loops()

func stop_flashing():
  flash_tween.kill()

func _set_colour(colour: Color):
  modulate = colour