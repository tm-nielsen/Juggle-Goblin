extends AnimatableBody3D

@export var offset_multiplier: float = 2
@export var rotation_multiplier: float = 1
@export var acceleration_scale: float = 40
@export_range(0, 1) var minimum_scale: float = 0.1
@export_range(0, 1) var scale_offset: float = 0.2;

var offset_step: Vector3
var rotation_step: Vector2

var target_scale: float = 1
var current_scale: float = 1

var last_mouse_delta: Vector2


func _ready():
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  Input.use_accumulated_input = false

func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.screen_relative)

    
func _physics_process(delta):
  scale = Vector3.ONE * target_scale
  position = offset_step * delta * offset_multiplier
  rotation_step *= delta
  rotate(Vector3.RIGHT, rotation_step.y)
  rotate(Vector3.FORWARD, rotation_step.x)


func _handle_mouse_movement(mouse_delta: Vector2):
  var mouse_acceleration = mouse_delta - last_mouse_delta
  last_mouse_delta = mouse_delta

  var acceleration_offset = acceleration_scale - mouse_acceleration.length()
  target_scale =  clampf(acceleration_offset / acceleration_scale, minimum_scale, INF)

  offset_step = Vector3(mouse_delta.x, 0, mouse_delta.y)
  offset_step *= 1 + target_scale * scale_offset

  rotation_step = mouse_delta * rotation_multiplier