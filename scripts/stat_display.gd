class_name StatDisplay
extends Control

@export var checkpoint_count := 15
@export var checkpoint_stat_display_prefab: PackedScene
@export var checkpoint_stat_display_parent: Control

@export var timer_label: Label
@export var dropped_ball_deaths_label: Label
@export var hazard_deaths_label: Label


func _ready():
	visibility_changed.connect(_on_visibility_changed)
	hide()


func _on_visibility_changed():
	if visible:
		timer_label.text = get_time_string(StatTracker.get_current_time_msecs())
		dropped_ball_deaths_label.text = str(StatTracker.get_dropped_ball_deaths())
		hazard_deaths_label.text = str(StatTracker.get_hazard_deaths())
	else:
		for child in checkpoint_stat_display_parent.get_children():
			child.queue_free()
	
func display_checkpoint_stats():
	for i in checkpoint_count:
		var checkpoint_stat_display = checkpoint_stat_display_prefab.instantiate()
		checkpoint_stat_display_parent.add_child(checkpoint_stat_display)
		checkpoint_stat_display.display_stats(i)
	


static func get_time_string(msecs):
	return _get_clock_text(msecs / 1000.0)
	
static func _get_clock_text(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var partial_seconds = seconds - int(seconds)
	seconds = floori(seconds - minutes * 60)
	return "%01d:%02d:%02d" % [minutes, seconds, floori(partial_seconds * 100)]
