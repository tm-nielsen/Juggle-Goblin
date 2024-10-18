extends Node

@export var juggle_ball: PackedScene
@export var checkpoints: CheckpointManager
@export var spawnpoint: Node2D

var spawned_ball = false

func _process(_delta):
  if checkpoints.active_checkpoint_index >= 0 and not spawned_ball:
    var instance = juggle_ball.instantiate()
    instance.position = spawnpoint.position
    instance.rotation = spawnpoint.rotation
    add_child(instance)
    spawned_ball = true
