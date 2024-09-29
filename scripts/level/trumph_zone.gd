class_name TriumphZone
extends Area2D

var validator: CheckpointValidator


func _ready():
	validator = CheckpointValidator.new()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	validator.partially_validated.connect(_on_partially_validated)
	validator.validated.connect(_on_validated)


func _on_body_entered(body):
	if body is PlayerController:
		validator.start_validation()

func _on_body_exited(body):
	if body is PlayerController:
		validator.end_validation()


func _on_partially_validated(): pass

func _on_validated():
	LevelSignalBus.notify_level_completed()