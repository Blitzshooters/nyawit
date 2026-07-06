extends Control

@onready var main_menu_btn: TextureButton = $MainMenuTextureButton
@onready var play_btn: TextureButton = $PlayTextureButton

@onready var sawit_sprite: AnimatedSprite2D = $SawitAnimatedSprite2D
@onready var tree_sprite: AnimatedSprite2D  = $TreeAnimatedSprite2D

func _ready() -> void:
	sawit_sprite.play("default")
	tree_sprite.play("default")
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
