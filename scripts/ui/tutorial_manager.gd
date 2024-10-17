class_name TutorialManager
extends Node

enum TutorialState { INTRO, JUGGLING, MOVING, JUMPING, DASHING, COMPLETED }

const THROWING_EXPLANATION := "Use either mouse button to catch\nand throw the juggling pins"
const MOVING_EXPLANATION := "Use A & D to Move"
const JUMPING_EXPLANATION := "Use W to Jump"
const DASHING_EXPLANATION := "Use Spacebar to Dash"

@export_subgroup("References")
@export var game_manager: GameManager
@export var taunt_manager: TauntManager
@export var tutorial_text: Label

var state: TutorialState
var dialogue_tween: Tween
var text_tween: Tween

var catch_count: int


func _ready():
  tutorial_text.text = ""
  if game_manager.checkpoint_manager.active_checkpoint_index >= 0:
    return
  
  game_manager.player.input_enabled = false
  taunt_manager.event_responses_enabled = false
  taunt_manager.set_display_text("I'm bored.")
  _set_taunt_dialogue_after_delay("Do the thing.", 1.8)
  _set_tutorial_text_after_delay(THROWING_EXPLANATION, 2.3 + taunt_manager.text_display_period)
  
  game_manager.ball_caught.connect(_on_ball_caught)
  game_manager.ball_dropped.connect(_on_ball_dropped)
  game_manager.checkpoint_reached.connect(_on_checkpoint_reached)
      

func _on_ball_caught():
  if state == TutorialState.INTRO:
    if catch_count == 0:
      catch_count += 1
    else:
      tutorial_text.text = ""
      _kill_tween(text_tween)
      taunt_manager.set_display_text("AHAHAHAHA")
      taunt_manager.play_animation("Laugh")
      _set_taunt_dialogue_after_delay("More, MORE!", 1.2)
      state = TutorialState.JUGGLING
    
  elif state == TutorialState.JUGGLING:
    catch_count += 1
    if catch_count >= 6:
      taunt_manager.set_display_text("Now go over there.")
      game_manager.player.input_enabled = true
      tutorial_text.text = ""
      _set_tutorial_text_after_delay(MOVING_EXPLANATION, taunt_manager.text_display_period)
      # make arrow do
      state = TutorialState.MOVING
      
func _on_ball_dropped():
  if state == TutorialState.JUGGLING:
    catch_count = 0
    

func _on_checkpoint_reached():
  if state == TutorialState.MOVING:
    tutorial_text.text = ""
    _kill_tween(text_tween)
    taunt_manager.set_display_text("Yes, YES!")
    taunt_manager.play_animation("Laugh")
    _set_taunt_dialogue_after_delay("Keep Going...", 1.0)
    _set_tutorial_text_after_delay(JUMPING_EXPLANATION, 1.5 + taunt_manager.text_display_period)
    state = TutorialState.JUMPING
  
  elif state == TutorialState.JUMPING:
    taunt_manager.set_display_text("")
    _kill_tween(dialogue_tween)
    tutorial_text.text = DASHING_EXPLANATION
    _kill_tween(text_tween)
    state = TutorialState.DASHING
    
  elif state == TutorialState.DASHING:
    tutorial_text.visible = false
    taunt_manager.event_responses_enabled = true
    state = TutorialState.COMPLETED

  
func _set_taunt_dialogue_after_delay(text: String, delay: float):
  _kill_tween(dialogue_tween)
  dialogue_tween = create_tween()
  dialogue_tween.tween_interval(delay)
  dialogue_tween.tween_callback(func(): taunt_manager.set_display_text(text))
  
func _set_tutorial_text_after_delay(text: String, delay):
  _kill_tween(text_tween)
  text_tween = create_tween()
  text_tween.tween_interval(delay)
  text_tween.tween_callback(func(): tutorial_text.text = text)
  
func _kill_tween(tween: Tween):
  if tween && tween.is_valid:
    tween.kill()
