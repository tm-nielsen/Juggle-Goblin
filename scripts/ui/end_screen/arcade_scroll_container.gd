extends ScrollContainer

@export var trackball_sensitivity: float = 2
@export var joystick_scroll_speed: float = 5


func _ready():
  if Settings.input_mode == Settings.TRACKBALL_INPUT:
    CursorMovement.cursor_moved.connect(_on_cursor_moved)

func _process(_delta: float):
  var vertical_input = Input.get_axis("ui_up", "ui_down")
  scroll_vertical += floor(vertical_input * joystick_scroll_speed)


func _on_cursor_moved(velocity: Vector2, _acceleration: Vector2):
  scroll_vertical += floor(velocity.y * trackball_sensitivity)