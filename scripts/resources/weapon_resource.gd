class_name WeaponResource
extends Resource
## Data-only weapon definition. Behavior lives in weapon.gd.
## Create .tres files in res://resources/weapons/ to define new weapons.

## Stable id used to look up the weapon (for unlocks and targeted upgrades).
@export var id: StringName = &""

@export var display_name: String = "Machine Gun"

## Base time between shots (seconds). Lower = faster fire rate.
## Effective fire rate = base_fire_rate / player_stats.fire_rate_mult
@export var base_fire_rate: float = 0.25

## Base damage per projectile.
## Effective damage = base_damage * player_stats.damage_mult
@export var base_damage: float = 5.0

## Number of projectiles per shot before player_stats.projectile_count_bonus.
@export var projectile_count: int = 1

## Spread angle between projectiles in a multi-shot, in radians.
@export var spread_radians: float = 0.12

## Base projectile speed (pixels/sec).
@export var projectile_speed: float = 700.0

## Bullet flight time before despawn (seconds).
@export var projectile_lifetime: float = 1.2

## Times a projectile can hit before despawning. 1 = no pierce.
@export var base_pierce: int = 1

## Scene to spawn for each projectile.
@export var projectile_scene: PackedScene

## Drone weapons only: orbit radius (px) and orbit angular speed (rad/s).
@export var orbit_radius: float = 80.0
@export var orbit_speed: float = 2.5
