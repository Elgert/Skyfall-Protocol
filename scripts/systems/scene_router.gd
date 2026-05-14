extends Node
## Helper for scene transitions. Unpauses the tree before changing scenes
## so a paused run-end overlay doesn't carry over.

const MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const MAIN := "res://scenes/main.tscn"


static func goto_main_menu(tree: SceneTree) -> void:
	tree.paused = false
	tree.change_scene_to_file(MAIN_MENU)


static func goto_game(tree: SceneTree) -> void:
	tree.paused = false
	tree.change_scene_to_file(MAIN)


static func quit(tree: SceneTree) -> void:
	tree.quit()
