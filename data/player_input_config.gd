class_name PlayerInputConfig
extends Resource

## Movement actions
@export var action_move_left: StringName = "move_left"
@export var action_move_right: StringName = "move_right"
@export var action_move_forward: StringName = "move_forward"
@export var action_move_back: StringName = "move_back"
@export var action_jump: StringName = "jump"
@export var action_run: StringName = "run"
@export var action_toggle_lantern: StringName = "toggle_lantern"
@export var action_interact: StringName = "interact"

## Movement keys
@export var move_left_keys: Array[Key] = [KEY_A]
@export var move_right_keys: Array[Key] = [KEY_D]
@export var move_forward_keys: Array[Key] = [KEY_W]
@export var move_back_keys: Array[Key] = [KEY_S]
@export var jump_keys: Array[Key] = [KEY_SPACE]
@export var run_keys: Array[Key] = [KEY_SHIFT]
@export var toggle_lantern_keys: Array[Key] = [KEY_F]
@export var interact_keys: Array[Key] = [KEY_E]

func _get_keyboard_actions_map() -> Dictionary:
	return {
		action_move_left: move_left_keys,
		action_move_right: move_right_keys,
		action_move_forward: move_forward_keys,
		action_move_back: move_back_keys,
		action_jump: jump_keys,
		action_run: run_keys,
		action_toggle_lantern: toggle_lantern_keys,
		action_interact: interact_keys,
	}

func ensure_actions_registered() -> void:
	var keyboard_actions_map = _get_keyboard_actions_map()
	for action_name in keyboard_actions_map.keys():
		_register_key_bindings(action_name, keyboard_actions_map[action_name])

func _register_key_bindings(action_name: StringName, keys: Array[Key]) -> void:
	_ensure_action_exists(action_name)
	for keycode in keys:
		if _has_key_event(action_name, keycode):
			continue

		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action_name, event)

static func _ensure_action_exists(action_name: StringName) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

static func _has_key_event(action_name: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false

