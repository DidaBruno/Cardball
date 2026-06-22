class_name HeaderAbility
extends Ability

@export var header_force: float = 1600.0

var _timer: float = 0.0

func activate(player: CharacterBody2D) -> void:
	_timer = duration

func tick(player: CharacterBody2D, delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta

func get_time_remaining() -> float:
	return max(_timer, 0.0)

func reset(player: CharacterBody2D) -> void:
	_timer = 0.0

func on_head_contact(player: CharacterBody2D, ball: RigidBody2D, contact_direction: Vector2) -> bool:
	if _timer > 0.0 and ball.has_method("launch"):
		ball.launch(contact_direction, header_force, 0.0)
		return true
	return false
