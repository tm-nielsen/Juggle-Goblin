class_name NameEntryArea
extends Control

signal name_confirmed(confirmed_name: String)
signal name_changed(current_name: String)

@export var maximum_length: int = 4
@export var name_label: Label
@export var letter_button_parent: Control
@export var confirm_name_button: Control
@export var clear_name_button: Control

var default_focus_item: Button
var letter_buttons: Array[Button]

var entered_name: String
var is_selecting_name: bool

func _ready():
  _create_letter_buttons()
  confirm_name_button.pressed.connect(_on_confirm_name_button_pressed)
  clear_name_button.pressed.connect(_on_clear_name_button_pressed)
  set_buttons_disabled(true)

func _process(_delta):
  if is_visible_in_tree() && !get_viewport().gui_get_focus_owner():
    grab_default_focus()


func start_name_selection():
  is_selecting_name = true
  entered_name = ""
  name_label.text = ""
  for i in maximum_length:
    name_label.text += '-'
  _set_button_disabled_and_focus_mode(confirm_name_button, true)
  _set_button_disabled_and_focus_mode(clear_name_button, true)
  _set_letter_buttons_disabled(false)
  grab_default_focus()
  visible = true

func grab_default_focus():
  _set_letter_buttons_disabled(false)
  _focus_button(default_focus_item)


func censor_name():
  _set_button_disabled_and_focus_mode(confirm_name_button, true)
  if entered_name.length() >= maximum_length:
    _focus_button(clear_name_button)


func _focus_button(button):
  button.grab_focus()

func set_buttons_disabled(disabled := true):
  _set_button_disabled_and_focus_mode(confirm_name_button, disabled)
  _set_button_disabled_and_focus_mode(clear_name_button, disabled)
  _set_letter_buttons_disabled(disabled)

func _set_letter_buttons_disabled(disabled := true):
  for button in letter_buttons:
    _set_button_disabled_and_focus_mode(button, disabled)

func _set_button_disabled_and_focus_mode(button, disabled: bool):
  button.disabled = disabled
  button.focus_mode = FOCUS_NONE if disabled else FOCUS_ALL


func _on_letter_button_pressed(letter: String):
  entered_name += letter
  name_label.text = entered_name
  _set_button_disabled_and_focus_mode(confirm_name_button, false)
  _set_button_disabled_and_focus_mode(clear_name_button, false)

  if entered_name.length() >= maximum_length:
    _set_letter_buttons_disabled()
    _focus_button(confirm_name_button)
  name_changed.emit(entered_name)


func _on_clear_name_button_pressed():
  start_name_selection()

func _on_confirm_name_button_pressed():
  is_selecting_name = false
  name_confirmed.emit(entered_name)


func on_pause_toggled(is_paused: bool):
  if is_visible_in_tree():
    if is_paused:
      set_buttons_disabled(true)
    else:
      _set_letter_buttons_disabled(entered_name.length() >= maximum_length)
      _set_button_disabled_and_focus_mode(confirm_name_button, entered_name.is_empty())
      _set_button_disabled_and_focus_mode(clear_name_button, entered_name.is_empty())


func _create_letter_buttons():
  for child in letter_button_parent.get_children():
    child.queue_free()

  letter_buttons = []
  for i in 26:
    var new_button = _create_letter_button(i)
    letter_buttons.append(new_button)
    letter_button_parent.add_child(new_button)
  default_focus_item = letter_buttons[13]

func _create_letter_button(index: int) -> Button:
  var letter_button = Button.new()
  letter_button.theme_type_variation = "LetterButton"
  var letter = String.chr(65 + index)
  letter_button.text = letter
  letter_button.pressed.connect(_on_letter_button_pressed.bind(letter))
  return letter_button