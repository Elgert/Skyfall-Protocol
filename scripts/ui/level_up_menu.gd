class_name LevelUpMenu
extends CanvasLayer
## Shows on player_leveled_up. Rolls 3 upgrades, lets the player pick one,
## applies it, then resumes the game.

const CARD_SCENE: PackedScene = preload("res://scenes/ui/upgrade_card.tscn")

@onready var root: Control = $Root
@onready var card_row: HBoxContainer = %CardRow


func _ready() -> void:
	# This menu must run while the game tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.hide()
	EventBus.player_leveled_up.connect(_on_level_up)


func _on_level_up(_new_level: int) -> void:
	_clear_cards()
	var choices := UpgradeDatabase.roll_choices(3)
	if choices.is_empty():
		# Nothing to offer — just resume.
		GameManager.resume_from_level_up()
		return
	for upgrade in choices:
		var card: UpgradeCard = CARD_SCENE.instantiate()
		card_row.add_child(card)
		card.setup(upgrade)
		card.selected.connect(_on_card_selected)
	root.show()


func _on_card_selected(upgrade: UpgradeResource) -> void:
	var player := _get_player()
	if player != null and player.stats != null:
		upgrade.apply_to(player.stats, player)
	EventBus.upgrade_chosen.emit(upgrade)
	root.hide()
	_clear_cards()
	GameManager.resume_from_level_up()


func _clear_cards() -> void:
	for c in card_row.get_children():
		c.queue_free()


func _get_player() -> Player:
	var players := get_tree().get_nodes_in_group(&"player")
	if players.is_empty():
		return null
	return players[0] as Player
