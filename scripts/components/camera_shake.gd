class_name CameraShake
extends Node
## Drives a parent Camera2D's offset to fake screen shake.
## Listens to EventBus.player_damaged automatically; call shake() to add more.

@export var max_offset: Vector2 = Vector2(8, 8)
@export var decay: float = 6.0  ## higher = faster falloff

var _trauma: float = 0.0  ## 0..1, squared to map to actual shake
var _camera: Camera2D


func _ready() -> void:
	_camera = get_parent() as Camera2D
	EventBus.player_damaged.connect(_on_player_damaged)


func _process(delta: float) -> void:
	if _camera == null:
		return
	if _trauma > 0.0:
		_trauma = max(0.0, _trauma - decay * delta)
		var amount := _trauma * _trauma
		_camera.offset = Vector2(
			randf_range(-max_offset.x, max_offset.x) * amount,
			randf_range(-max_offset.y, max_offset.y) * amount
		)
	elif _camera.offset != Vector2.ZERO:
		_camera.offset = Vector2.ZERO


## Add trauma (0..1). Use larger values for bigger hits.
func shake(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _on_player_damaged(amount: float, _current: float, _max_hp: float) -> void:
	# Trauma scales with hit size — big hits shake harder.
	shake(clampf(amount * 0.04, 0.2, 0.8))
