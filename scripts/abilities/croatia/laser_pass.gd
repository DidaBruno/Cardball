class_name LaserPassAbility
extends Ability

@export var laser_force: float = 2000.0
@export var window_duration: float = 5.0
@export var flat_duration: float = 0.6

var _timer: float = 0.0

func activate(player: CharacterBody2D) -> void:
	_timer = window_duration

func tick(player: CharacterBody2D, delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta

func get_time_remaining() -> float:
	return max(_timer, 0.0)

func reset(player: CharacterBody2D) -> void:
	_timer = 0.0

func on_kick(player: CharacterBody2D, ball: RigidBody2D, kick_direction: Vector2, default_force: float) -> bool:
	if _timer > 0.0 and ball.has_method("launch"):
		ball.launch(kick_direction, laser_force, flat_duration)
		_timer = 0.0
		return true
	return false
