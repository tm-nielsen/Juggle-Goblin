class_name BallReflector
extends Area2D

@export var bounce_multiplier := 1.5


func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is BallController:
		var reflection_normal = Vector2.UP.rotated(rotation)
		var normal_component = body.velocity.project(reflection_normal)
		var tangent_component = body.velocity - normal_component
		var reflected_velocity = tangent_component - normal_component
		body.velocity = reflected_velocity * bounce_multiplier
