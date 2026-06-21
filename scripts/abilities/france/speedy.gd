class_name SpeedyAbility
extends Ability

@export var speed_multiplier: float = 2

var _timer: float = 0.0

func activate(player: CharacterBody2D) -> void:
	_timer = duration
	player.speed_modifier = speed_multiplier

func tick(player: CharacterBody2D, delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta
		if _timer <= 0.0:
			player.speed_modifier = 1.0

func get_time_remaining() -> float:
	return max(_timer, 0.0)

func reset(player: CharacterBody2D) -> void:
	_timer = 0.0
	player.speed_modifier = 1.0
