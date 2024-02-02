class_name CheckpointStatsDisplay
extends Control

@export_subgroup("References")
@export var flag_icon: TextureRect
@export var time_label: Label
@export var deaths_label: Label

@export_subgroup("Parameters")
@export var raised_flag_icon: Texture2D
@export var unraised_flag_icon: Texture2D


func display_stats(checkpoint_index: int):
	var is_unlocked = checkpoint_index <= StatTracker.current_checkpoint
	flag_icon.texture = raised_flag_icon if is_unlocked else unraised_flag_icon
	var checkpoint_time = StatTracker.get_checkpoint_time(checkpoint_index)
	time_label.text = StatDisplay.get_clock_string(checkpoint_time)
	deaths_label.text = str(StatTracker.get_checkpoint_death_count(checkpoint_index))
