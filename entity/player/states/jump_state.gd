class_name JumpState
extends State

const StateNames = preload("res://entity/player/states/state_names.gd")

func enter() -> void:
	if parent == null or not parent.balance_config:
		return
	parent.velocity.y = parent.balance_config.jump_velocity
	super.enter()

func process_physics(delta: float) -> StringName:
	if parent == null or parent.balance_config == null:
		return StateNames.NONE

	# Apply air movement
	parent.movement.apply_air_movement(delta, parent.balance_config.run_speed)

	# State transitions
	if parent.velocity.y < 0.0:
		return StateNames.FALL

	return StateNames.NONE

