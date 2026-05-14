class_name HurtboxComponent
extends Area2D
## A hurtbox DEALS damage on contact. Attach to anything that should hurt things:
## a bullet, an enemy's body, a melee swing.
## Pair with a HitboxComponent on the receiver.
##
## Lifecycle is owned by whoever attaches the hurtbox. Listen to `hit_landed`
## to react (e.g., projectile decrements its pierce count and frees itself).

signal hit_landed(hitbox: HitboxComponent, damage: float)

@export var damage: float = 1.0

## Optional: hurtboxes can ignore hitboxes whose owner is in this group.
## Empty string disables the filter. Useful so player bullets can't hit the player.
@export var ignore_group: String = ""


func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not (area is HitboxComponent):
		return
	var hit: HitboxComponent = area
	if ignore_group != "" and hit.owner != null and hit.owner.is_in_group(ignore_group):
		return
	hit.receive_damage(damage, self)
	hit_landed.emit(hit, damage)
