extends RigidBody2D

@export var pop_force: float = 1000.0
@export var pop_cooldown: float = 1.0
@export var contact_memory_time: float = 0.25 # how long a touch "counts" after it happened

var pop_timer: float = 0.0
var player_last_touch: Dictionary = {}  # player -> time since last touched

func _physics_process(delta: float) -> void:
	if pop_timer > 0.0:
		pop_timer -= delta
		return

	# Decay all remembered touches
	for player in player_last_touch.keys():
		player_last_touch[player] += delta

	# Record current-frame contacts
	var bodies := get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("players"):
			player_last_touch[body] = 0.0

	# Count how many players were touched "recently enough"
	var recent_count := 0
	for player in player_last_touch.keys():
		if player_last_touch[player] <= contact_memory_time:
			recent_count += 1

	if recent_count >= 2:
		apply_central_impulse(Vector2.UP * pop_force)
		pop_timer = pop_cooldown
		player_last_touch.clear()
