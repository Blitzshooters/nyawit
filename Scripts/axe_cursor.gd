extends AnimatedSprite2D

func _ready() -> void:
	# Sembunyikan kursor sistem
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	play("Idle")
	
	# Pastikan kursor tetap diproses dan dapat digerakkan meskipun game sedang di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	# Menggunakan mouse position dari viewport agar sejajar sempurna di CanvasLayer
	global_position = get_viewport().get_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			play("OnClick")
		else:
			play("Idle")
