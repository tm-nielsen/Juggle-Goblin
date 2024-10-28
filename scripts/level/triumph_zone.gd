class_name TriumphZone
extends Area2D

@export var animator: AnimationPlayer
@export var landing_zone: Area2D

@export_subgroup('sounds')
@export var landed_sound: AudioStreamPlayer2D
@export var half_validated_sound: AudioStreamPlayer2D
@export var validated_sound: AudioStreamPlayer2D

var validator: CheckpointValidator
var is_validated: bool


func _ready():
  validator = CheckpointValidator.new()
  body_entered.connect(_on_body_entered)
  body_exited.connect(_on_body_exited)
  landing_zone.body_entered.connect(_on_body_entered_landing_zone)
  validator.partially_validated.connect(_on_partially_validated)
  validator.validated.connect(_on_validated)
  animator.play('RESET')
  _set_camera_limit()

func _set_camera_limit():
  var level_camera = get_viewport().get_camera_2d()
  if global_position.x > level_camera.x_limit:
    level_camera.x_limit = global_position.x


func _on_body_entered(body):
  if body is PlayerController:
    validator.start_validation()

func _on_body_exited(body):
  if body is PlayerController && !is_validated:
    validator.end_validation()
    animator.play('RESET')


func _on_body_entered_landing_zone(body):
  if body is PlayerController && validator.validation_state <= CheckpointValidator.NEEDS_ALL:
    animator.play('bounce')
    body.position.y += 2
    if landed_sound: landed_sound.play()


func _on_partially_validated():
  animator.play('turn')
  if half_validated_sound: half_validated_sound.play()

func _on_validated():
  is_validated = true
  animator.play('spin')
  if validated_sound: validated_sound.play()
  LevelSignalBus.notify_level_completed()