class_name EndingTriggerArea
extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(_body):
	StatTracker.on_game_completed()
