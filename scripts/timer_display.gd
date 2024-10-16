extends Label

func _ready():
	visibility_changed.connect(_update_display)
	hide()

func _process(_delta):
	if visible:
		_update_display()

func _update_display():
	text = StatDisplay.get_timer_string()
