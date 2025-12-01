class_name RunState
extends State

const StateNames = preload("res://entity/player/states/state_names.gd")

func process_physics(delta: float) -> StringName:
	if parent == null or parent.balance_config == null:
		return StateNames.NONE

	# State transition check
	if not parent.is_on_floor():
		return StateNames.FALL

	# Get input direction
	var input_dir := parent.get_input_direction()

	# Check if still running
	var is_running := parent.movement.is_running(input_dir)

	# Apply horizontal movement
	var target_speed := parent.balance_config.run_speed if is_running else parent.balance_config.walk_speed
	parent.movement.apply_horizontal_movement(delta, target_speed)

	# Check for jump from buffer (coyote time or jump buffer)
	if parent.movement.can_jump_from_buffer():
		return StateNames.JUMP

	# State transitions
	if input_dir.length() < parent.balance_config.walk_threshold:
		return StateNames.IDLE
	if not is_running:
		return StateNames.WALK

	return StateNames.NONE

func process_input(event: InputEvent) -> StringName:
	if parent == null or not parent.movement:
		return StateNames.NONE

	# Check for jump input
	if parent.movement.can_jump(event):
		return StateNames.JUMP

	return StateNames.NONE

