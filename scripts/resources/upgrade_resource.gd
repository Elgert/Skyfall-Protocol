class_name UpgradeResource
extends Resource
## Data-only upgrade. Behaviour: optional weapon unlock, optional weapon-targeted
## stat changes, otherwise applies to global PlayerStats.

enum Rarity { COMMON, UNCOMMON, RARE }

@export var id: StringName
@export var display_name: String = "Upgrade"
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON

# --- Eligibility filters (used by UpgradeDatabase.roll_choices) ---
## Only offer this upgrade if the player owns the named weapon.
@export var requires_weapon_id: StringName = &""

# --- Weapon unlock ---
## Optional scene + resource. When non-null, applying this upgrade adds a new
## weapon to the player's WeaponMount.
@export var weapon_unlock_scene: PackedScene
@export var weapon_unlock_resource: WeaponResource

# --- Stat deltas ---
## If non-empty, deltas apply to that weapon instead of PlayerStats.
@export var targets_weapon_id: StringName = &""

@export var damage_mult_add: float = 0.0
@export var fire_rate_mult_add: float = 0.0
@export var projectile_speed_mult_add: float = 0.0
@export var projectile_count_add: int = 0
@export var pierce_add: int = 0
@export var move_speed_add: float = 0.0
@export var max_hp_add: float = 0.0
@export var pickup_radius_add: float = 0.0


func apply_to(stats: PlayerStats, player: Player) -> void:
	# Weapon unlock first — gives the player the weapon, then deltas (if any)
	# can target it.
	if weapon_unlock_scene != null and player != null and player.weapon_mount != null:
		var w: Node = weapon_unlock_scene.instantiate()
		if weapon_unlock_resource != null:
			w.set("resource", weapon_unlock_resource)
		player.weapon_mount.add_child(w)

	# Weapon-targeted upgrade
	if targets_weapon_id != &"" and player != null:
		var weapon := player.find_weapon(targets_weapon_id)
		if weapon != null and weapon.has_method("apply_upgrade"):
			weapon.apply_upgrade(self)
		return

	# Global player-stat upgrade
	if stats == null:
		return
	stats.damage_mult += damage_mult_add
	stats.fire_rate_mult += fire_rate_mult_add
	stats.projectile_speed_mult += projectile_speed_mult_add
	stats.projectile_count_bonus += projectile_count_add
	stats.pierce_bonus += pierce_add
	stats.move_speed += move_speed_add
	stats.pickup_radius += pickup_radius_add
	if max_hp_add != 0.0:
		stats.max_hp += max_hp_add
		if player != null and player.health != null:
			player.health.set_max_hp(stats.max_hp, false)
			player.health.heal(max_hp_add)
