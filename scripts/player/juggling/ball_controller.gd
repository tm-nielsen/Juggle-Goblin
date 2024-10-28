class_name BallController
extends CharacterBody2D

enum ThrowState { FROZEN, JUST_THROWN, FREE}

static var ball_count: int

@export var gravity := 2
@export var friction := 0.01
@export var thrown_spin_multiplier := -0.1
@export var reset_offset := Vector2(5, -5)
@export var reset_rotation := 90

@export_subgroup('respawn animation', 'respawn')
@export var respawn_delay: float = 0.5
@export var respawn_duration: float = 0.6
@export var respawn_easing := Tween.EASE_OUT
@export var respawn_transition := Tween.TRANS_ELASTIC

@export_subgroup('effect prefabs')
@export var dropped_prefab: PackedScene
@export var firework_prefab: PackedScene

@export_subgroup("Sfx")
@export var grab_sound: AudioStreamPlayer2D
@export var throw_sound: AudioStreamPlayer2D

@onready var active_collision_layer := collision_layer
var reset_tween: Tween

var index: int
var angular_velocity: float
var state: ThrowState


func _ready():
  LevelSignalBus.reset_triggered.connect(_reset_to_checkpoint)
  LevelSignalBus.level_completed.connect(_on_level_completed)
  index = ball_count
  ball_count += 1

func _exit_tree():
  ball_count -= 1


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
  _start_respawn_animation()
  state = ThrowState.FROZEN
  collision_mask = 0
  collision_layer = 0
  position = checkpoint_position + reset_offset
  rotation_degrees = reset_rotation
  velocity = Vector2.ZERO
  angular_velocity = 0

func _start_respawn_animation():
  scale = Vector2.ZERO
  if reset_tween: reset_tween.kill()
  reset_tween = _create_eased_tween(respawn_easing, respawn_transition)
  reset_tween.tween_interval(respawn_delay)
  reset_tween.tween_callback(_enable_collision)
  reset_tween.tween_property(self, 'scale', Vector2.ONE, respawn_duration)

func _create_eased_tween(easing: Tween.EaseType, transition: Tween.TransitionType) -> Tween:
  var eased_tween = create_tween()
  eased_tween.set_ease(easing)
  eased_tween.set_trans(transition)
  return eased_tween

func _enable_collision():
  collision_layer = active_collision_layer


func _on_level_completed():
  _spawn_effect(firework_prefab)
  queue_free()