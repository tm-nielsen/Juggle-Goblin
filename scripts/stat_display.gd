class_name StatDisplay
extends Control

@export var checkpoint_stat_display_prefab: PackedScene
@export var checkpoint_stat_display_parent: Control

@export var timer_label: Label
@export var dropped_ball_deaths_label: Label
@export var hazard_deaths_label: Label
@export var close_button: Button
@export var music_slider: Slider


func _ready():
	visibility_changed.connect(_on_visibility_changed)
	clear_checkpoint_stats()
	hide()


func _on_visibility_changed():
	if visible: 
		InputMap.erase_action("ui_left")
		InputMap.erase_action("ui_right")
		InputMap.erase_action("ui_up")
		InputMap.erase_action("ui_down")
		close_button.grab_focus()
		timer_label.text = StatDisplay.get_timer_string()
		dropped_ball_deaths_label.text = str(StatTracker.get_dropped_ball_deaths())
		hazard_deaths_label.text = str(StatTracker.get_hazard_deaths())
		display_checkpoint_stats()
	else:
		music_slider.grab_focus()
		InputMap.load_from_project_settings()
		clear_checkpoint_stats()
	
func display_checkpoint_stats():
	for i in GameManager.checkpoint_count:
		var checkpoint_stat_display = checkpoint_stat_display_prefab.instantiate()
		checkpoint_stat_display_parent.add_child(checkpoint_stat_display)
		checkpoint_stat_display.display_stats(i)
	
func clear_checkpoint_stats():
		for child in checkpoint_stat_display_parent.get_children():
			child.queue_free()


static func get_timer_string() -> String:
	return get_clock_string(StatTracker.get_current_or_completion_time())
	
static func get_clock_string(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var partial_seconds = seconds - int(seconds)
	seconds = floori(seconds - minutes * 60)
	return "%01d:%02d:%02d" % [minutes, seconds, floori(partial_seconds * 100)]
