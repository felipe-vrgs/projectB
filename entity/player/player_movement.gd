class_name PlayerMovement
extends RefCounted

## Handles base movement tech like jumping, horizontal movement, and air movement
## This will be extended with more movement features over time

const INPUT_DEADZONE := 0.1

var parent: Player
var coyote_time_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var landing_impact_timer: float = 0.0
var just_landed: bool = false

func _init(player: Player) -> void:
	parent = player

## Check if jump input was just pressed from an input event
func is_jump_input_pressed(event: InputEvent) -> bool:
	if not parent or not parent.input_config:
		return false
	return event.is_action_pressed(parent.input_config.action_jump)

## Check if the player is on floor
func is_on_floor() -> bool:
	if not parent:
		return false
	return parent.is_on_floor()

## Update coyote time and jump buffer timers (call every frame)
func update_timers(delta: float) -> void:
	if not parent or not parent.balance_config:
		return

	var is_on_ground := is_on_floor()

	# Handle coyote time (time after leaving ground where jump still works)
	if was_on_floor and not is_on_ground:
		coyote_time_timer = parent.balance_config.coyote_time
	elif is_on_ground:
		coyote_time_timer = 0.0
	else:
		coyote_time_timer = max(0.0, coyote_time_timer - delta)

	# Handle jump buffer (time before landing where jump input is remembered)
	if is_jump_input_just_pressed():
		jump_buffer_timer = parent.balance_config.jump_buffer_time
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	was_on_floor = is_on_ground

	# Handle landing impact
	if just_landed:
		landing_impact_timer = max(0.0, landing_impact_timer - delta)
		if landing_impact_timer <= 0.0:
			just_landed = false

## Check if jump input was just pressed (for jump buffering)
func is_jump_input_just_pressed() -> bool:
	if not parent or not parent.input_config:
		return false
	return Input.is_action_just_pressed(parent.input_config.action_jump)

## Check if the player can jump from jump buffer (called in physics process)
func can_jump_from_buffer() -> bool:
	if not parent or not parent.balance_config:
		return false

	var has_jump_buffer := jump_buffer_timer > 0.0
	var can_jump_from_ground := is_on_floor() or coyote_time_timer > 0.0

	if has_jump_buffer and can_jump_from_ground:
		# Consume coyote time and jump buffer
		coyote_time_timer = 0.0
		jump_buffer_timer = 0.0
		return true

	return false

## Check if the player can jump (has input event, on floor/coyote time, and has balance config)
func can_jump(event: InputEvent) -> bool:
	if not parent or not parent.balance_config:
		return false

	var has_jump_input := is_jump_input_pressed(event) or jump_buffer_timer > 0.0
	var can_jump_from_ground := is_on_floor() or coyote_time_timer > 0.0

	if has_jump_input and can_jump_from_ground:
		# Consume coyote time and jump buffer
		coyote_time_timer = 0.0
		jump_buffer_timer = 0.0
		return true

	return false

## Convert 2D input direction to 3D movement direction relative to player rotation
func get_movement_direction(input_dir: Vector2) -> Vector3:
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	if direction.length() > 0.001:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO
	direction = direction.rotated(Vector3.UP, parent.rotation.y)
	return direction

## Check if player is running based on input
func is_running(input_dir: Vector2) -> bool:
	if not parent or not parent.input_config or not parent.balance_config:
		return false
	return Input.is_action_pressed(parent.input_config.action_run) and input_dir.length() > parent.balance_config.run_threshold

## Apply horizontal ground movement with acceleration/friction
func apply_horizontal_movement(delta: float, target_speed: float) -> void:
	if not parent or not parent.balance_config:
		return

	# Apply landing impact slowdown if just landed
	var speed_multiplier := 1.0
	if just_landed and landing_impact_timer > 0.0:
		speed_multiplier = parent.balance_config.landing_impact_slowdown

	var input_dir := parent.get_input_direction()
	var direction := get_movement_direction(input_dir)
	var target_velocity := direction * target_speed * speed_multiplier if direction.length() > 0.001 else Vector3.ZERO
	var current_horizontal_velocity := Vector3(parent.velocity.x, 0, parent.velocity.z)

	var has_input := input_dir.length() > INPUT_DEADZONE
	var acceleration_rate := parent.balance_config.acceleration if has_input else parent.balance_config.friction
	current_horizontal_velocity = current_horizontal_velocity.move_toward(target_velocity, acceleration_rate * delta)

	# Snap to zero if velocity is very small (prevent micro-sliding)
	if not has_input and current_horizontal_velocity.length() < 0.1:
		current_horizontal_velocity = Vector3.ZERO

	parent.velocity.x = current_horizontal_velocity.x
	parent.velocity.z = current_horizontal_velocity.z

## Apply air movement with air acceleration
func apply_air_movement(delta: float, target_speed: float) -> void:
	if not parent or not parent.balance_config:
		return

	var input_dir := parent.get_input_direction()
	if input_dir.length() > INPUT_DEADZONE:
		var direction := get_movement_direction(input_dir)
		var current_horizontal_velocity := Vector3(parent.velocity.x, 0, parent.velocity.z)
		var target_velocity := direction * target_speed

		current_horizontal_velocity = current_horizontal_velocity.move_toward(
			target_velocity,
			parent.balance_config.air_acceleration * delta
		)

		parent.velocity.x = current_horizontal_velocity.x
		parent.velocity.z = current_horizontal_velocity.z

## Called when player lands (from fall state)
func on_landed() -> void:
	if not parent or not parent.balance_config:
		return
	just_landed = true
	landing_impact_timer = parent.balance_config.landing_impact_duration
	# Apply landing impact to horizontal velocity
	var horizontal_velocity := Vector3(parent.velocity.x, 0, parent.velocity.z)
	horizontal_velocity *= parent.balance_config.landing_impact_slowdown
	parent.velocity.x = horizontal_velocity.x
	parent.velocity.z = horizontal_velocity.z

## Apply friction to horizontal velocity
func apply_friction(delta: float) -> void:
	if not parent or not parent.balance_config:
		return

	parent.velocity.x = move_toward(parent.velocity.x, 0.0, parent.balance_config.friction * delta)
	parent.velocity.z = move_toward(parent.velocity.z, 0.0, parent.balance_config.friction * delta)

	# Snap to zero if velocity is very small (prevent micro-sliding)
	var horizontal_velocity := Vector3(parent.velocity.x, 0, parent.velocity.z)
	if horizontal_velocity.length() < 0.1:
		parent.velocity.x = 0.0
		parent.velocity.z = 0.0

