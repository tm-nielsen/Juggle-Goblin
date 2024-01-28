class_name GameManager
extends Node2D

enum CheckpointValidationState { INACTIVE, NEEDS_BALL_2, NEEDS_BALL_1, NEEDS_BOTH }

signal player_died
signal ball_dropped
signal ball_caught
signal checkpoint_reached

static var instance: GameManager
static var registered_switches: Array[Switch] = []

@export_subgroup("References")
@export var player: CharacterBody2D
@export var ball_1: BallController
@export var ball_2: BallController
@export var checkpoint_manager: CheckpointManager

var ball_1_checkpoint_offset: Vector2
var ball_2_checkpoint_offset: Vector2

var check_point_validation_state: CheckpointValidationState


func _ready():
	instance = self
	ball_1.dropped.connect(_on_ball_dropped)
	ball_2.dropped.connect(_on_ball_dropped)
	checkpoint_manager.new_checkpoint_entered.connect(_on_new_checkpoint_entered)
	checkpoint_manager.potential_checkpoint_exited.connect(_on_potential_checkpoint_exited)
	ball_1.caught.connect(func(): _on_ball_caught(1))
	ball_2.caught.connect(func(): _on_ball_caught(2))
	

static func register_switch(switch: Switch):
	registered_switches.append(switch)


func _on_ball_dropped():
	check_point_validation_state = CheckpointValidationState.INACTIVE
	reset_to_checkpoint()
	ball_dropped.emit()
	
static func on_player_died():
	instance._on_player_died()

func _on_player_died():
	reset_to_checkpoint()
	player_died.emit()


func reset_to_checkpoint():
	checkpoint_manager.invalidate_checkpoint()
	_reset_balls()
	_reset_player()
	for switch in registered_switches:
		switch.reset()
	
func _reset_balls():
	var checkpoint_position = checkpoint_manager.get_checkpoint_position()
	ball_1.reset_to_checkpoint(checkpoint_position)
	ball_2.reset_to_checkpoint(checkpoint_position)
	JugglingController.on_balls_reset()
	
func _reset_player():
	player.position = checkpoint_manager.get_checkpoint_position()
	player.velocity = Vector2.ZERO


func _on_new_checkpoint_entered():
	check_point_validation_state = CheckpointValidationState.NEEDS_BOTH
	
func _on_potential_checkpoint_exited():
	check_point_validation_state = CheckpointValidationState.INACTIVE
	
func _on_ball_caught(ball_index: int):
	ball_caught.emit()
	if check_point_validation_state == CheckpointValidationState.INACTIVE:
		return
		
	if check_point_validation_state == CheckpointValidationState.NEEDS_BOTH:
		check_point_validation_state = ball_index
		checkpoint_manager.half_validate_checkpoint()
	elif ball_index != check_point_validation_state:
		check_point_validation_state = CheckpointValidationState.INACTIVE
		checkpoint_manager.validate_checkpoint()
		checkpoint_reached.emit()
