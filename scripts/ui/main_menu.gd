class_name MainMenu
extends Control

const SceneRouter := preload("res://scripts/systems/scene_router.gd")

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	start_button.grab_focus()


func _on_start() -> void:
	SceneRouter.goto_game(get_tree())


func _on_quit() -> void:
	SceneRouter.quit(get_tree())
