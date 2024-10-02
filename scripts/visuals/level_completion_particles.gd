extends CPUParticles2D

@export var delay: float = 1.0


func _ready():
  LevelSignalBus.level_completed.connect(_on_level_completed)

func _on_level_completed():
  var delay_tween = create_tween()
  delay_tween.tween_interval(delay)
  delay_tween.tween_callback(restart)