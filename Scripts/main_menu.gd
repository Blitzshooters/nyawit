extends Control

@onready var sawit_sprite: AnimatedSprite2D = $SawitAnimatedSprite2D
@onready var tree_sprite: AnimatedSprite2D  = $TreeAnimatedSprite2D

func _ready() -> void:
	sawit_sprite.play("default")
	tree_sprite.play("default")
	$VBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditTextureButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/ExitTextureButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_node("/root/Main").change_scene(
		load("res://Scenes/gameplay.tscn")
	)

func _on_settings_pressed():
	get_node("/root/Main").change_scene(
		load("res://Scenes/settings.tscn")
	)

func _on_credits_pressed():
	get_node("/root/Main").change_scene(
		load("res://Scenes/credit.tscn")
	)

func _on_quit_pressed():
	get_tree().quit()


func _on_play_texture_button_pressed() -> void:
	_on_play_pressed()
