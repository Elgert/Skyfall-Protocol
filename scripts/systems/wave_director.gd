class_name WaveDirector
extends Node
## Spawning + difficulty ramp.
## - Basic drones spawn continuously on a decaying interval.
## - Elites spawn on a strict timer that shortens every 60s (30s → 25s → 20s ...
##   floored at 5s).
## - Bosses spawn every 3 minutes. Stats scale up per spawn; every 3rd spawn
##   doubles the number of bosses summoned.

@export var enemy_scene: PackedScene

@export var basic_resource: EnemyResource
@export var elite_resource: EnemyResource
@export var boss_resource: EnemyResource
@export var shooter_resource: EnemyResource
@export var shooter_start_time: float = 30.0
@export var shooter_interval: float = 8.0

# Basic spawn cadence
@export var spawn_radius: float = 700.0
@export var base_spawn_interval: float = 1.5
@export var min_spawn_interval: float = 0.18
@export var interval_decay_per_sec: float = 0.02
@export var max_alive: int = 100

# Elite schedule: every (30 - 5 * minute) seconds, floored at min_elite_interval.
@export var elite_base_interval: float = 30.0
@export var elite_interval_decrement: float = 5.0
@export var min_elite_interval: float = 5.0

# Boss schedule
@export var boss_interval: float = 180.0
@export var boss_hp_growth: float = 0.18      ## +18% HP per boss spawn
@export var boss_damage_growth: float = 0.12  ## +12% contact damage per boss spawn

var _spawn_accum: float = 0.0
var _player: Node2D = null
var _alive_count: int = 0

var _next_elite_time: float = 0.0
var _next_boss_time: float = 0.0
var _next_shooter_time: float = 0.0
var _boss_spawn_index: int = 0  ## 0-indexed count of boss spawn events


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
	_next_elite_time = _current_elite_interval()
	_next_boss_time = boss_interval
	_next_shooter_time = shooter_start_time
	_boss_spawn_index = 0


func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.RUNNING:
		return
	if _player == null or not is_instance_valid(_player) or enemy_scene == null:
		return

	# Boss tick — bosses always spawn (bypass alive cap).
	if boss_resource != null and GameManager.elapsed >= _next_boss_time:
		_spawn_boss_wave()
		_boss_spawn_index += 1
		_next_boss_time += boss_interval

	# Elite tick — strict timer.
	if elite_resource != null and GameManager.elapsed >= _next_elite_time:
		_spawn_resource(elite_resource)
		_next_elite_time += _current_elite_interval()

	# Shooter tick — independent timer.
	if shooter_resource != null and GameManager.elapsed >= _next_shooter_time:
		_spawn_resource(shooter_resource)
		_next_shooter_time += shooter_interval

	# Basic ramp.
	var interval := _current_interval()
	_spawn_accum += delta
	while _spawn_accum >= interval and _alive_count < max_alive:
		_spawn_accum -= interval
		_spawn_resource(basic_resource)


## Elite interval shortens by `elite_interval_decrement` every 60s, floored.
func _current_elite_interval() -> float:
	var minute := int(GameManager.elapsed / 60.0)
	return max(min_elite_interval, elite_base_interval - elite_interval_decrement * float(minute))


func _current_interval() -> float:
	var t := GameManager.elapsed
	return max(min_spawn_interval, base_spawn_interval - t * interval_decay_per_sec)


## How many bosses to spawn this wave. count = 2 ^ floor((index + 1) / 3).
##   index 0,1,2  -> 1, 1, 1
##   index 3,4,5  -> 2, 2, 2  (the 3rd, 6th, 9th spawn doubles vs. prior)
## Wait — user wanted "every 3rd spawn doubles the AMOUNT". With 0-indexed:
##   spawn 1 (index 0): 1   spawn 2 (1): 1   spawn 3 (2): 2 (doubled)
##   spawn 4 (3): 2         spawn 5 (4): 2   spawn 6 (5): 4 (doubled)
## Formula: 2 ^ floor((index + 1) / 3) gives 1,1,2,2,2,4,4,4,8,...
func _boss_count_for(spawn_index: int) -> int:
	return int(pow(2.0, floor(float(spawn_index + 1) / 3.0)))


func _spawn_boss_wave() -> void:
	var count := _boss_count_for(_boss_spawn_index)
	# Duplicate the resource and scale stats per spawn index.
	var scaled: EnemyResource = boss_resource.duplicate(true) as EnemyResource
	scaled.max_hp = boss_resource.max_hp * pow(1.0 + boss_hp_growth, float(_boss_spawn_index))
	scaled.contact_damage = boss_resource.contact_damage * pow(1.0 + boss_damage_growth, float(_boss_spawn_index))
	for i in count:
		_spawn_resource(scaled)


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
