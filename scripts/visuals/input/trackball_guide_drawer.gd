@tool
extends CanvasItem

const WHITE = Color.WHITE
const CENTRE = Vector2.ZERO

@export var radius: float = 20
@export var stroke_width: float = 2


func _draw():
  draw_circle(Vector2.ZERO, radius, WHITE, false, stroke_width)
  draw_dashed_arc(radius / 2, -PI, 0, 6)

  var left = Vector2.LEFT * radius
  var right = Vector2.RIGHT * radius
  var bottom = Vector2.DOWN * radius

  draw_line(left, left / 2, WHITE, stroke_width)
  draw_dashed_line(left / 2, bottom.rotated(PI / 8), WHITE, stroke_width)

  draw_line(right, right / 2, WHITE, stroke_width)
  draw_dashed_line(right / 2, bottom.rotated(-PI / 8), WHITE, stroke_width)


func draw_dashed_arc(p_radius, start_angle: float, end_angle: float, point_count: int = 4):
  var points = PackedVector2Array()
  var arm = p_radius * Vector2.RIGHT.rotated(start_angle)
  var angle_step = (end_angle - start_angle) / (point_count - 1)
  for i in (point_count - 1):
    points.append(arm)
    arm = arm.rotated(angle_step)
  points.append(arm)
  draw_dashed_polyline(points)


func draw_dashed_polyline(points: PackedVector2Array):
  for i in range(1, points.size()):
    draw_dashed_line(points[i - 1], points[i], WHITE, stroke_width)