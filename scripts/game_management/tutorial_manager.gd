extends Node

@export var juggle_ball: PackedScene
@export var checkpoints: CheckpointManager
@export var ball_spawn_index: int
@export var spawnpoint: Node2D

var spawned_ball = false

func _process(_delta):
  if checkpoints.active_checkpoint_index >= ball_spawn_index and not spawned_ball:
    var instance = juggle_ball.instantiate()
    instance.position = spawnpoint.position
    instance.rotation = spawnpoint.rotation
    add_child(instance)
    spawned_ball = true
