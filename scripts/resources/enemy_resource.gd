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
