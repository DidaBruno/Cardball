extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 1200.0
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.15
@export var double_tap_window: float = 0.25
@export var dash_cooldown: float = 0.5

var dash_timer: float = 0.0
var dash_direction: float = 0.0

var last_left_press_time: float = -1.0
var last_right_press_time: float = -1.0

var dash_cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("p1_jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	# Detect double-taps
	if Input.is_action_just_pressed("p1_left"):
		var now := Time.get_ticks_msec() / 1000
		if now - last_left_press_time <= double_tap_window and dash_cooldown_timer <= 0.0:
			_start_dash(-1.0)
		last_left_press_time = now
	if Input.is_action_just_pressed("p1_right"):
		var now := Time.get_ticks_msec() / 1000
		if now - last_right_press_time <= double_tap_window and dash_cooldown_timer <= 0.0:
			_start_dash(1.0)
		last_right_press_time = now
	
	# Dash overrides normal horizontal movement while active
	if dash_timer > 0.0:
		dash_timer -= delta
		velocity.x = dash_direction * dash_speed
	
	# If there are no double taps, move normally
	else:
		var direction := Input.get_axis("p1_left", "p1_right")
		velocity.x = direction * speed

	move_and_slide()

func _start_dash(direction:float) -> void:
	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
