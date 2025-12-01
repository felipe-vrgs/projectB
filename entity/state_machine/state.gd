class_name State
extends Node

signal animation_change_requested(animation_name: StringName)

const INPUT_DEADZONE := 0.1

@export var player_balance_config: PlayerBalanceConfig
@export var animation_name: StringName = &""

var parent: Player

func bind_player(new_player: Player) -> void:
	parent = new_player

func enter() -> void:
	if String(animation_name).is_empty():
		return
	animation_change_requested.emit(animation_name)
	if parent == null:
		return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> StringName:
	return &""

func process_frame(_delta: float) -> StringName:
	return &""

func process_physics(_delta: float) -> StringName:
	return &""

func apply_carried_momentum(_previous_velocity: Vector3) -> void:
	# Override in child states that need to preserve momentum
	pass