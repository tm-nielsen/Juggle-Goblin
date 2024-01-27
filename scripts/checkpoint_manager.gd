class_name CheckpointManager
extends Node

signal new_checkpoint_entered
signal potential_checkpoint_exited

@export var checkpoints: Array[Area2D]
@export var player: CharacterBody2D

var potential_checkpoint_index := -1
var active_checkpoint_index := -1


func _ready():
	for i in checkpoints.size():
		checkpoints[i].body_entered.connect(func(_body): _on_checkpoint_entered(i))
		checkpoints[i].body_exited.connect(func(_body): _on_checkpoint_exited(i))
	

func get_checkpoint_position() -> Vector2:
	if active_checkpoint_index >= 0:
		return checkpoints[active_checkpoint_index].global_position
	return Vector2.ZERO
	
func validate_checkpoint():
	active_checkpoint_index = potential_checkpoint_index
	
func invalidate_checkpoint():
	potential_checkpoint_index = active_checkpoint_index

func _on_checkpoint_entered(checkpoint_index: int):
	if checkpoint_index > active_checkpoint_index && checkpoint_index > potential_checkpoint_index:
		potential_checkpoint_index = checkpoint_index
		new_checkpoint_entered.emit()
		
func _on_checkpoint_exited(checkpoint_index: int):
	if checkpoint_index == potential_checkpoint_index:
		potential_checkpoint_index = active_checkpoint_index
		potential_checkpoint_exited.emit()
