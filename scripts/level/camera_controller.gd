class_name CameraController
extends Camera2D

@export var player: CharacterBody2D
@export var follow_offset := Vector2(0, -12)
@export_range(0, 1) var y_lerp := 0.2
@export var slope_offset_factor := 10.0

@export var dropped_pause_duration := 1.2
@export var death_pause_duration := 0.8

var area_offset: Vector2

var target_position: Vector2
var tracking_enabled := true


func ready():
	LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
	LevelSignalBus.player_died.connect(_on_player_died)

func _process(_delta):
	if tracking_enabled:
		var total_offset = follow_offset + area_offset
		target_position = player.global_position + total_offset
	
	global_position.x = target_position.x
	if global_position.x < 0:
		global_position.x = 0
		
	if player.is_on_floor():
		var slope_offset = _get_slope_offset()
		global_position.y -= slope_offset
		global_position.y = lerp(global_position.y, target_position.y, y_lerp)
		global_position.y += slope_offset
		

func _get_slope_offset() -> float:
	var floor_normal = player.get_floor_normal()
	return slope_offset_factor * floor_normal.x
	

func _on_ball_dropped():
	_disable_tracking_for_duration(dropped_pause_duration)

func _on_player_died():
	_disable_tracking_for_duration(death_pause_duration)
	
func _disable_tracking_for_duration(duration: float):
	tracking_enabled = false
	var delay_tween = create_tween()
	delay_tween.tween_interval(duration)
	delay_tween.tween_callback(func(): tracking_enabled = true)
