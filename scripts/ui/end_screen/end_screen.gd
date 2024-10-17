extends Control

signal reset_triggered
signal display_bypass_triggered

enum DisplayState {HIDDEN, NAME_ENTRY, LEADERBOARD, RESET_ENABLED}
const HIDDEN = DisplayState.HIDDEN
const NAME_ENTRY = DisplayState.NAME_ENTRY
const LEADERBOARD = DisplayState.LEADERBOARD
const RESET_ENABLED = DisplayState.RESET_ENABLED

@export var initial_display: Control
@export var final_display: Control

@export var completion_time_label: TimeLabel
@export var name_entry_area: NameEntryArea

@export var reset_prompt: FlashingDisplay
@export var reset_delay: float = 3

var display_state: DisplayState

var name_filter: NameFilter
var entered_name: String

var completion_time: float
var final_death_count: int


func _ready():
  display_state = HIDDEN
  hide()
  name_filter = NameFilter.new()
  name_entry_area.name_changed.connect(_on_name_changed)
  name_entry_area.name_confirmed.connect(_on_name_confirmed)

func _process(_delta: float):
  if display_state == HIDDEN && _display_bypass_inputs_pressed():
    show()
    display_leaderboard()
    display_bypass_triggered.emit()

  if display_state == RESET_ENABLED && _reset_input_pressed():
    StatTracker.reset()
    display_state = HIDDEN
    hide()
    reset_triggered.emit()


func start_display():
  show()
  display_state = NAME_ENTRY
  initial_display.show()
  final_display.hide()

  completion_time = StatTracker.completion_time
  final_death_count = StatTracker.get_total_death_count()

  completion_time_label.seconds = completion_time
  name_entry_area.start_name_selection()


func _on_name_changed(new_name: String):
  if name_filter.test(new_name):
    name_entry_area.censor_name()

func _on_name_confirmed(confirmed_name: String):
  CompletionStatsIO.append_completion(confirmed_name, completion_time, final_death_count)
  display_leaderboard()

func display_leaderboard():
  display_state = LEADERBOARD
  initial_display.hide()
  final_display.show()
  reset_prompt.hide()
  _enable_reset_after_delay()


func _enable_reset_after_delay():
  var delay_tween = create_tween()
  delay_tween.tween_interval(reset_delay)
  delay_tween.tween_callback(_enable_reset)

func _enable_reset():
  reset_prompt.start_flashing()
  display_state = RESET_ENABLED


func _reset_input_pressed() -> bool:
  return Input.is_action_just_pressed('ui_accept')

func _display_bypass_inputs_pressed() -> bool:
  return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && \
  Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && \
  Input.is_key_pressed(KEY_3) && Input.is_key_pressed(KEY_4)