extends Node

@onready var container = $PageContainer

var current_scene: Node = null

func _ready():
	# scene pertama yang muncul saat game start
	change_scene(preload("res://Scenes/main_menu.tscn"))

func change_scene(scene: PackedScene):
	# hapus scene lama
	if current_scene:
		current_scene.queue_free()

	# buat scene baru
	current_scene = scene.instantiate()

	# masukkan ke PageContainer
	container.add_child(current_scene)
