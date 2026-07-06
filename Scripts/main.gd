extends Node

@onready var container = $PageContainer

var current_scene: Node = null
var bgm_player: AudioStreamPlayer
var menu_bgm = preload("res://Audio/mainmenu.ogg")
var cursor_instance: Node = null

func _ready() -> void:
	# 1. Setup Global BGM Player for menu, settings, credit
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = menu_bgm
	bgm_player.volume_db = linear_to_db(GameSettings.music_volume / 100.0)
	bgm_player.finished.connect(func(): bgm_player.play())
	add_child(bgm_player)
	
	# 2. Setup Global Axe Cursor Layer (layer 128) to float above all scenes/UI
	var cursor_layer = CanvasLayer.new()
	cursor_layer.layer = 128
	add_child(cursor_layer)
	
	var cursor_scene = load("res://Sprite/axe_cursor.tscn")
	cursor_instance = cursor_scene.instantiate()
	cursor_layer.add_child(cursor_instance)
	
	# Sembunyikan kursor bawaan sistem
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# 3. Load first scene (Main Menu)
	change_scene(load("res://Scenes/main_menu.tscn"))

func change_scene(scene: PackedScene):
	print("[Main] change_scene called with: ", scene.resource_path if scene else "null")
	if not scene:
		printerr("[Main] Error: Attempted to change to a null scene!")
		return

	if current_scene:
		print("[Main] Removing old scene: ", current_scene.name, " (", current_scene, ")")
		container.remove_child(current_scene)
		current_scene.queue_free()

	# Cek apakah scene yang dimuat adalah gameplay
	var is_gameplay = "gameplay.tscn" in scene.resource_path.to_lower()
	
	# Atur pemutaran BGM global (hanya hidup di non-gameplay)
	if is_gameplay:
		bgm_player.stop()
	else:
		if not bgm_player.is_playing():
			bgm_player.volume_db = linear_to_db(GameSettings.music_volume / 100.0)
			bgm_player.play()

	current_scene = scene.instantiate()
	print("[Main] Instantiated new scene: ", current_scene.name, " (", current_scene, ")")
	container.add_child(current_scene)
	print("[Main] Current children in PageContainer: ", container.get_children())
