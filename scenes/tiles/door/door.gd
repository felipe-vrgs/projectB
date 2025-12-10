class_name Door
extends Node3D

@export var add_to_door_group: bool = true
@export var open_animation: StringName = "door_open"
@export var open_animation_alt: StringName = "door_open_2"

var is_open: bool = false

@onready var _anim_player: AnimationPlayer = $AnimationPlayer
var _current_open_anim: StringName = ""

func _ready() -> void:
	if add_to_door_group and not is_in_group("door"):
		add_to_group("door")

	_apply_state(is_open, true)

func open(instant: bool = false) -> void:
	_set_open_state(true, instant)

func close(instant: bool = false) -> void:
	_set_open_state(false, instant)

func toggle(instant: bool = false) -> void:
	_set_open_state(not is_open, instant)

func toggle_with_direction(direction: Vector3, instant: bool = false) -> void:
	_set_open_state_with_direction(not is_open, instant, direction)

func _set_open_state(target_open: bool, instant: bool) -> void:
	_set_open_state_with_direction(target_open, instant, Vector3.ZERO)

func _set_open_state_with_direction(target_open: bool, instant: bool, direction: Vector3) -> void:
	if is_open == target_open and not instant:
		return

	is_open = target_open
	_play_anim(target_open, direction)

func _apply_state(target_open: bool, _instant: bool) -> void:
	is_open = target_open
	_play_anim(target_open, Vector3.ZERO)

func _has_anim(anim_name: String) -> bool:
	return _anim_player and _anim_player.has_animation(anim_name)

func _pick_open_animation(direction: Vector3) -> StringName:
	var has_primary := _has_anim(open_animation)
	var has_alt := _has_anim(open_animation_alt)
	if not has_alt or direction == Vector3.ZERO:
		return open_animation if has_primary else (open_animation_alt if has_alt else StringName(""))
	var side := direction.dot(transform.basis.z)
	return open_animation if side >= 0.0 else open_animation_alt

func _play_anim(opening: bool, direction: Vector3) -> void:
	if not _anim_player:
		return
	
	var anim_name := ""
	if opening:
		anim_name = _pick_open_animation(direction)
		_current_open_anim = anim_name
	else:
		if _current_open_anim != "" and _has_anim(_current_open_anim):
			anim_name = _current_open_anim
		elif _has_anim(open_animation):
			anim_name = open_animation
		elif _has_anim(open_animation_alt):
			anim_name = open_animation_alt
		else:
			anim_name = ""
	
	if anim_name == "":
		return
	
	if opening:
		_anim_player.play(anim_name)
	else:
		_anim_player.play_backwards(anim_name)
