extends Control

enum DisplayState {NAME_ENTRY, LEADERBOARD}

@export var initial_display: Control
@export var final_display: Control

@export var completion_time_label: TimeLabel
@export var name_entry_area: NameEntryArea

var completion_time: float
var final_death_count: int
var entered_name: String

var name_filter: NameFilter
var display_state: DisplayState


func _ready():
  hide()
  name_filter = NameFilter.new()
  name_entry_area.name_changed.connect(_on_name_changed)
  name_entry_area.name_confirmed.connect(_on_name_confirmed)
  start_display()


func start_display():
  show()
  initial_display.show()
  final_display.hide()

  completion_time_label.seconds = completion_time
  name_entry_area.start_name_selection()


func _on_name_changed(new_name: String):
  if name_filter.test(new_name):
    name_entry_area.censor_name()

func _on_name_confirmed(confirmed_name: String):
  CompletionStatsIO.append_completion(confirmed_name, completion_time, final_death_count)
  initial_display.hide()
  final_display.show()