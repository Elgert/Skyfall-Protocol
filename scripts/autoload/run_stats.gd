extends Node
## Per-run progression: XP, level, kills.
## Reset at the start of each run. Read by HUD and upgrade pickers.

var level: int = 1
var xp: int = 0
var xp_to_next: int = 5
var kills: int = 0


func _ready() -> void:
	EventBus.run_started.connect(reset)
	EventBus.enemy_died.connect(_on_enemy_died)


func reset() -> void:
	level = 1
	xp = 0
	xp_to_next = 5
	kills = 0


func add_xp(amount: int) -> void:
	xp += amount
	EventBus.xp_collected.emit(amount, xp)
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = _xp_curve(level)
		EventBus.player_leveled_up.emit(level)


func _xp_curve(next_level: int) -> int:
	# Mild ramp; tune later.
	return 5 + (next_level - 1) * 3


func _on_enemy_died(_enemy: Node, _position: Vector2, _xp_value: int) -> void:
	# XP is credited when the player picks up the gem, not on kill.
	kills += 1
