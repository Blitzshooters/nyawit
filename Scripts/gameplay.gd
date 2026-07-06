extends Node2D

# ── Referensi scene spawn ─────────────────────────────────────────────────────
const TREE_SCENE  := preload("res://Sprite/tree.tscn")
const SAWIT_SCENE := preload("res://Sprite/sawit.tscn")

# ── Referensi audio ───────────────────────────────────────────────────────────
const SFX_HIT    := preload("res://Audio/hittree.mp3")
const BGM_STREAM := preload("res://Audio/gameplay.mp3")
const WIN_STREAM := preload("res://Audio/hidup jokowi.mp3")
const LOSE_STREAM:= preload("res://Audio/antek antek asing.mp3")

# ── Referensi node UI (dari CanvasLayer) ──────────────────────────────────────
@onready var score_label: Label         = $CanvasLayer/ScoreLabel
@onready var timer_label: Label         = $CanvasLayer/TimerLabel
@onready var pause_menu: Control        = $CanvasLayer/PauseMenu
@onready var game_over_menu1: Control   = $CanvasLayer/GameOverMenu1
@onready var game_over_menu2: Control   = $CanvasLayer/GameOverMenu2

# Tombol di PauseMenu
@onready var pause_play_btn: TextureButton     = $CanvasLayer/PauseMenu/PlayTextureButton
@onready var pause_menu_btn: TextureButton     = $CanvasLayer/PauseMenu/MainMenuTextureButton

# Tombol di GameOverMenu1 & 2
@onready var go1_menu_btn: TextureButton = $CanvasLayer/GameOverMenu1/MainMenuTextureButton
@onready var go2_menu_btn: TextureButton = $CanvasLayer/GameOverMenu2/MainMenuTextureButton

# ── Variabel game ─────────────────────────────────────────────────────────────
var score: int = 0
var time_left: float = 60.0
var game_active: bool = false
var paused: bool = false

# Container untuk menampung pohon yang sedang aktif (agar bisa di-pause secara independen)
var tree_container: Node2D

# Bag untuk mengacak spawn sawit dan tree agar seimbang dan acak (mencegah tumpukan sejenis berturut-turut)
var spawn_bag: Array[bool] = []

# Spawn interval: diambil dari speed setting (0-100) lalu dimap ke detik
var spawn_interval: float = 0.75
var spawn_timer: float = 0.0

# Percepatan spawn: setiap detik interval dikurangi sedikit, minimal 0.1 detik
const MIN_SPAWN_INTERVAL := 0.1
const ACCELERATION := 0.01   # dikurangi per detik

# ── Audio players ─────────────────────────────────────────────────────────────
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var end_player: AudioStreamPlayer

# ── Pengaturan dari Settings ──────────────────────────────────────────────────
var music_volume: float = 50.0
var sfx_volume: float   = 50.0
var speed_setting: float = 50.0   # 0-100

# ── Spawn area ────────────────────────────────────────────────────────────────
const VIEWPORT_W := 1280.0
const VIEWPORT_H := 720.0
const MARGIN_TOP := 100.0   # hindari area HUD atas
const MARGIN     := 60.0

# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Pastikan script ini tetap aktif saat pause untuk memproses input tombol Esc
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Muat pengaturan volume, kecepatan, dan batas waktu dari GameSettings autoload
	music_volume  = GameSettings.music_volume
	sfx_volume    = GameSettings.sfx_volume
	speed_setting = GameSettings.speed_value
	time_left     = GameSettings.timer_value
	
	# Hubungkan interval spawn awal dari speed setting (2 kali lipat lebih cepat dari sebelumnya)
	# speed 0 → 1.5s, speed 100 → 0.15s (linear)
	spawn_interval = lerp(1.5, 0.15, speed_setting / 100.0)
	
	# Buat container untuk pohon dan atur agar bisa di-pause secara terpisah
	tree_container = Node2D.new()
	tree_container.name = "TreeContainer"
	tree_container.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(tree_container)
	
	# Setup audio
	_setup_audio()
	
	# Sembunyikan semua menu
	pause_menu.visible = false
	game_over_menu1.visible = false
	game_over_menu2.visible = false
	
	# Sambungkan tombol-tombol
	pause_play_btn.pressed.connect(_on_resume_pressed)
	pause_menu_btn.pressed.connect(_on_main_menu_pressed)
	go1_menu_btn.pressed.connect(_on_main_menu_pressed)
	go2_menu_btn.pressed.connect(_on_main_menu_pressed)
	
	game_active = true

func _setup_audio() -> void:
	# BGM
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = BGM_STREAM
	# Diberikan boost +10.0 dB agar lagu gameplay terdengar lebih keras
	if music_volume > 0.0:
		bgm_player.volume_db = linear_to_db(music_volume / 100.0) + 10.0
	else:
		bgm_player.volume_db = -80.0
	bgm_player.autoplay = true
	add_child(bgm_player)
	bgm_player.finished.connect(func(): bgm_player.play())
	
	# SFX
	sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = SFX_HIT
	sfx_player.volume_db = linear_to_db(sfx_volume / 100.0)
	add_child(sfx_player)
	
	# End jingle player
	end_player = AudioStreamPlayer.new()
	add_child(end_player)

func _process(delta: float) -> void:
	if not game_active or paused:
		return
	
	# ── Countdown timer ───────────────────────────────────────────────────────
	time_left -= delta
	timer_label.text = "Timer: %d" % max(0, int(ceil(time_left)))
	
	if time_left <= 0.0:
		_end_game()
		return
	
	# ── Spawn ─────────────────────────────────────────────────────────────────
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_object()
		
		# Percepat spawn interval seiring waktu berlalu
		spawn_interval = max(MIN_SPAWN_INTERVAL, spawn_interval - ACCELERATION * delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # Esc
		if game_active:
			if paused:
				_resume()
			else:
				_pause()

# ─── Spawn ────────────────────────────────────────────────────────────────────

func _spawn_object() -> void:
	# Isi kembali bag jika kosong untuk memastikan spawn sawit & tree seimbang dan teracak secara merata
	if spawn_bag.is_empty():
		for i in range(4):
			spawn_bag.append(true)  # sawit
			spawn_bag.append(false) # tree
		spawn_bag.shuffle()
	
	var is_sawit: bool = spawn_bag.pop_back()
	
	var pos := Vector2.ZERO
	var pos_found := false
	var min_distance := 130.0 # Jarak minimal antar objek agar tidak bertumpuk
	
	for attempt in range(50):
		var rx := randf_range(MARGIN, VIEWPORT_W - MARGIN)
		var ry := randf_range(MARGIN_TOP + MARGIN, VIEWPORT_H - MARGIN)
		var candidate := Vector2(rx, ry)
		
		var overlaps := false
		for child in tree_container.get_children():
			# Lewati jika objek sudah tidak aktif / sedang ditebang
			if child.get("_alive") == false:
				continue
				
			if candidate.distance_to(child.position) < min_distance:
				overlaps = true
				break
		
		if not overlaps:
			pos = candidate
			pos_found = true
			break
	
	# Jika tidak menemukan posisi yang tidak bertumpuk setelah 50 kali percobaan, lewati spawn kali ini
	if not pos_found:
		return
		
	var scene = SAWIT_SCENE if is_sawit else TREE_SCENE
	var obj = scene.instantiate()
	obj.position = pos
	
	# Sambungkan sinyal klik
	obj.clicked.connect(_on_object_clicked.bind(is_sawit))
	
	tree_container.add_child(obj)

# ─── Event handlers ───────────────────────────────────────────────────────────

func _on_object_clicked(_node: Node2D, is_sawit: bool) -> void:
	if not game_active or paused:
		return
	
	# SFX tebang
	sfx_player.play()
	
	if is_sawit:
		score -= 1
	else:
		score += 1
	
	score_label.text = "Score: %d" % score

func _pause() -> void:
	paused = true
	pause_menu.visible = true
	get_tree().paused = true

func _resume() -> void:
	get_tree().paused = false
	paused = false
	pause_menu.visible = false

func _on_resume_pressed() -> void:
	_resume()

func _on_main_menu_pressed() -> void:
	# Pastikan game tidak pause saat kembali ke menu
	get_tree().paused = false
	get_node("/root/Main").change_scene(load("res://Scenes/main_menu.tscn"))

func _end_game() -> void:
	game_active = false
	
	# Hentikan BGM
	bgm_player.stop()
	
	# Bersihkan pohon yang tersisa
	for child in tree_container.get_children():
		child.queue_free()
	
	# Tampilkan menu yang sesuai dan putar audio
	if score >= 0:
		game_over_menu1.visible = true
		end_player.stream = WIN_STREAM
	else:
		game_over_menu2.visible = true
		end_player.stream = LOSE_STREAM
	
	end_player.volume_db = linear_to_db(music_volume / 100.0)
	end_player.play()
