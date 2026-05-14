class_name HealthComponent
extends Node
## Tracks HP for whatever owns it. Doesn't know or care what that is.
## Emits signals on damage/heal/death; owner reacts.

signal damaged(amount: float, current: float, max_hp: float)
signal healed(amount: float, current: float, max_hp: float)
signal died

@export var max_hp: float = 10.0

var current: float


func _ready() -> void:
	current = max_hp


func take_damage(amount: float) -> void:
	if amount <= 0.0 or current <= 0.0:
		return
	current = max(0.0, current - amount)
	damaged.emit(amount, current, max_hp)
	if current <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0 or current <= 0.0:
		return
	current = min(max_hp, current + amount)
	healed.emit(amount, current, max_hp)


func is_alive() -> bool:
	return current > 0.0


func set_max_hp(value: float, refill: bool = false) -> void:
	max_hp = max(1.0, value)
	if refill:
		current = max_hp
	else:
		current = min(current, max_hp)
