extends Control

# Slider node paths
@onready var music_slider: HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/MusicHSlider
@onready var sfx_slider: HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/SFXHSlider
@onready var speed_slider: HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/SpeedHSlider

# Value label node paths
@onready var music_value: Label = $HBoxContainer/MarginContainer3/VBoxContainer3/MusicValue
@onready var sfx_value: Label = $HBoxContainer/MarginContainer3/VBoxContainer3/SFXValue
@onready var speed_value: Label = $HBoxContainer/MarginContainer3/VBoxContainer3/SpeedValue

# Buttons
@onready var main_menu_btn: TextureButton = $MainMenuTextureButton
@onready var play_btn: TextureButton = $PlayTextureButton

func _ready() -> void:
	# Set initial label values to match slider defaults
	music_value.text = str(int(music_slider.value))
	sfx_value.text = str(int(sfx_slider.value))
	speed_value.text = str(int(speed_slider.value))

	# Connect slider value_changed signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	speed_slider.value_changed.connect(_on_speed_slider_changed)

	# Connect buttons
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	play_btn.pressed.connect(_on_play_pressed)

func _on_music_slider_changed(value: float) -> void:
	music_value.text = str(int(value))

func _on_sfx_slider_changed(value: float) -> void:
	sfx_value.text = str(int(value))

func _on_speed_slider_changed(value: float) -> void:
	speed_value.text = str(int(value))

func _on_main_menu_pressed() -> void:
	get_node("/root/Main").change_scene(
		load("res://Scenes/main_menu.tscn")
	)

func _on_play_pressed() -> void:
	get_node("/root/Main").change_scene(
		load("res://Scenes/gameplay.tscn")
	)
