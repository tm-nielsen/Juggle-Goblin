extends AnimatedSprite2D

enum PresenceState {ABSENT, APPEARING, PRESENT, DISAPPEARING}
const ABSENT = PresenceState.ABSENT
const APPEARING = PresenceState.APPEARING
const PRESENT = PresenceState.PRESENT
const DISAPPEARING = PresenceState.DISAPPEARING

@export var enable_responses: bool = true
@export var appear_delay: float = 2

@export_subgroup('laugh parameters')
@export var base_laugh_chance: float = 0.05
@export var dropped_laugh_buildup: float = 0.1
@export var died_laugh_buildup: float = 0.25

@export_subgroup("Sfx")
@export var laugh_sounds: Array[AudioStreamPlayer2D]

@onready var laugh_chance := base_laugh_chance

var responses_enabled: bool: get = _get_responses_enabled
var state: PresenceState = ABSENT


func _ready():
  hide()
  LevelSignalBus.level_started.connect(_on_level_started)
  LevelSignalBus.level_completed.connect(_on_level_completed)
  _on_level_started()
  LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
  LevelSignalBus.player_died.connect(_on_player_died)
  LevelSignalBus.new_checkpoint_reached.connect(_on_checkpoint_reached)
  animation_finished.connect(_on_animation_finished)


func trigger_laugh_chance(laugh_buildup: float):
  laugh_chance += laugh_buildup
  if randf() < laugh_chance:
    play("Laugh")
    laugh_sounds.pick_random().play()
    laugh_chance = base_laugh_chance
  else:
    play("Smirk")


func _on_level_started():
  var delay_tween = create_tween()
  delay_tween.tween_interval(appear_delay)
  delay_tween.tween_callback(_appear)

func _appear():
  state = APPEARING
  play('Appear')
  show()

func _on_level_completed():
  state = DISAPPEARING
  play('Disappear')


func _on_ball_dropped():
  if responses_enabled:
    trigger_laugh_chance(dropped_laugh_buildup)

func _on_player_died():
  if responses_enabled:
    trigger_laugh_chance(died_laugh_buildup)

func _on_checkpoint_reached():
  if responses_enabled:
    play("Wheeze")
    laugh_chance = base_laugh_chance


func _on_animation_finished():
  if state == APPEARING:
    state = PRESENT
  elif state == DISAPPEARING:
    state = ABSENT
    hide()
  elif animation != "Idle":
    play("Idle")


func _get_responses_enabled() -> bool:
  return enable_responses && state == PRESENT