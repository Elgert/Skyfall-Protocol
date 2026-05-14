extends Node2D
## Root script for the gameplay scene. Kicks off the run.


func _ready() -> void:
	GameManager.start_run()
