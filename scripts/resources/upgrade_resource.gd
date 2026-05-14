class_name UpgradeResource
extends Resource
## Data-only upgrade. Each .tres = one selectable upgrade.
## Deltas are added to the matching field on PlayerStats. Multipliers are stored
## as additive deltas (e.g. +25% damage = 0.25 added to damage_mult).

enum Rarity { COMMON, UNCOMMON, RARE }

@export var id: StringName
@export var display_name: String = "Upgrade"
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON

# --- Stat deltas ---
@export var damage_mult_add: float = 0.0
@export var fire_rate_mult_add: float = 0.0
@export var projectile_speed_mult_add: float = 0.0
@export var projectile_count_add: int = 0
@export var pierce_add: int = 0
@export var move_speed_add: float = 0.0
@export var max_hp_add: float = 0.0
@export var pickup_radius_add: float = 0.0


func apply_to(stats: PlayerStats, player: Player) -> void:
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
