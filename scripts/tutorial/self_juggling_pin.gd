class_name SelfJugglingPin
extends Node2D

signal caught
signal thrown

@export_subgroup('movement')
@export var gravity: float = 2
@export var friction: float = 0.01
@export var throw_velocity: float = 100
@export var thrown_spin_multiplier: float = 0.1

@export_subgroup('juggling')
@export var initial_throw_delay: float = 0
@export var juggle_threshold: float = 16
@export var hold_duration: float = 0.1
@export var hold_rotation: float = 0

var velocity: Vector2
var angular_velocity: float

var held: bool


func _ready():
  rotation = hold_rotation
  position.y = juggle_threshold
  held = true
  _throw_after_delay(initial_throw_delay)

func _physics_process(delta: float):
  if !held:
    _process_movement(delta)
    if position.y > juggle_threshold:
      _catch()


func _process_movement(delta: float):
  velocity += gravity * Vector2.DOWN
  velocity *= (1 - friction)
  position += velocity * delta
	
  rotation += angular_velocity * delta

func _catch():
  held = true
  position.y = juggle_threshold
  rotation = hold_rotation
  caught.emit()
  _throw_after_delay(hold_duration)


func _throw_after_delay(delay: float):
  var throw_tween = create_tween()
  throw_tween.tween_interval(delay)
  throw_tween.tween_callback(_throw)

func _throw():
  held = false
  velocity = Vector2.UP * throw_velocity
  angular_velocity = throw_velocity * thrown_spin_multiplier
  thrown.emit()