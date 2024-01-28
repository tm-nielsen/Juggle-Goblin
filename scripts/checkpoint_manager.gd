class_name CheckpointManager
extends Node

signal new_checkpoint_entered
signal potential_checkpoint_exited

@export var checkpoints: Array[Area2D]
@export var player: CharacterBody2D
@export var active_checkpoint_index := -1

var potential_checkpoint_index := -1
var potential_checkpoint_animator: CheckpointAnimator


func _ready():
	for i in checkpoints.size():
		checkpoints[i].body_entered.connect(func(_body): _on_checkpoint_entered(i))
		checkpoints[i].body_exited.connect(func(_body): _on_checkpoint_exited(i))
	

func get_checkpoint_position() -> Vector2:
	if active_checkpoint_index >= 0:
		return checkpoints[active_checkpoint_index].global_position
	return Vector2.ZERO
	
func half_validate_checkpoint():
	if is_instance_valid(potential_checkpoint_animator):
		potential_checkpoint_animator.display_half_validated()
	
func validate_checkpoint():
	active_checkpoint_index = potential_checkpoint_index
	if is_instance_valid(potential_checkpoint_animator):
		potential_checkpoint_animator.display_validated()
		potential_checkpoint_animator = null
	
func invalidate_checkpoint():
	potential_checkpoint_index = active_checkpoint_index
	if is_instance_valid(potential_checkpoint_animator):
		potential_checkpoint_animator.display_invalidated()
		potential_checkpoint_animator = null

func _on_checkpoint_entered(checkpoint_index: int):
	if checkpoint_index > active_checkpoint_index && checkpoint_index > potential_checkpoint_index:
		potential_checkpoint_index = checkpoint_index
		potential_checkpoint_animator = _get_checkpoint_animator(checkpoint_index)
		if is_instance_valid(potential_checkpoint_animator):
			potential_checkpoint_animator.display_touched()
		new_checkpoint_entered.emit()
		
func _get_checkpoint_animator(checkpoint_index: int) -> CheckpointAnimator:
	var checkpoint_node = checkpoints[checkpoint_index]
	for child in checkpoint_node.get_children():
		if child is CheckpointAnimator:
			return child
	return null


func _on_checkpoint_exited(checkpoint_index: int):
	if checkpoint_index == potential_checkpoint_index:
		invalidate_checkpoint()
		potential_checkpoint_exited.emit()
