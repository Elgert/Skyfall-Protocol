class_name GameOverMenu
extends CanvasLayer

const SceneRouter := preload("res://scripts/systems/scene_router.gd")

@onready var root: Control = $Root
@onready var time_label: Label = %TimeLabel
@onready var level_label: Label = %LevelLabel
@onready var kills_label: Label = %KillsLabel
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.hide()
	EventBus.run_ended.connect(_on_run_ended)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)


func _on_run_ended(survived: float) -> void:
	time_label.text = "Time: %s" % _format_time(survived)
	level_label.text = "Level: %d" % RunStats.level
	kills_label.text = "Kills: %d" % RunStats.kills
	root.show()
	retry_button.grab_focus()


func _on_retry() -> void:
	SceneRouter.goto_game(get_tree())


func _on_menu() -> void:
	SceneRouter.goto_main_menu(get_tree())


func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	var m := total / 60
	var s := total % 60
	return "%02d:%02d" % [m, s]
