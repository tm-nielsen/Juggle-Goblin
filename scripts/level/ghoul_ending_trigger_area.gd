class_name GhoulEndingTriggerArea
extends Area2D

@export var animator: AnimatedSprite2D
@export var camera_limit_offset: float = -32


func _ready():
  body_entered.connect(_on_body_entered)
  get_viewport().get_camera_2d().x_limit = global_position.x + camera_limit_offset


func _on_body_entered(body):
  if body is BallController:
    animator.play("Disappear")
    LevelSignalBus.notify_level_completed()