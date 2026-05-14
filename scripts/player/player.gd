class_name Player
extends CharacterBody2D
## Arcade airplane: WASD to thrust, mouse to aim, Shift to boost.
## All numbers come from the PlayerStats resource — keep this script behavior-only.

@export var stats: PlayerStats

@onready var sprite: Node2D = $Visual
@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var weapon_mount: Node2D = $WeaponMount

var _boost_time_left: float = 0.0
var _boost_cooldown_left: float = 0.0
var _iframe_left: float = 0.0
var _flicker_t: float = 0.0

## Cached each physics frame so weapons and rotation agree on the same target.
var _aim_target: Node2D = null


func _ready() -> void:
	if stats == null:
		stats = PlayerStats.new()
	health.max_hp = stats.max_hp
	health.set_max_hp(stats.max_hp, true)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	add_to_group("player")
	EventBus.player_spawned.emit(self)


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_refresh_aim_target()
	_apply_movement(delta)
	_apply_rotation(delta)
	_apply_iframe_flicker(delta)
	move_and_slide()


## Returns the world position the plane is aiming at, or Vector2.INF if no target.
func get_aim_position() -> Vector2:
	return _aim_target.global_position if _aim_target != null else Vector2.INF


func has_aim_target() -> bool:
	return _aim_target != null and is_instance_valid(_aim_target)


func _refresh_aim_target() -> void:
	# Only target visible enemies. Bullets can still hit anything they pass
	# through — but the player only shoots when there's a target on-screen.
	var view_rect := _get_view_rect()
	var nearest: Node2D = null
	var nearest_dist_sq := INF
	for n in get_tree().get_nodes_in_group(&"enemy"):
		if not (n is Node2D):
			continue
		var node2d: Node2D = n
		if not view_rect.has_point(node2d.global_position):
			continue
		var d := global_position.distance_squared_to(node2d.global_position)
		if d < nearest_dist_sq:
			nearest_dist_sq = d
			nearest = node2d
	_aim_target = nearest


## World-space rect that the camera currently shows.
func _get_view_rect() -> Rect2:
	var vp := get_viewport_rect().size
	var cam: Camera2D = $Camera2D
	var size := vp / cam.zoom
	var center := cam.get_screen_center_position()
	return Rect2(center - size * 0.5, size)


func _tick_timers(delta: float) -> void:
	_boost_time_left = max(0.0, _boost_time_left - delta)
	_boost_cooldown_left = max(0.0, _boost_cooldown_left - delta)
	if _iframe_left > 0.0:
		_iframe_left = max(0.0, _iframe_left - delta)
		if _iframe_left == 0.0:
			hitbox.invulnerable = false
			sprite.modulate.a = 1.0


func _apply_movement(delta: float) -> void:
	var input := Vector2(
		Input.get_axis(&"move_left", &"move_right"),
		Input.get_axis(&"move_up", &"move_down")
	)
	if input.length_squared() > 1.0:
		input = input.normalized()

	# Boost trigger
	if Input.is_action_just_pressed(&"boost") and _boost_cooldown_left == 0.0:
		_boost_time_left = stats.boost_duration
		_boost_cooldown_left = stats.boost_cooldown

	var max_speed := stats.move_speed
	if _boost_time_left > 0.0:
		max_speed *= stats.boost_multiplier

	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * max_speed, stats.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, stats.friction * delta)


func _apply_rotation(delta: float) -> void:
	# Priority: face the nearest enemy. If none, face the direction of travel.
	# If standing still with no target, keep current rotation.
	var target_angle: float = rotation
	if has_aim_target():
		target_angle = global_position.angle_to_point(_aim_target.global_position)
	elif velocity.length_squared() > 100.0:
		target_angle = velocity.angle()
	else:
		return
	rotation = rotate_toward(rotation, target_angle, stats.rotation_speed * delta)


func _apply_iframe_flicker(delta: float) -> void:
	if _iframe_left == 0.0:
		return
	_flicker_t += delta * 30.0
	sprite.modulate.a = 0.4 + 0.6 * (0.5 + 0.5 * sin(_flicker_t))


func _on_damaged(amount: float, current: float, max_hp: float) -> void:
	EventBus.player_damaged.emit(amount, current, max_hp)
	_iframe_left = stats.iframe_duration
	hitbox.invulnerable = true


func _on_died() -> void:
	EventBus.player_died.emit()
	set_physics_process(false)
	hide()
