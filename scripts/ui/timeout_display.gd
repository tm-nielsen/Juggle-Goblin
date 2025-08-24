extends Control

@export var label: Label
@export var idle_threshold: float = 10


func _ready():
  if !Settings.timeout_enabled:
    queue_free()
  else:
    hide()

func _process(_delta):
  var idle_time = Settings.get_seconds_since_last_input()
  visible = idle_time > idle_threshold
  label.text = "Game Will Time Out In %ds" % ceil(
    Settings.timeout_period - idle_time
  )
