extends Control

@onready var main_menu_btn: TextureButton = $MainMenuTextureButton
@onready var play_btn: TextureButton = $PlayTextureButton

func _ready() -> void:
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	play_btn.pressed.connect(_on_play_pressed)

func _on_main_menu_pressed() -> void:
	get_node("/root/Main").change_scene(
		load("res://Scenes/main_menu.tscn")
	)

func _on_play_pressed() -> void:
	get_node("/root/Main").change_scene(
		load("res://Scenes/gameplay.tscn")
	)
