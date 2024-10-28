extends TimeLabel

func _ready():
  visibility_changed.connect(_update_display)
  hide()

func _process(_delta):
  if visible:
    _update_display()

func _update_display():
  seconds = StatTracker.get_current_or_completion_time()
