extends Node2D

@export var player: PlayerController
@export var ball_dropped_corpse: PackedScene
@export var player_died_corpse: PackedScene


func _ready():
  LevelSignalBus.ball_dropped.connect(_spawn_corpse.bind(ball_dropped_corpse))
  LevelSignalBus.player_died.connect(_spawn_corpse.bind(player_died_corpse))

func _spawn_corpse(corpse_prefab: PackedScene):
  var new_corpse: Corpse = corpse_prefab.instantiate()
  add_child.call_deferred(new_corpse)
  new_corpse.global_position = player.global_position
  new_corpse.launch_body(player.velocity)