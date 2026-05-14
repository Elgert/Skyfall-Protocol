class_name XPGem
extends Area2D
## Drops on enemy death. Sits still until the player is within pickup_radius,
## then magnets toward them. Credits XP to RunStats on contact.

const COLLECT_SPEED: float = 700.0
const MAGNET_ACCEL: float = 12.0  ## how fast we ramp into the player

var xp_value: int = 1

var _player: Player = null
var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	_find_player()
	EventBus.player_spawned.connect(_on_player_spawned)


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var to_player := _player.global_position - global_position
	var radius: float = 70.0
	if _player.stats != null:
		radius = _player.stats.pickup_radius
	if to_player.length() <= radius:
		var pull := to_player.normalized() * COLLECT_SPEED
		_velocity = _velocity.lerp(pull, MAGNET_ACCEL * delta)
		global_position += _velocity * delta


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		_player = players[0] as Player


func _on_player_spawned(p: Node) -> void:
	_player = p as Player


func _on_area_entered(area: Area2D) -> void:
	# Gem's mask=1 means only player-layer Area2Ds get here.
	if area is HitboxComponent:
		RunStats.add_xp(xp_value)
		queue_free()
