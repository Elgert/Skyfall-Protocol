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


func roll_choices(count: int = 3) -> Array[Resource]:
	# Naive uniform roll; weighting by rarity comes later.
	var pool := _all.duplicate()
	pool.shuffle()
	var out: Array[Resource] = []
	for i in min(count, pool.size()):
		out.append(pool[i])
	return out


func all_upgrades() -> Array[Resource]:
	return _all
