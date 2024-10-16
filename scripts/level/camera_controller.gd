class_name CameraController
extends Camera2D

@export var player: CharacterBody2D
@export var follow_offset := Vector2(0, -12)
@export var follow_strength := 0.1
@export var maximum_follow_speed := 10.0
@export_range(0, 1) var y_lerp := 0.2
@export var slope_offset_factor := 10.0

@export var death_pause_duration := 0.25

var area_offset: Vector2
var x_limit: float = INF

var target_position: Vector2
var tracking_enabled := true


func _ready():
	LevelSignalBus.ball_dropped.connect(_start_death_freeze)
	LevelSignalBus.player_died.connect(_start_death_freeze)

func _process(delta):
	if tracking_enabled:
		var total_offset = follow_offset + area_offset
		target_position = player.global_position + total_offset
	
	_track_horizontally(delta)
	
	if player.is_on_floor() && tracking_enabled:
		_track_vertically()


func _track_horizontally(delta):
	var displacement = target_position.x - global_position.x
	displacement *= follow_strength * delta * 60
	displacement = clampf(displacement, -maximum_follow_speed, maximum_follow_speed)
	global_position.x += displacement
	global_position.x = clampf(global_position.x, 0, x_limit)


func _track_vertically():
	var slope_offset = _get_slope_offset()
	global_position.y -= slope_offset
	global_position.y = lerp(global_position.y, target_position.y, y_lerp)
	global_position.y += slope_offset
		

func _get_slope_offset() -> float:
	var floor_normal = player.get_floor_normal()
	return slope_offset_factor * floor_normal.x
	

func _start_death_freeze():
	tracking_enabled = false
	var delay_tween = create_tween()
	delay_tween.tween_interval(death_pause_duration)
	delay_tween.tween_callback(_enable_tracking)

func _enable_tracking():
	tracking_enabled = true
	# global_position = player.global_position + follow_offset