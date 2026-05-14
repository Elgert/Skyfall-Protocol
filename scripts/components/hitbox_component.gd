class_name HitboxComponent
extends Area2D
## A hitbox RECEIVES damage. Attach to anything that can be hurt:
## the player's body, an enemy's body.
## Forwards damage to a linked HealthComponent.

signal hit(amount: float, source: Node)

@export var health: HealthComponent
@export var invulnerable: bool = false


func _ready() -> void:
	monitoring = false
	monitorable = true
	# Convention fallback: if not wired explicitly, look for a sibling HealthComponent.
	if health == null:
		var parent := get_parent()
		if parent != null:
			var sib := parent.get_node_or_null("HealthComponent")
			if sib is HealthComponent:
				health = sib


func receive_damage(amount: float, source: Node = null) -> void:
	if invulnerable or health == null or not health.is_alive():
		return
	health.take_damage(amount)
	hit.emit(amount, source)
