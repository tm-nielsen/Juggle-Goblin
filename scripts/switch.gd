class_name Switch
extends BallReflector

@export var connected_gate: Gate
@export var bounce_disabled_when_on := true
@export var sprite: AnimatedSprite2D

var is_toggled: bool


func _ready():
	super()
	GameManager.register_switch(self)

func reset():
	is_toggled = false
	sprite.play("Idle")
	if connected_gate:
		connected_gate.reset()

func _on_body_entered(body):
	if is_toggled && bounce_disabled_when_on:
		return
	super(body)
	if body is BallController:
		is_toggled = true
		sprite.play("Flip")
		if connected_gate:
			connected_gate.open()
