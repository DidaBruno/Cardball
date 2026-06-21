class_name Ability
extends Resource

## Base class for all player abilities
## Each specific ability extends this and overrides activate()/tick() as needed.

@export var ability_name: String = ""
@export var duration: float = 0.0  # how long the effect lasts, 0 = instant/no duration

# Called once, the instant the ability is activated (bar was full, player pressed the key).
func activate(player: CharacterBody2D) -> void:
	pass

# Called every physics frame while this ability is equipped, regardless of whether
# it's currently "active" - useful for counting down internal timers and reverting
# effects when they expire. Override and check your own internal timer.
func tick(player: CharacterBody2D, delta: float) -> void:
	pass

func get_time_remaining() -> float:
	return 0.0

func reset(player: CharacterBody2D) -> void:
	pass
