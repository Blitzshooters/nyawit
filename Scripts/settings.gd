extends Control

@onready var music_slider: HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/MusicHSlider
@onready var sfx_slider:   HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/SFXHSlider
@onready var speed_slider:  HSlider = $HBoxContainer/MarginContainer2/VBoxContainer2/SpeedHSlider

@onready var music_value: Label = $HBoxContainer/MarginContainer3/VBoxContainer3/MusicValue
@onready var sfx_value:   Label = $HBoxContainer/MarginContainer3/VBoxContainer3/SFXValue
@onready var speed_value:  Label = $HBoxContainer/MarginContainer3/VBoxContainer3/SpeedValue

@onready var main_menu_btn: TextureButton = $MainMenuTextureButton
@onready var play_btn:      TextureButton = $PlayTextureButton

func _ready() -> void:
	# Muat nilai tersimpan dari GameSettings autoload
	music_slider.value = GameSettings.music_volume
	sfx_slider.value   = GameSettings.sfx_volume
	speed_slider.value = GameSettings.speed_value
	
	# Setel label awal
	music_value.text = str(int(music_slider.value))
	sfx_value.text   = str(int(sfx_slider.value))
	speed_value.text  = str(int(speed_slider.value))
	
	# Sambungkan sinyal slider
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	
	# Sambungkan tombol
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	play_btn.pressed.connect(_on_play_pressed)

func _on_music_changed(value: float) -> void:
	music_value.text = str(int(value))
	GameSettings.music_volume = value
	var main = get_node_or_null("/root/Main")
	if main and main.bgm_player:
		main.bgm_player.volume_db = linear_to_db(value / 100.0)

func _on_sfx_changed(value: float) -> void:
	sfx_value.text = str(int(value))
	GameSettings.sfx_volume = value

func _on_speed_changed(value: float) -> void:
	speed_value.text = str(int(value))
	GameSettings.speed_value = value

func _on_main_menu_pressed() -> void:
	get_node("/root/Main").change_scene(load("res://Scenes/main_menu.tscn"))

func _on_play_pressed() -> void:
	get_node("/root/Main").change_scene(load("res://Scenes/gameplay.tscn"))
