class_name AnimatedCheckpoint
extends Checkpoint

@export var animator: AnimatedSprite2D


func _ready():
	animator.animation_finished.connect(_on_animation_finished)
	animator.play("Inactive")


func _display_passed():
	animator.play("Touched")
	
func _display_half_validated():
	animator.play("Raise Half")

func _display_validated():
	animator.play("Raise Full")
	
func _display_invalidated():
	animator.play("Inactive")
	

func _on_animation_finished():
	if animator.animation == "Raise Full":
		animator.play("Flap")
