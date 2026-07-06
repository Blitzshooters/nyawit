extends Node

@onready var container = $PageContainer

var current_scene: Node = null

func _ready():
	# scene pertama yang muncul saat game start
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

	current_scene = scene.instantiate()
	print("[Main] Instantiated new scene: ", current_scene.name, " (", current_scene, ")")
	container.add_child(current_scene)
	print("[Main] Current children in PageContainer: ", container.get_children())

