class_name IdleState
extends State

const StateNames = preload("res://entity/player/states/state_names.gd")

func process_physics(delta: float) -> StringName:
	if parent == null or parent.balance_config == null:
		return StateNames.NONE

	# State transition check
	if not parent.is_on_floor():
		return StateNames.FALL

	# Apply friction aggressively
	parent.movement.apply_friction(delta)

	# Check for jump from buffer (coyote time or jump buffer)
	if parent.movement.can_jump_from_buffer():
		return StateNames.JUMP

	# Check for input
	var input_dir := parent.get_input_direction()
	if input_dir.length() > parent.balance_config.walk_threshold:
		return StateNames.WALK

	return StateNames.NONE

func process_input(event: InputEvent) -> StringName:
	if parent == null or not parent.movement:
		return StateNames.NONE

	# Check for jump input
	if parent.movement.can_jump(event):
		return StateNames.JUMP

	return StateNames.NONE
