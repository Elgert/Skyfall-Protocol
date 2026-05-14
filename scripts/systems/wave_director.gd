class_name WaveDirector
extends Node
## Continuous spawning with a time-based difficulty ramp + boss spawns.
## - Basic drones from t=0
## - Elite drones start mixing in after `elite_start_time`, ramping up
## - Boss spawns at `boss_interval` cadence (default every 120s)

@export var enemy_scene: PackedScene

# Standard enemy roster + elite mix-in
@export var basic_resource: EnemyResource
@export var elite_resource: EnemyResource
@export var elite_start_time: float = 60.0  ## seconds until elites can appear
@export var elite_chance_max: float = 0.35  ## max fraction of spawns that are elites
@export var elite_ramp_time: float = 180.0  ## seconds to reach elite_chance_max

# Boss
@export var boss_resource: EnemyResource
@export var boss_interval: float = 120.0  ## seconds between boss spawns

# Spawn pacing
@export var spawn_radius: float = 700.0
@export var base_spawn_interval: float = 1.5
@export var min_spawn_interval: float = 0.18
@export var interval_decay_per_sec: float = 0.02
@export var max_alive: int = 100

var _spawn_accum: float = 0.0
var _next_boss_time: float = -1.0
var _player: Node2D = null
var _alive_count: int = 0


func _ready() -> void:
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.run_started.connect(_on_run_started)
	var players := get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		_player = players[0]


func _on_run_started() -> void:
	_spawn_accum = 0.0
	_alive_count = 0
	_next_boss_time = boss_interval


func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.RUNNING:
		return
	if _player == null or not is_instance_valid(_player) or enemy_scene == null:
		return

	# Boss check first — bosses always spawn even if cap is reached.
	if boss_resource != null and GameManager.elapsed >= _next_boss_time:
		_next_boss_time += boss_interval
		_spawn_resource(boss_resource)

	# Normal spawn cadence
	var interval := _current_interval()
	_spawn_accum += delta
	while _spawn_accum >= interval and _alive_count < max_alive:
		_spawn_accum -= interval
		_spawn_one_normal()


func _current_interval() -> float:
	var t := GameManager.elapsed
	return max(min_spawn_interval, base_spawn_interval - t * interval_decay_per_sec)


func _spawn_one_normal() -> void:
	# Roll elite vs basic.
	var use_elite := false
	if elite_resource != null and GameManager.elapsed >= elite_start_time:
		var ramp_progress: float = clampf((GameManager.elapsed - elite_start_time) / elite_ramp_time, 0.0, 1.0)
		var chance: float = ramp_progress * elite_chance_max
		use_elite = randf() < chance
	_spawn_resource(elite_resource if use_elite else basic_resource)


func _spawn_resource(res: EnemyResource) -> void:
	if res == null:
		return
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.resource = res
	_get_enemy_container().add_child(enemy)
	var angle := randf() * TAU
	enemy.global_position = _player.global_position + Vector2(spawn_radius, 0).rotated(angle)


func _get_enemy_container() -> Node:
	var groups := get_tree().get_nodes_in_group(&"enemy_container")
	if not groups.is_empty():
		return groups[0]
	return get_tree().current_scene


func _on_player_spawned(p: Node) -> void:
	_player = p


func _on_enemy_spawned(_e: Node) -> void:
	_alive_count += 1


func _on_enemy_died(_e: Node, _pos: Vector2, _xp: int) -> void:
	_alive_count = max(0, _alive_count - 1)
