class_name VirtualJoystick
extends Control
## Floating joystick: invisible until touched. On first touch anywhere in this
## Control's rect (the whole screen, minus the boost button which is drawn on
## top), a circular base appears at the touch point. Drag the finger to move
## the knob within the base radius.
##
## Boost button sits on top of this Control in the scene; its taps are
## consumed there, so they never reach _gui_input here.

@export var stick_radius: float = 90.0
@export var deadzone: float = 0.18

@onready var base: Panel = $Base
@onready var knob: Panel = $Base/Knob

var _touch_index: int = -1
var _value: Vector2 = Vector2.ZERO
var _last_actions: Dictionary = {
	&"move_left": 0.0,
	&"move_right": 0.0,
	&"move_up": 0.0,
	&"move_down": 0.0,
}


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	base.hide()
	_center_knob()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var t: InputEventScreenTouch = event
		if t.pressed:
			if _touch_index == -1:
				_touch_index = t.index
				_begin_at(t.position)
				accept_event()
		else:
			if t.index == _touch_index:
				_end()
				accept_event()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_from_position(event.position)
			accept_event()


func _begin_at(touch_pos: Vector2) -> void:
	# Position the base on the touch point for math, but never show it.
	base.position = touch_pos - global_position - base.size * 0.5
	_center_knob()
	_value = Vector2.ZERO
	_push_input()


func _update_from_position(touch_pos: Vector2) -> void:
	var center := base.global_position + base.size * 0.5
	var v: Vector2 = touch_pos - center
	if v.length() > stick_radius:
		v = v.normalized() * stick_radius
	knob.position = base.size * 0.5 + v - knob.size * 0.5
	_value = v / stick_radius
	if _value.length() < deadzone:
		_value = Vector2.ZERO
	_push_input()


func _end() -> void:
	_touch_index = -1
	_value = Vector2.ZERO
	base.hide()
	_push_input()


func _center_knob() -> void:
	knob.position = base.size * 0.5 - knob.size * 0.5


func _push_input() -> void:
	_set_action(&"move_left", maxf(0.0, -_value.x))
	_set_action(&"move_right", maxf(0.0, _value.x))
	_set_action(&"move_up", maxf(0.0, -_value.y))
	_set_action(&"move_down", maxf(0.0, _value.y))


func _set_action(action: StringName, strength: float) -> void:
	var prev: float = _last_actions.get(action, 0.0)
	if strength > 0.0:
		Input.action_press(action, strength)
	elif prev > 0.0:
		Input.action_release(action)
	_last_actions[action] = strength
