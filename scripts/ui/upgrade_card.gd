class_name UpgradeCard
extends PanelContainer
## A single clickable upgrade card. Set the upgrade via `setup()`,
## emits `selected(upgrade)` when the player picks it.

signal selected(upgrade: UpgradeResource)

@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var pick_button: Button = %PickButton

var _upgrade: UpgradeResource


func _ready() -> void:
	pick_button.pressed.connect(_on_pressed)


func setup(upgrade: UpgradeResource) -> void:
	_upgrade = upgrade
	# If the card was just instantiated, @onready vars might not be set yet —
	# defer the refresh to after _ready.
	if is_node_ready():
		_refresh()
	else:
		ready.connect(_refresh, CONNECT_ONE_SHOT)


func _refresh() -> void:
	name_label.text = _upgrade.display_name
	desc_label.text = _upgrade.description


func _on_pressed() -> void:
	selected.emit(_upgrade)
