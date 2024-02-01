extends Node

enum DeathType { DROPPED_BALL, HAZARD }

signal game_completed

var start_time_msec: int
var completion_time_msec: int

var checkpoint_times_msec: Array[int]
var checkpoint_death_counts: Array[int]
var typed_death_counts: Dictionary

var current_checkpoint: int = -1


func get_current_time_msecs() -> int:
	if completion_time_msec == 0:
		return Time.get_ticks_msec() - start_time_msec
	else:
		return completion_time_msec - start_time_msec


func on_game_start():
	start_time_msec = Time.get_ticks_msec()
	completion_time_msec = 0
	checkpoint_times_msec = []
	checkpoint_death_counts = [0]
	typed_death_counts = {DeathType.DROPPED_BALL: 0, DeathType.HAZARD: 0}
	current_checkpoint = 0
	
	
func on_game_completed():
	completion_time_msec = Time.get_ticks_msec()
	game_completed.emit()

	
func on_check_point_reached(checkpoint_index: int):
	current_checkpoint = checkpoint_index
	checkpoint_times_msec.append(Time.get_ticks_msec())
	checkpoint_death_counts.append(0)
	

func on_ball_dropped():
	_record_typed_death(DeathType.DROPPED_BALL)
	
func on_player_died():
	_record_typed_death(DeathType.HAZARD)
	
func _record_typed_death(death_type: DeathType):
	checkpoint_death_counts[current_checkpoint] += 1
	typed_death_counts[death_type] += 1
		
		
func get_checkpoint_time_msec(checkpoint_index: int) -> int:
	if checkpoint_index < checkpoint_times_msec.size():
		return checkpoint_times_msec[checkpoint_index]
	return 0

func get_checkpoint_death_count(checkpoint_index: int) -> int:
	if checkpoint_index < checkpoint_death_counts.size():
		return checkpoint_death_counts[checkpoint_index]
	return 0
	
	
func get_dropped_ball_deaths() -> int:
	return typed_death_counts[DeathType.DROPPED_BALL]
	
func get_hazard_deaths() -> int:
	return typed_death_counts[DeathType.HAZARD]
