class_name Switch
extends BallReflector

@export var wired_body: StaticBody2D
@export var sprite: AnimatedSprite2D


func _ready():
	super()
	GameManager.register_switch(self)

func reset():
	sprite.play("Idle")
	if wired_body:
		wired_body.visible = true
		wired_body.collision_layer = 1

func _on_body_entered(body):
	super(body)
	if body is BallController:
		sprite.play("Flip")
		if wired_body:
			wired_body.visible = false
			wired_body.collision_layer = 0
