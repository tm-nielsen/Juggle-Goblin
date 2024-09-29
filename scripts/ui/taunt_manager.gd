class_name TauntManager
extends Control

@export var event_responses_enabled := true

@export_subgroup("References")
@export var dialogue_box: Label
@export var sprite: AnimatedSprite2D

@export_subgroup("Parameters")
@export var text_display_period := 1.2
@export var base_laugh_chance := 0.05
@export var dropped_laugh_buildup := 0.1
@export var died_laugh_buildup := 0.25

@export_subgroup("Content")
@export var drop_captions: Array[String]
@export var death_captions: Array[String]
@export var success_captions: Array[String]

@export_subgroup("Sfx")
@export var laugh_sounds: Array[AudioStreamPlayer2D]

@onready var laugh_chance := base_laugh_chance
var text_lifetime: float


func _ready():
	LevelSignalBus.ball_dropped.connect(_on_ball_dropped)
	LevelSignalBus.player_died.connect(_on_player_died)
	LevelSignalBus.new_checkpoint_reached.connect(_on_checkpoint_activated)
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	StatTracker.game_completed.connect(_on_game_completed)
	dialogue_box.text = ""
	
func _process(delta):
	if text_lifetime > 0:
		text_lifetime -= delta
		if text_lifetime <= 0:
			dialogue_box.text = ""


func set_display_text(text: String):
	dialogue_box.text = text
	text_lifetime = text_display_period
	
func play_animation(animation_name: String):
	sprite.play(animation_name)


func _on_ball_dropped():
	if event_responses_enabled:
		set_display_text(drop_captions.pick_random())
		trigger_laugh_chance(dropped_laugh_buildup)
	
func _on_player_died():
	if event_responses_enabled:
		set_display_text(death_captions.pick_random())
		trigger_laugh_chance(died_laugh_buildup)
	
func trigger_laugh_chance(laugh_buildup: float):
	laugh_chance += laugh_buildup
	if randf() < laugh_chance:
		sprite.play("Laugh")
		laugh_sounds.pick_random().play()
		laugh_chance = base_laugh_chance
	else:
		sprite.play("Smirk")
	
func _on_checkpoint_activated():
	if event_responses_enabled:
		set_display_text(success_captions.pick_random())
		sprite.play("Wheeze")
		laugh_chance = base_laugh_chance
		
		
func _on_game_completed():
	event_responses_enabled = false
	hide()
	

func _on_sprite_animation_finished():
	if sprite.animation != "Idle":
		sprite.play("Idle")
