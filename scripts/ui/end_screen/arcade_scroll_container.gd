extends ScrollContainer

@export var trackball_sensitivity: float = 2
@export var joystick_scroll_speed: float = 5


func _ready():
  visibility_changed.connect(_on_visibility_changed)
  if Settings.input_mode == Settings.TRACKBALL_INPUT:
    CursorMovement.cursor_moved.connect(_on_cursor_moved)

func _process(_delta: float):
  if !visible: return
  var vertical_input = Input.get_axis("ui_up", "ui_down")
  scroll_vertical += floor(vertical_input * joystick_scroll_speed)


func _on_visibility_changed():
  scroll_vertical = 0

func _on_cursor_moved(velocity: Vector2, _acceleration: Vector2):
  if !visible: return
  scroll_vertical += floor(velocity.y * trackball_sensitivity)