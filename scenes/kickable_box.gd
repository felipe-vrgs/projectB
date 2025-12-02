class_name KickableBox
extends RigidBody3D

@export var kick_force_multiplier: float = 2.0
@export var min_kick_velocity: float = 0.5
@export var detection_distance: float = 1.5

var last_collision_time: float = 0.0
var collision_cooldown: float = 0.2
var player: CharacterBody3D = null
var detection_area: Area3D = null

func _ready() -> void:
	# Try to get the detection area if it exists
	if has_node("DetectionArea"):
		detection_area = $DetectionArea
		if detection_area:
			detection_area.body_entered.connect(_on_body_entered)
			detection_area.body_exited.connect(_on_body_exited)
	
	# Also search for player in scene tree
	_find_player()

func _find_player() -> void:
	var main = get_tree().get_first_node_in_group("player")
	if not main:
		# Try finding by name in scene
		var bunker = get_parent().get_parent()  # Go up to Bunker node
		if bunker:
			var main_scene = bunker.get_parent()
			if main_scene:
				player = main_scene.get_node_or_null("Player")

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D and (body.name == "Player" or body.is_in_group("player")):
		player = body

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody3D and (body.name == "Player" or body.is_in_group("player")):
		if player == body:
			player = null

func _physics_process(_delta: float) -> void:
	# If no player found via Area3D, try to find it
	if not player:
		_find_player()
		if not player:
			return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Prevent multiple collisions in quick succession
	if current_time - last_collision_time < collision_cooldown:
		return
	
	# Check distance to player
	var distance = global_position.distance_to(player.global_position)
	if distance > detection_distance:
		return
	
	# Check if player is moving fast enough to kick
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	if horizontal_velocity.length() > min_kick_velocity:
		last_collision_time = current_time
		_apply_kick_force(player)

func _apply_kick_force(player_body: CharacterBody3D) -> void:
	# Get player's horizontal velocity (ignore vertical for more predictable kicks)
	var horizontal_velocity = Vector3(player_body.velocity.x, 0, player_body.velocity.z)
	
	if horizontal_velocity.length() < min_kick_velocity:
		return
	
	# Calculate direction from player to box (use player's movement direction)
	var direction = horizontal_velocity.normalized()
	
	# Use player's horizontal velocity to determine kick strength
	var kick_force = horizontal_velocity.length() * kick_force_multiplier
	
	# Apply impulse to the box in the direction the player is moving
	apply_central_impulse(direction * kick_force)
