@tool
class_name CameraOffsetArea
extends Node2D

@export var size: Vector2
@export var offset: Vector2

@export_subgroup('debug draw')
@export var debug_fill_colour := Color(0.5, 0.8, 0.9, 0.5)
@export var debug_stroke_colour := Color.BLACK

var area_rect: Rect2: get = _get_rect
var camera: CameraController
var contains_camera: bool


func _physics_process(_delta):
  if Engine.is_editor_hint():
    queue_redraw()
  else:
    if !is_instance_valid(camera):
      camera = get_viewport().get_camera_2d()
    _process_area()

  
func _process_area():
  if !contains_camera && area_rect.has_point(camera.position):
    _on_camera_entered()
  elif contains_camera && !area_rect.has_point(camera.position - offset):
    _on_camera_exited()
    

func _on_camera_entered():
  contains_camera = true
  camera.area_offset += offset

func _on_camera_exited():
  contains_camera = false
  camera.area_offset -= offset


func _draw():
  if Engine.is_editor_hint():
    var visual_rect = Rect2(-size / 2, size)
    draw_rect(visual_rect, debug_fill_colour)
    draw_rect(visual_rect, debug_stroke_colour, false)

func _get_rect() -> Rect2:
  return Rect2(position -size / 2, size)