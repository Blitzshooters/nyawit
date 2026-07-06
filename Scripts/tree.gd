extends Area2D

signal clicked(node)

var _alive := true
var _lifetime_timer := 0.0
const LIFETIME := 2.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("default")
	input_pickable = true

func _process(delta: float) -> void:
	if not _alive:
		return
	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		_die_expired()

func _input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if not _alive:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_alive = false
		emit_signal("clicked", self)
		sprite.play("cutdown")
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _die_expired() -> void:
	_alive = false
	queue_free()
