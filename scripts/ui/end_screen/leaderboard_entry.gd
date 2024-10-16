class_name LeaderboardEntry
extends Control

@export var name_label: Label
@export var time_label: TimeLabel

var time: float


func set_attributes(saved_name: String, saved_time: float):
  name_label.text = saved_name
  time = saved_time
  time_label.seconds = time