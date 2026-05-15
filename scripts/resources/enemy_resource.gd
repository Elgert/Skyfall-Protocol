class_name EnemyResource
extends Resource
## Data-only enemy definition. Behavior lives in enemy.gd.

@export var display_name: String = "Drone"
@export var max_hp: float = 10.0
@export var speed: float = 110.0
@export var contact_damage: float = 8.0
@export var xp_value: int = 1

## Optional visual overrides. Color(0,0,0,0) means "use scene default".
@export var tint: Color = Color(0, 0, 0, 0)
@export var visual_scale: float = 1.0

## Marks this enemy as a boss — bigger XP, used by WaveDirector for spawning rules.
@export var is_boss: bool = false

# --- Ranged attack ---
## When true, the enemy fires bullets periodically at the player.
@export var shoots: bool = false
@export var bullet_scene: PackedScene
@export var bullet_damage: float = 6.0
@export var bullet_speed: float = 280.0
@export var shoot_interval: float = 2.0
@export var attack_range: float = 500.0
