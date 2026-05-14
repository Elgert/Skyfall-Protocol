class_name Weapon
extends Node2D
## Auto-firing weapon. Reads timing/damage from a WeaponResource,
## modulates with PlayerStats, and asks the Player for aim direction.
## Add as a child of Player/WeaponMount in the scene.

@export var resource: WeaponResource

var _cooldown: float = 0.0
var _player: Player


func _ready() -> void:
	# Walk up to find the Player (we're a child of Player/WeaponMount).
	var n: Node = self
	while n != null and not (n is Player):
		n = n.get_parent()
	_player = n as Player


func _process(delta: float) -> void:
	# Stats are read each frame instead of cached: Godot runs child _ready()
	# before parent _ready(), so player.stats may still be null at our _ready.
	if resource == null or _player == null or _player.stats == null:
		return
	var stats := _player.stats
	_cooldown = max(0.0, _cooldown - delta)
	if _cooldown == 0.0:
		_fire(stats)
		_cooldown = resource.base_fire_rate / max(0.01, stats.fire_rate_mult)


func _fire(stats: PlayerStats) -> void:
	# Gate: only fire when a visible enemy exists. Direction: plane's forward,
	# not the target's position — bullets shoot out the nose, even while
	# the plane is mid-rotation toward a new target.
	if not _player.has_aim_target():
		return

	var base_dir: Vector2 = global_transform.x.normalized()
	var count := resource.projectile_count + stats.projectile_count_bonus
	var damage := resource.base_damage * stats.damage_mult
	var speed := resource.projectile_speed * stats.projectile_speed_mult
	var pierce := resource.base_pierce + stats.pierce_bonus

	# Spread evenly. count=1 → one bullet straight at target.
	var start_offset := -resource.spread_radians * (count - 1) * 0.5
	for i in count:
		var angle := base_dir.angle() + start_offset + resource.spread_radians * i
		var dir := Vector2.RIGHT.rotated(angle)
		_spawn_projectile(dir, speed, damage, resource.projectile_lifetime, pierce)


func _spawn_projectile(dir: Vector2, speed: float, dmg: float, life: float, pierce: int) -> void:
	if resource.projectile_scene == null:
		return
	var proj: Projectile = resource.projectile_scene.instantiate()
	_get_projectile_container().add_child(proj)
	proj.global_position = global_position
	proj.setup(dir, speed, dmg, life, pierce)


## Projectiles should live in the world, not under the player. Look for a
## node in the "projectile_container" group; fall back to the current scene.
func _get_projectile_container() -> Node:
	var groups := get_tree().get_nodes_in_group(&"projectile_container")
	if not groups.is_empty():
		return groups[0]
	return get_tree().current_scene
