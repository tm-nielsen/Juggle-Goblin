class_name BallController
extends CharacterBody2D

enum ThrowState { FROZEN, JUST_THROWN, FREE}

static var ball_count: int

@export var gravity := 2
@export var friction := 0.01
@export var thrown_spin_multiplier := -0.1
@export var reset_offset := Vector2(5, -5)
@export var reset_rotation := 90

@export_subgroup('effect prefabs')
@export var dropped_prefab: PackedScene
@export var firework_prefab: PackedScene

@export_subgroup("Sfx")
@export var grab_sound: AudioStreamPlayer2D
@export var throw_sound: AudioStreamPlayer2D

var index: int
var angular_velocity: float
var state: ThrowState


func _ready():
	LevelSignalBus.reset_triggered.connect(_reset_to_checkpoint)
	LevelSignalBus.level_completed.connect(_on_level_completed)
	index = ball_count
	ball_count += 1


func _physics_process(delta):
	if state == ThrowState.FROZEN:
		return
	
	velocity += gravity * Vector2.DOWN
	velocity *= (1 - friction)
	
	rotation += angular_velocity * delta
	move_and_slide()
	
	if state == ThrowState.JUST_THROWN:
		if velocity.y > 0:
			state = ThrowState.FREE
	elif is_on_floor():
		LevelSignalBus.notify_ball_dropped()
			
			
func on_grabbed():
	LevelSignalBus.notify_ball_caught(index)
	state = ThrowState.FROZEN
	collision_mask = 0
	grab_sound.play()
		
func throw(p_velocity: Vector2):
	velocity = p_velocity
	angular_velocity = thrown_spin_multiplier * p_velocity.length()
	state = ThrowState.FREE if velocity.y >= 0 else ThrowState.JUST_THROWN
	collision_mask = 1
	throw_sound.play()


func _spawn_effect(effect_prefab: PackedScene):
	var effect = effect_prefab.instantiate()
	add_sibling(effect)
	effect.position = position
	

func _reset_to_checkpoint(checkpoint_position: Vector2):
	_spawn_effect(dropped_prefab)
	state = ThrowState.FROZEN
	collision_mask = 0
	position = checkpoint_position + reset_offset
	rotation_degrees = reset_rotation
	velocity = Vector2.ZERO
	angular_velocity = 0

func _on_level_completed():
	ball_count = 0
	_spawn_effect(firework_prefab)
	queue_free()