extends Node2D

@onready var goal_left: Area2D = $GoalLeft
@onready var goal_right: Area2D = $GoalRight
@onready var match_timer: Timer = $MatchTimer
@onready var timer_label: Label = $TimerLabel
@onready var result_label: Label = $ResultLabel
@onready var player1: CharacterBody2D = $Player1
@onready var player2: CharacterBody2D = $Player2
@onready var ball: RigidBody2D = $Ball

var match_over: bool = false

func _ready() -> void:
	result_label.visible = false
	goal_left.body_entered.connect(_on_goal_left_entered)
	goal_right.body_entered.connect(_on_goal_right_entered)
	match_timer.timeout.connect(_on_time_up)
	match_timer.start()

func _process(delta: float) -> void:
	if not match_over:
		var seconds_left := int(floor(match_timer.time_left))
		timer_label.text = str(seconds_left)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func _on_goal_left_entered(body: Node) -> void:
	if body is RigidBody2D and not match_over:
		_end_match("Player 2 wins!")

func _on_goal_right_entered(body: Node) -> void:
	if body is RigidBody2D and not match_over:
		_end_match("Player 1 wins!")

func _on_time_up() -> void:
	if not match_over:
		_end_match("Draw :(")

func _end_match(message: String) -> void:
	match_over = true
	match_timer.stop()
	
	result_label.text = message
	result_label.visible = true
	
	player1.set_physics_process(false)
	player2.set_physics_process(false)
