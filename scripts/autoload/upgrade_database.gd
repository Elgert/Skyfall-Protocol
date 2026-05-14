extends Node
## Loads all UpgradeResource files from res://resources/upgrades and rolls choices on level-up.
## Resources are the source of truth — add a .tres, it shows up in the picker.

const UPGRADE_DIR := "res://resources/upgrades"

var _all: Array[Resource] = []


func _ready() -> void:
	_load_all()


func _load_all() -> void:
	_all.clear()
	var dir := DirAccess.open(UPGRADE_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".tres"):
			var res := load(UPGRADE_DIR.path_join(name))
			if res != null:
				_all.append(res)
		name = dir.get_next()


func roll_choices(count: int = 3, player: Node = null) -> Array[Resource]:
	# Filter by eligibility (weapon-locked upgrades, already-owned unlocks).
	var pool: Array[Resource] = []
	for r in _all:
		if r is UpgradeResource and _is_eligible(r, player):
			pool.append(r)
	pool.shuffle()
	var out: Array[Resource] = []
	for i in min(count, pool.size()):
		out.append(pool[i])
	return out


func _is_eligible(u: UpgradeResource, player: Node) -> bool:
	if player == null:
		return u.requires_weapon_id == &"" and u.weapon_unlock_resource == null
	# Skip upgrades that require an unowned weapon.
	if u.requires_weapon_id != &"" and not player.has_weapon(u.requires_weapon_id):
		return false
	# Skip unlock upgrades for weapons the player already owns.
	if u.weapon_unlock_resource != null and player.has_weapon(u.weapon_unlock_resource.id):
		return false
	return true


func all_upgrades() -> Array[Resource]:
	return _all
