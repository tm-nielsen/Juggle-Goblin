class_name CheckpointAnimator
extends AnimatedSprite2D


func _ready():
	animation_finished.connect(_on_animation_finished)
	play("Inactive")


func display_touched():
	play("Touched")
	
func display_half_validated():
	play("Raise Half")

func display_validated():
	play("Raise Full")
	
func display_invalidated():
	play("Inactive")
	

func _on_animation_finished():
	if animation == "Raise Full":
		play("Flap")
