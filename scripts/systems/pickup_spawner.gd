class_name PickupSpawner
extends Node
## Listens to EventBus.enemy_died and spawns XP gems at the death position.
## Decouples enemies from pickup spawning — enemies just announce death.

const XP_GEM_SCENE: PackedScene = preload("res://scenes/pickups/xp_gem.tscn")


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(_enemy: Node, position: Vector2, xp_value: int) -> void:
	var gem: XPGem = XP_GEM_SCENE.instantiate()
	gem.xp_value = xp_value
	_get_container().add_child(gem)
	gem.global_position = position


## Spawn into the "pickup_container" group if present; otherwise current scene.
func _get_container() -> Node:
	var groups := get_tree().get_nodes_in_group(&"pickup_container")
	if not groups.is_empty():
		return groups[0]
	return get_tree().current_scene
