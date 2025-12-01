class_name Player
extends CharacterBody3D

@export var balance_config: PlayerBalanceConfig
@export var input_config: PlayerInputConfig

## First-person camera controls
var mouse_captured: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var state_machine: StateMachine = $StateMachine
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var movement: PlayerMovement

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
		state_machine.state_binding_requested.connect(_on_state_binding_requested)
		state_machine.init()

func _input(event: InputEvent) -> void:
	if state_machine:
		state_machine.process_input(event)

	if event is InputEventMouseMotion and mouse_captured:
		_handle_mouse_look(event)

	if event.is_action_pressed("ui_cancel"):  # ESC key
		release_mouse()

	if event.is_action_pressed("ui_accept") and not mouse_captured:  # Click to capture
		capture_mouse()

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
