@tool
extends CanvasItem

@export var mouse_delta_multiplier: float = 0.02
@export var offset_multiplier: float = 2
@export var acceleration_offset_multiplier: float = 0.2
@export var acceleration_scale: float = 40
@export_range(0, 1) var minimum_scale: float = 0.1

@export var radius: float = 20
@export var ball_radius: float = 5
@export var stroke_width: float = 2
@export var guide_stroke_width: float = 1

var ball_offset: Vector2
var last_ball_offset: Vector2

var ball_scale: float
var last_ball_scale: float

var last_mouse_delta: Vector2


func _ready():
  if !Engine.is_editor_hint():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    Input.use_accumulated_input = false

func _unhandled_input(event: InputEvent):
  if event is InputEventMouseMotion:
    _handle_mouse_movement(event.screen_relative)


func _handle_mouse_movement(mouse_delta: Vector2):
  mouse_delta *= mouse_delta_multiplier
  var mouse_acceleration = mouse_delta - last_mouse_delta
  last_mouse_delta = mouse_delta
  last_ball_offset = ball_offset
  last_ball_scale = ball_scale

  var acceleration_offset = acceleration_scale - mouse_acceleration.length()
  ball_scale =  clampf(acceleration_offset / acceleration_scale, minimum_scale, INF)
  ball_offset = mouse_delta + mouse_acceleration * acceleration_offset_multiplier

  queue_redraw()


func _draw():
  draw_circle(Vector2.ZERO, radius, Color.WHITE, false, stroke_width)
  draw_dashed_line(Vector2.LEFT * radius, Vector2.RIGHT * radius, Color.WHITE, guide_stroke_width)

  var ball_displacement = ball_offset - last_ball_offset
  if ball_displacement.length() < 0.5:
    draw_circle(ball_offset, ball_radius, Color.WHITE)
  else:
    _draw_streched_ball(ball_displacement.normalized())


func _draw_streched_ball(ball_normal: Vector2):
  var current_ball_radius = ball_radius * ball_scale
  var current_ball_points = _get_semicircle_points(ball_offset, current_ball_radius, ball_normal)
  var last_ball_radius = ball_radius * last_ball_scale
  var last_ball_points = _get_semicircle_points(last_ball_offset, last_ball_radius, -ball_normal)
  
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