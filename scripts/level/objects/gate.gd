class_name Gate
extends StaticBody2D

@export var sprite: AnimatedSprite2D


func reset():
  sprite.play("Reset")
  collision_layer = 1
  
func open():
  sprite.play("Open")
  collision_layer = 0
