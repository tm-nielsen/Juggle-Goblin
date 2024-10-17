extends Node

enum DeathType { DROPPED_BALL, HAZARD }

var current_time: float = 0
var completion_time: float = 0
var timer_paused: bool

var level_stats: Array[LevelStats] = []
var current_level_stats: LevelStats


func _ready():
	LevelSignalBus.level_started.connect(_on_level_started)
	LevelSignalBus.level_completed.connect(_on_level_completed)
	LevelSignalBus.new_checkpoint_reached.connect(_on_checkpoint_reached)
	LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
	LevelSignalBus.player_died.connect(_on_player_died)

func _process(delta):
	if !timer_paused:
		current_time += delta


func reset():
	current_time = 0
	completion_time = 0
	timer_paused = false
	level_stats = []
	current_level_stats = null


func get_current_or_completion_time() -> float:
	if completion_time == 0:
		return current_time
	else:
		return completion_time

func get_total_death_count() -> int:
	var death_count = 0
	for stats in level_stats:
		death_count += stats.death_count
	return death_count

func get_current_level_time() -> float:
	return current_level_stats.total_time

func get_current_level_deaths() -> int:
	return current_level_stats.death_count


func _on_level_started():
	current_level_stats = LevelStats.new(current_time)
	level_stats.append(current_level_stats)
	timer_paused = false

func _on_level_completed():
	current_level_stats.notify_completed(current_time)
	timer_paused = true

func notify_game_completed():
	completion_time = current_time
	timer_paused = true


func _on_checkpoint_reached():
	current_level_stats.notify_checkpoint_reached(current_time)

func _on_ball_dropped():
	current_level_stats.record_typed_death(DeathType.DROPPED_BALL)

func _on_player_died():
	current_level_stats.record_typed_death(DeathType.HAZARD)


class LevelStats:
	var completion_time: float
	var starting_time: float

	var checkpoint_times: Array[float]
	var checkpoint_death_counts: Array[int]
	var typed_death_counts: Dictionary

	var current_checkpoint: int: get = _get_current_checkpoint
	var total_time: float: get = _get_total_time
	var death_count: int: get = _get_death_count

	func _init(current_time: float = 0):
		starting_time = current_time
		checkpoint_times = []
		checkpoint_death_counts = [0]
		typed_death_counts = {DeathType.DROPPED_BALL: 0, DeathType.HAZARD: 0}

	func notify_checkpoint_reached(time: float):
		checkpoint_times.append(time)
		checkpoint_death_counts.append(0)

	func notify_completed(time: float):
		completion_time = time

	func record_typed_death(death_type: DeathType):
		checkpoint_death_counts[current_checkpoint] += 1
		typed_death_counts[death_type] += 1

	func _get_current_checkpoint() -> int:
		return checkpoint_times.size()

	func _get_total_time() -> float:
		return completion_time - starting_time

	func _get_death_count() -> int:
		return checkpoint_death_counts.reduce(_sum)

	func _sum(n, total):
		return n + total