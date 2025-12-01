class_name FallState
extends State

const StateNames = preload("res://entity/player/states/state_names.gd")

func process_physics(delta: float) -> StringName:
	if parent == null or parent.balance_config == null:
		return StateNames.NONE

	# Apply air friction when not giving input
	var input_dir := parent.get_input_direction()
	if input_dir.length() <= INPUT_DEADZONE:
		parent.velocity.x = move_toward(parent.velocity.x, 0.0, parent.balance_config.air_friction * delta)
		parent.velocity.z = move_toward(parent.velocity.z, 0.0, parent.balance_config.air_friction * delta)
	else:
		# Apply air movement
		parent.movement.apply_air_movement(delta, parent.balance_config.run_speed)

	# State transitions
	if parent.is_on_floor():
		# Handle landing impact
		if parent.movement:
			parent.movement.on_landed()

		var input_dir_check := parent.get_input_direction()
		if input_dir_check.length() < parent.balance_config.walk_threshold:
			return StateNames.IDLE
		return StateNames.WALK

	return StateNames.NONE
