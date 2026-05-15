class_name Enemy
extends CharacterBody2D
## Chases the nearest player and damages on contact.
## All stats come from EnemyResource. Spawned by WaveDirector (later)
## or placed by hand for testing.

@export var resource: EnemyResource

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var visual: Polygon2D = $Visual

var _player: Node2D = null
var _base_color: Color = Color.WHITE
var _flash_timer: float = 0.0
var _shoot_timer: float = 0.0


func _ready() -> void:
	add_to_group(&"enemy")
	_base_color = visual.color
	if resource != null:
		health.set_max_hp(resource.max_hp, true)
		hurtbox.damage = resource.contact_damage
		if resource.tint != Color(0, 0, 0, 0):
			visual.color = resource.tint
			_base_color = resource.tint
		if resource.visual_scale != 1.0:
			scale = Vector2.ONE * resource.visual_scale
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	EventBus.player_spawned.connect(_on_player_spawned)
	_find_player()
	EventBus.enemy_spawned.emit(self)


func _physics_process(delta: float) -> void:
	_tick_flash(delta)
	if _player == null or not is_instance_valid(_player):
		_find_player()
		velocity = Vector2.ZERO
		return
	_tick_shoot(delta)
	var to_player := _player.global_position - global_position
	if to_player.length_squared() < 1.0:
		return
	var dir := to_player.normalized()
	var speed := resource.speed if resource != null else 100.0
	velocity = dir * speed
	rotation = velocity.angle()
	move_and_slide()


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		_player = players[0]


func _on_player_spawned(p: Node) -> void:
	_player = p


func _on_damaged(_amount: float, _current: float, _max_hp: float) -> void:
	_flash_timer = 0.08


func _tick_shoot(delta: float) -> void:
	if resource == null or not resource.shoots or resource.bullet_scene == null:
		return
	_shoot_timer = max(0.0, _shoot_timer - delta)
	if _shoot_timer > 0.0:
		return
	if global_position.distance_squared_to(_player.global_position) > resource.attack_range * resource.attack_range:
		return
	_fire_at_player()
	_shoot_timer = resource.shoot_interval


func _fire_at_player() -> void:
	var bullet: Projectile = resource.bullet_scene.instantiate()
	var dir := (_player.global_position - global_position).normalized()
	_get_projectile_container().add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(dir, resource.bullet_speed, resource.bullet_damage, 2.5, 1)


func _get_projectile_container() -> Node:
	var groups := get_tree().get_nodes_in_group(&"projectile_container")
	if not groups.is_empty():
		return groups[0]
	return get_tree().current_scene


func _tick_flash(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer = max(0.0, _flash_timer - delta)
		visual.color = Color.WHITE if _flash_timer > 0.0 else _base_color


func _on_died() -> void:
	var xp := resource.xp_value if resource != null else 1
	EventBus.enemy_died.emit(self, global_position, xp)
	queue_free()
