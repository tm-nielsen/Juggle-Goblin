@tool
class_name StretchedBallDrawer
extends CanvasItem

@export var radius: float = 5

var draw_offset: Vector2: set = _set_draw_offset
var _last_draw_offset: Vector2

var draw_scale: float = 1: set = _set_draw_scale
var _last_draw_scale: float = 1


func update_ball(p_offset: Vector2, p_scale: float):
  draw_offset = p_offset
  draw_scale = p_scale


func _draw():
  var ball_displacement = draw_offset - _last_draw_offset
  if ball_displacement.length() < 0.5:
    draw_circle(draw_offset, radius * draw_scale, Color.WHITE)
  else:
    _draw_streched_ball(ball_displacement.normalized())


func _draw_streched_ball(ball_normal: Vector2):
  var current_ball_radius = radius * draw_scale
  var current_ball_points = _get_semicircle_points(draw_offset, current_ball_radius, ball_normal)
  var last_ball_radius = radius * _last_draw_scale
  var last_ball_points = _get_semicircle_points(_last_draw_offset, last_ball_radius, -ball_normal)
  
  var stretched_ball_points = current_ball_points
  stretched_ball_points.append_array(last_ball_points)
  draw_colored_polygon(stretched_ball_points, Color.WHITE)


func _get_semicircle_points(centre: Vector2, p_radius: float,
    normal: Vector2, point_count: int = 6) -> PackedVector2Array:
  var points = PackedVector2Array()
  var offset = (normal * p_radius).rotated(-PI / 2)
  for i in point_count:
    points.append(centre + offset)
    offset = offset.rotated(PI / point_count)
  points.append(centre + offset)
  return points


func _set_draw_offset(new_offset: Vector2):
  _last_draw_offset = draw_offset
  draw_offset = new_offset
  queue_redraw()

func _set_draw_scale(new_scale: float):
  _last_draw_scale = draw_scale
  draw_scale = new_scale
  queue_redraw()