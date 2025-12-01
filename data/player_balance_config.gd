class_name PlayerBalanceConfig
extends Resource

## Movement settings
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var acceleration: float = 30.0
@export var friction: float = 15.0
@export var air_acceleration: float = 5.0
@export var air_friction: float = 2.0

## Jump settings
@export_group("Jump")
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var coyote_time: float = 0.15  # Time after leaving ground where jump still works
@export var jump_buffer_time: float = 0.1  # Time before landing where jump input is remembered

## Landing settings
@export_group("Landing")
@export var landing_impact_slowdown: float = 0.7  # Multiplier for velocity on landing (0.7 = 30% slowdown)
@export var landing_impact_duration: float = 0.15  # How long landing impact lasts

## Mouse look settings
@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.003
@export var vertical_look_limit: float = 1.4  # In radians (~80 degrees)

## Input thresholds
@export_group("Input")
@export var walk_threshold: float = 0.3
@export var run_threshold: float = 0.8
