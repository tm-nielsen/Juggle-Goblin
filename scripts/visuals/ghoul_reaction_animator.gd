extends AnimatedSprite2D

@export var responses_enabled: bool = false

@export var base_laugh_chance: float = 0.05
@export var dropped_laugh_buildup: float = 0.1
@export var died_laugh_buildup: float = 0.25

@export_subgroup("Sfx")
@export var laugh_sounds: Array[AudioStreamPlayer2D]

@onready var laugh_chance := base_laugh_chance


func _ready():
  LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
  LevelSignalBus.player_died.connect(_on_player_died)
  LevelSignalBus.new_checkpoint_reached.connect(_on_checkpoint_reached)
  LevelSignalBus.level_completed.connect(_on_level_completed)
  animation_finished.connect(_on_animation_finished)


func trigger_laugh_chance(laugh_buildup: float):
  laugh_chance += laugh_buildup
  if randf() < laugh_chance:
    play("Laugh")
    laugh_sounds.pick_random().play()
    laugh_chance = base_laugh_chance
  else:
    play("Smirk")


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

func _on_level_completed():
  pass
  # responses_enabled = false
  # hide()


func _on_animation_finished():
  if animation != "Idle":
    play("Idle")