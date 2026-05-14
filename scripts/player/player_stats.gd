class_name PlayerStats
extends Resource
## All tunable player numbers live on this Resource.
## Upgrades mutate fields here. Weapons read damage_mult / fire_rate_mult / etc.

# --- Survival ---
@export var max_hp: float = 100.0
@export var iframe_duration: float = 0.6

# --- Flight ---
@export var move_speed: float = 320.0
@export var acceleration: float = 1400.0
@export var friction: float = 900.0
@export var rotation_speed: float = 8.0  # radians/sec toward aim target

# --- Boost / dash ---
@export var boost_multiplier: float = 2.4
@export var boost_duration: float = 0.25
@export var boost_cooldown: float = 1.2

# --- Pickups ---
@export var pickup_radius: float = 70.0

# --- Weapon modifiers (read by weapons, written by upgrades) ---
@export var damage_mult: float = 1.0
@export var fire_rate_mult: float = 1.0
@export var projectile_count_bonus: int = 0
@export var projectile_speed_mult: float = 1.0
@export var pierce_bonus: int = 0
