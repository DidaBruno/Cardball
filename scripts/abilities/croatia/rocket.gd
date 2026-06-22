class_name RocketAbility
extends Ability

@export var rocket_speed: float = 2000.0
@export var lock_duration: float = 0.2

func activate(player: CharacterBody2D) -> void:
	player.velocity.x = player.facing_direction * rocket_speed
	player.ability_movement_lock = lock_duration

func tick(player: CharacterBody2D, delta: float) -> void:
	pass  # one-time burst, nothing to tick over time

func get_time_remaining() -> float:
	return 0.0  # instant effect, no duration to display

func reset(player: CharacterBody2D) -> void:
	pass  # nothing to revert, since it's not a sustained effect
