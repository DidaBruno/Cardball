extends CharacterBody2D

@export var input_prefix: String = "p1"
@export var facing_direction: float = 1.0  # 1 = facing right, -1 = facing left

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 1200.0
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.15
@export var double_tap_window: float = 0.25
@export var dash_cooldown: float = 0.5
@export var kick_force: float = 600.0

@onready var kick_zone: Area2D = $KickZone
@onready var sprite: Sprite2D = $Sprite2D

var dash_timer: float = 0.0
var dash_direction: float = 0.0

var last_left_press_time: float = -1.0
var last_right_press_time: float = -1.0

var dash_cooldown_timer: float = 0.0

func _ready() -> void:
	kick_zone.position.x = abs(kick_zone.position.x) * facing_direction
	sprite.flip_h = facing_direction < 0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed(input_prefix + "_jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	# Detect double-taps
	if Input.is_action_just_pressed(input_prefix + "_left"):
		var now := Time.get_ticks_msec() / 1000
		if now - last_left_press_time <= double_tap_window and dash_cooldown_timer <= 0.0:
			_start_dash(-1.0)
		last_left_press_time = now
	if Input.is_action_just_pressed(input_prefix + "_right"):
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
		var direction := Input.get_axis(input_prefix + "_left", input_prefix + "_right")
		velocity.x = direction * speed

	move_and_slide()
	
	if Input.is_action_just_pressed(input_prefix + "_kick"):
		_try_kick()

func _start_dash(direction:float) -> void:
	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func _try_kick() -> void:
	for body in kick_zone.get_overlapping_bodies():
		if body is RigidBody2D:
			var kick_direction := (body.global_position - global_position).normalized()
			body.apply_central_impulse(kick_direction * kick_force)
