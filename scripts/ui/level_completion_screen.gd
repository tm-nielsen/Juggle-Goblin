extends Node

@export_subgroup('references')
@export var ghoul_animator: AnimatedSprite2D
@export var dialogue_label: Label
@export var level_timer: TimeLabel
@export var deaths_label: Label

@export_subgroup('performance thresholds', 'death_threshold')
@export var death_threshold_perfect = 0
@export var death_threshold_good = 4

@export_subgroup('animation names', 'animations')
@export var animations_perfect: Array[String]
@export var animations_good: Array[String]
@export var animations_poor: Array[String]

@export_subgroup('dialogue', 'qoutes')
@export_multiline var qoutes_perfect: Array[String]
@export_multiline var qoutes_good: Array[String]
@export_multiline var qoutes_poor: Array[String]

var previous_animation: String
var previous_qoute: String


func _ready():
  LevelSignalBus.level_completed.connect(_on_level_completed)

func _on_level_completed():
  level_timer.seconds = StatTracker.current_time
  var death_count = StatTracker.get_current_level_deaths()
  deaths_label.text = str(death_count)
  _display_performance_feedback(death_count)


func _display_performance_feedback(death_count: int):
  if death_count <= death_threshold_perfect:
    _display_feedback(animations_perfect, qoutes_perfect)
  elif death_count <= death_threshold_good:
    _display_feedback(animations_good, qoutes_good)
  else:
    _display_feedback(animations_poor, qoutes_poor)


func _display_feedback(animations: Array[String], qoutes: Array[String]):
  var selected_animation = _pick_random_except(animations, previous_animation)
  ghoul_animator.play(selected_animation)
  previous_animation = selected_animation

  var selected_qoute = _pick_random_except(qoutes, previous_qoute)
  dialogue_label.text = qoutes.pick_random()
  previous_qoute = selected_qoute

func _pick_random_except(array: Array, last_used) -> Variant:
  if array.has(last_used) && array.size() > 1:
    array.erase(last_used)
  return array.pick_random()