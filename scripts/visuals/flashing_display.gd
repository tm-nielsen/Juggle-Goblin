extends CanvasItem

@export var on_period: float = 0.6
@export var off_period: float = 0.4


func _ready():
  var flash_tween = create_tween()
  flash_tween.tween_callback(_set_colour.bind(Color.WHITE))
  flash_tween.tween_interval(on_period)
  flash_tween.tween_callback(_set_colour.bind(Color.TRANSPARENT))
  flash_tween.tween_interval(off_period)
  flash_tween.set_loops()

func _set_colour(colour: Color):
  modulate = colour