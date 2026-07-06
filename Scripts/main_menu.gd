extends Control

func _ready() -> void:
	$VBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditTextureButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/ExitTextureButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_node("/root/Main").change_scene(
		preload("res://Scenes/gameplay.tscn")
	)

func _on_settings_pressed():
	get_node("/root/Main").change_scene(
		preload("res://Scenes/settings.tscn")
	)

func _on_credits_pressed():
	get_node("/root/Main").change_scene(
		preload("res://Scenes/credit.tscn")
	)

func _on_quit_pressed():
	get_tree().quit()


func _on_play_texture_button_pressed() -> void:
	_on_play_pressed()
