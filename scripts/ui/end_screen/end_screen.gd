extends Control

enum DisplayState {NAME_ENTRY, LEADERBOARD}

@export var initial_display: Control
@export var final_display: Control

@export var completion_time_label: TimeLabel
@export var name_entry_area: NameEntryArea

var display_state: DisplayState

var name_filter: NameFilter
var entered_name: String

var completion_time: float
var final_death_count: int


func _ready():
  hide()
  name_filter = NameFilter.new()
  name_entry_area.name_changed.connect(_on_name_changed)
  name_entry_area.name_confirmed.connect(_on_name_confirmed)


func start_display():
  show()
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
  initial_display.hide()
  final_display.show()