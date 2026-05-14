extends Node
## Owns high-level run state and the elapsed timer.
## Scene transitions and pause control live here so no gameplay node needs to know about them.

enum State { MENU, RUNNING, PAUSED, LEVEL_UP, GAME_OVER }

var state: State = State.MENU
var elapsed: float = 0.0


func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)


func _process(delta: float) -> void:
	if state == State.RUNNING:
		elapsed += delta


func start_run() -> void:
	elapsed = 0.0
	state = State.RUNNING
	get_tree().paused = false
	EventBus.run_started.emit()


func end_run() -> void:
	state = State.GAME_OVER
	get_tree().paused = true
	EventBus.run_ended.emit(elapsed)


func pause_for_level_up() -> void:
	state = State.LEVEL_UP
	get_tree().paused = true


func resume_from_level_up() -> void:
	state = State.RUNNING
	get_tree().paused = false


func _on_player_died() -> void:
	end_run()


func _on_player_leveled_up(_new_level: int) -> void:
	pause_for_level_up()
