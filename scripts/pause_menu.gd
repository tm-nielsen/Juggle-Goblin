extends Control

@export_subgroup("References")
@export var music_slider: Slider
@export var sfx_slider: Slider
@export var fullscreen_button: Button
@export var quit_button: Button
@export var stats_button: Button
@export var slider_amount: float
@export var slider_timer: Timer

var music_bus_index: int
var sfx_bus_index: int


func _ready():
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("Sfx")
	music_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music_bus_index)))
	sfx_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index)))
	
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	visible = false


func _process(_delta):
	_kb_gamepad_control()
	
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen_button.button_pressed = !fullscreen_button.button_pressed
		_toggle_fullscreen(fullscreen_button.button_pressed)
		
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()
		

func _kb_gamepad_control():
	if (Input.is_action_just_pressed("up") || Input.is_action_just_pressed("down") || 
	Input.is_action_just_pressed("right") || Input.is_action_just_pressed("left")):
		if !ui_focus():
			fullscreen_button.grab_focus()
			
	
	if music_slider.has_focus():
		slider_adjust(music_slider)
		
	if sfx_slider.has_focus():
		slider_adjust(sfx_slider)
		
	# All of these don't highlight for some reason
	#if fullscreen_button.has_focus():
		#press_button(fullscreen_button)
		#
	#if stats_button.has_focus():
		#press_button(stats_button)
		#
	#if quit_button.has_focus():
		#press_button(quit_button)

#func press_button(button):
	#if Input.is_action_just_pressed("select"):
		# have no idea how to use the button and press it

func slider_adjust(slider):
	if slider_timer.is_stopped():
		slider_timer.start()
		if Input.is_action_pressed("left"):
			slider.value -= slider_amount
		elif Input.is_action_pressed("right"):
			slider.value += slider_amount
			
func ui_focus():
	var ui_elements = [music_slider, sfx_slider, fullscreen_button, quit_button]
	for ui_element in ui_elements:
		if ui_element.has_focus():
			return true
	return false
	
func _toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	

func _on_music_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	
func _on_sfx_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))


func _on_fullscreen_button_pressed():
	_toggle_fullscreen(fullscreen_button.button_pressed)

func _toggle_fullscreen(fullscreen_enabled: bool):
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	if fullscreen_enabled:
		window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(window_mode)
	

func _on_quit_button_pressed():
	get_tree().quit()
