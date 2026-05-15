class_name WeaponDrones
extends Node2D
## Orbiting drones around the player. Each drone has a hurtbox that damages
## enemies on contact. Count / radius / speed / damage live on the WeaponResource.

const DRONE_SCENE: PackedScene = preload("res://scenes/projectiles/seraphic_blade.tscn")

@export var resource: WeaponResource

var weapon_id: StringName = &"drones"

var _player: Player
var _drones: Array[Node2D] = []
var _angle: float = 0.0


func _ready() -> void:
	if resource != null:
		resource = resource.duplicate(true) as WeaponResource
		weapon_id = resource.id
	var n: Node = self
	while n != null and not (n is Player):
		n = n.get_parent()
	_player = n as Player
	_rebuild_drones()


func _process(delta: float) -> void:
	if resource == null or _player == null:
		return
	_angle = wrapf(_angle + resource.orbit_speed * delta, 0.0, TAU)
	var n := _drones.size()
	if n == 0:
		return
	var step := TAU / float(n)
	for i in n:
		var d := _drones[i]
		if not is_instance_valid(d):
			continue
		var a := _angle + step * i
		d.global_position = _player.global_position + Vector2(resource.orbit_radius, 0).rotated(a)


func apply_upgrade(u: UpgradeResource) -> void:
	if resource == null:
		return
	if u.damage_mult_add != 0.0:
		resource.base_damage *= 1.0 + u.damage_mult_add
		_apply_damage_to_drones()
	if u.projectile_speed_mult_add != 0.0:
		resource.orbit_speed *= 1.0 + u.projectile_speed_mult_add
	if u.projectile_count_add != 0:
		resource.projectile_count += u.projectile_count_add
		_rebuild_drones()


func _rebuild_drones() -> void:
	for d in _drones:
		if is_instance_valid(d):
			d.queue_free()
	_drones.clear()
	if resource == null:
		return
	var container := _get_container()
	for i in resource.projectile_count:
		var drone: Node2D = DRONE_SCENE.instantiate()
		container.add_child(drone)
		_drones.append(drone)
	_apply_damage_to_drones()


func _apply_damage_to_drones() -> void:
	for d in _drones:
		if not is_instance_valid(d):
			continue
		var hb := d.get_node_or_null("HurtboxComponent")
		if hb is HurtboxComponent:
			hb.damage = resource.base_damage


func _get_container() -> Node:
	var groups := get_tree().get_nodes_in_group(&"projectile_container")
	if not groups.is_empty():
		return groups[0]
	return get_tree().current_scene
