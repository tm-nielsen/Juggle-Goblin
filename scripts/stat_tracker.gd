extends Node

enum DeathType { DROPPED_BALL, HAZARD }

signal game_completed

var current_time: float
var completion_time: float

var checkpoint_times: Array[float]
var checkpoint_death_counts: Array[int]
var typed_death_counts: Dictionary

var current_checkpoint: int


func _process(delta):
	current_time += delta


func on_game_start():
	current_time = 0
	completion_time = 0
	checkpoint_times = []
	checkpoint_death_counts = [0]
	typed_death_counts = {DeathType.DROPPED_BALL: 0, DeathType.HAZARD: 0}
	current_checkpoint = -1
	
	
func on_game_completed():
	completion_time = current_time
	game_completed.emit()

	
func on_check_point_reached(checkpoint_index: int):
	current_checkpoint = checkpoint_index
	checkpoint_times.append(current_time)
	checkpoint_death_counts.append(0)
	

func on_ball_dropped():
	_record_typed_death(DeathType.DROPPED_BALL)
	
func on_player_died():
	_record_typed_death(DeathType.HAZARD)
	
func _record_typed_death(death_type: DeathType):
	checkpoint_death_counts[current_checkpoint] += 1
	typed_death_counts[death_type] += 1
		
		
func get_current_or_completion_time() -> float:
	if completion_time == 0:
		return current_time
	else:
		return completion_time


func get_checkpoint_time(checkpoint_index: int) -> float:
	if checkpoint_index < checkpoint_times.size():
		return checkpoint_times[checkpoint_index]
	return 0

func get_checkpoint_death_count(checkpoint_index: int) -> int:
	if checkpoint_index < checkpoint_death_counts.size():
		return checkpoint_death_counts[checkpoint_index]
	return 0
	
	
func get_dropped_ball_deaths() -> int:
	return typed_death_counts[DeathType.DROPPED_BALL]
	
func get_hazard_deaths() -> int:
	return typed_death_counts[DeathType.HAZARD]
