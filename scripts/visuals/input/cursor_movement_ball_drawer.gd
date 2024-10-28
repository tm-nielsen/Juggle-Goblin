@tool
extends StretchedBallDrawer

@export var mouse_delta_multiplier: float = 0.02
@export var offset_multiplier: float = 2
@export var acceleration_offset_multiplier: float = 0.2
@export var acceleration_scale: float = 40
@export_range(0, 1) var minimum_scale: float = 0.1


func _ready():
  if !Engine.is_editor_hint():
    CursorMovement.cursor_moved.connect(_on_cursor_moved)


func _on_cursor_moved(velocity: Vector2, acceleration: Vector2):
  var acceleration_offset = acceleration_scale - acceleration.length()
  draw_scale =  clampf(acceleration_offset / acceleration_scale, minimum_scale, INF)
  draw_offset = velocity + acceleration * acceleration_offset_multiplier