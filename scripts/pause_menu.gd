extends Control

@export_subgroup("References")
@export var music_slider: Slider
@export var sfx_slider: Slider
@export var fullscreen_button: Button
@export var quit_button: Button

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
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen_button.button_pressed = !fullscreen_button.button_pressed
		
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()
		
		
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
