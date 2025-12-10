class_name Player
extends CharacterBody3D

@export var balance_config: PlayerBalanceConfig
@export var input_config: PlayerInputConfig
@export var interact_distance: float = 3.0

## First-person camera controls
var mouse_captured: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var state_machine: StateMachine = $StateMachine
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var lantern: SpotLight3D = $Head/Lantern

var movement: PlayerMovement
var lantern_enabled: bool = true
## Head bobbing
var head_bob_timer: float = 0.0
var original_head_position: Vector3

func _ready() -> void:
	# Create default resources if not set in editor
	if not balance_config:
		balance_config = PlayerBalanceConfig.new()
	if not input_config:
		input_config = PlayerInputConfig.new()

	if input_config:
		input_config.ensure_actions_registered()

	# Initialize movement handler
	movement = PlayerMovement.new(self)
	
	# Hide character mesh in first-person view
	if mesh_instance:
		mesh_instance.visible = false
	
	capture_mouse()
	if state_machine:
		if not state_machine.is_connected("state_binding_requested", Callable(self, "_on_state_binding_requested")):
			state_machine.state_binding_requested.connect(_on_state_binding_requested)
		state_machine.init()
	
	# Store original head position for bobbing
	if head:
		original_head_position = head.position
	
	# Initialize lantern (starts enabled)
	if lantern:
		lantern.visible = lantern_enabled

func _input(event: InputEvent) -> void:
	if state_machine:
		state_machine.process_input(event)

	if event is InputEventMouseMotion and mouse_captured:
		_handle_mouse_look(event)

	if event.is_action_pressed("ui_cancel"):  # ESC key
		release_mouse()

	if event.is_action_pressed("ui_accept") and not mouse_captured:  # Click to capture
		capture_mouse()
	
	# Toggle lantern
	if event.is_action_pressed("toggle_lantern"):
		toggle_lantern()
	
	# Interact (doors)
	if input_config and event.is_action_pressed(input_config.action_interact):
		_try_interact()

func _physics_process(delta: float) -> void:
	# Process state machine first (handles jump input and movement)
	if state_machine:
		state_machine.process_physics(delta)

	# Apply gravity consistently (after state processing, so jump isn't overridden)
	if balance_config:
		if not is_on_floor():
			velocity.y -= balance_config.gravity * delta
		else:
			# Only zero upward velocity if it's very small (prevent bounces)
			# Don't zero if velocity is close to jump_velocity (we just jumped)
			if velocity.y > 0 and velocity.y < 2.0:
				velocity.y = 0

	# Move after all physics calculations
	move_and_slide()

func _process(delta: float) -> void:
	# Update movement timers (coyote time, jump buffer, landing impact)
	if movement:
		movement.update_timers(delta)

	if state_machine:
		state_machine.process_frame(delta)
	
	# Update head bobbing
	_update_head_bobbing(delta)

func _handle_mouse_look(event: InputEventMouseMotion) -> void:
	if not balance_config or not head:
		return

	# Horizontal rotation (Y-axis)
	rotate_y(-event.relative.x * balance_config.mouse_sensitivity)

	# Vertical rotation (X-axis) - clamped to prevent over-rotation
	head.rotate_x(-event.relative.y * balance_config.mouse_sensitivity)
	var vertical_limit = balance_config.vertical_look_limit
	head.rotation.x = clamp(head.rotation.x, -vertical_limit, vertical_limit)

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

func _on_state_binding_requested(state: State) -> void:
	state.bind_player(self)

func get_input_direction() -> Vector2:
	if not input_config:
		return Vector2.ZERO
	# Use the input config's action names directly
	return Input.get_vector(
		input_config.action_move_left,
		input_config.action_move_right,
		input_config.action_move_forward,
		input_config.action_move_back
	)

func is_action_pressed(action: StringName) -> bool:
	if not input_config:
		return false
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: StringName) -> bool:
	if not input_config:
		return false
	return Input.is_action_just_pressed(action)

func _update_head_bobbing(delta: float) -> void:
	if not balance_config or not head or not balance_config.head_bob_enabled:
		return
	
	# Only bob when moving on the ground
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var speed := horizontal_velocity.length()
	var is_moving := speed > 0.1
	var is_on_ground := is_on_floor()
	
	# Determine if we should bob (walking or running on ground)
	var should_bob := false
	var bob_intensity := 0.0
	
	if is_moving and is_on_ground and state_machine and state_machine.current_state:
		var state_name := state_machine.current_state.name
		
		# Bob when walking or running
		if state_name == &"Walk":
			should_bob = true
			bob_intensity = balance_config.walk_bob_intensity
		elif state_name == &"Run":
			should_bob = true
			bob_intensity = balance_config.run_bob_intensity
	
	if should_bob:
		# Update timer based on movement speed (faster = more frequent)
		var speed_ratio := speed / balance_config.run_speed
		head_bob_timer += delta * balance_config.bob_frequency * (1.0 + speed_ratio)
		
		# Calculate vertical bobbing (sine wave)
		var vertical_offset := sin(head_bob_timer) * bob_intensity
		
		# Calculate horizontal bobbing (subtle side-to-side, phase-shifted)
		var horizontal_offset := cos(head_bob_timer * 0.5) * balance_config.bob_horizontal_intensity * speed_ratio
		
		# Apply bobbing offset
		head.position = original_head_position + Vector3(horizontal_offset, vertical_offset, 0.0)
	else:
		# Smoothly return to original position when not moving
		head_bob_timer = 0.0
		head.position = head.position.lerp(original_head_position, delta * 10.0)

func toggle_lantern() -> void:
	if not lantern:
		return
	lantern_enabled = not lantern_enabled
	lantern.visible = lantern_enabled

func _try_interact() -> void:
	# Prefer a raycast hit (more accurate when close or looking directly)
	var door := _raycast_door()
	# Fallback to cone search if nothing was hit but something is nearby
	if not door:
		return
	var forward := Vector3.ZERO
	if camera:
		forward = -camera.global_transform.basis.z
	if door.has_method("toggle_with_direction"):
		door.toggle_with_direction(forward, false)
	else:
		door.toggle()

func _raycast_door() -> Door:
	if not camera:
		return null
	var origin: Vector3 = camera.global_transform.origin
	var forward: Vector3 = -camera.global_transform.basis.z
	# Nudge the start point forward so we don't start inside the door collider
	var start := origin + forward * 0.2
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(start, origin + forward * interact_distance)
	var result := space_state.intersect_ray(query)
	if result and result.has("collider"):
		var collider = result["collider"]
		return _extract_door_from_node(collider)
	return null

func _extract_door_from_node(node: Object) -> Door:
	var current := node as Node
	while current:
		if current is Door:
			return current
		if current.is_in_group("door"):
			return current as Door
		current = current.get_parent()
	return null
