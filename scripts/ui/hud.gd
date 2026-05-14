class_name HUD
extends CanvasLayer
## Signal-driven HUD. Listens to EventBus + reads RunStats/GameManager each frame.
## Never reaches into Player or any other game node directly.

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var level_label: Label = %LevelLabel
@onready var timer_label: Label = %TimerLabel


func _ready() -> void:
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.player_damaged.connect(_on_health_changed)
	EventBus.player_healed.connect(_on_health_changed)
	EventBus.player_leveled_up.connect(_on_level_up)
	# If the player already exists by the time the HUD is ready, catch up.
	var players := get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		_on_player_spawned(players[0])
	_refresh_xp()
	_refresh_level()


func _process(_delta: float) -> void:
	timer_label.text = _format_time(GameManager.elapsed)
	_refresh_xp()  # cheap, keeps bar smooth across signal latency


func _on_player_spawned(p: Node) -> void:
	var player := p as Player
	if player != null and player.health != null:
		_set_health(player.health.current, player.health.max_hp)


func _on_health_changed(_amount: float, current: float, max_hp: float) -> void:
	_set_health(current, max_hp)


func _on_level_up(_new_level: int) -> void:
	_refresh_level()
	_refresh_xp()


func _set_health(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "%d / %d" % [int(round(current)), int(round(max_hp))]


func _refresh_xp() -> void:
	xp_bar.max_value = max(1, RunStats.xp_to_next)
	xp_bar.value = RunStats.xp


func _refresh_level() -> void:
	level_label.text = "Lv %d" % RunStats.level


func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	var m := total / 60
	var s := total % 60
	return "%02d:%02d" % [m, s]
