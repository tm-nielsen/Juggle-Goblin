extends AudioStreamPlayer

func _ready():
	finished.connect(_on_playback_finished)
	
func _on_playback_finished():
	play()
