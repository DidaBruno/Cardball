extends Node2D

# 1 = Player1 won, 2 = Player2 won, 0 = draw
signal match_finished(pitch_winner: int)  

@onready var goal_left: Area2D = $GoalLeft
@onready var goal_right: Area2D = $GoalRight
@onready var match_timer: Timer = $MatchTimer
@onready var timer_label: Label = $TimerLabel
@onready var result_label: Label = $ResultLabel
@onready var player1: CharacterBody2D = $Player1
@onready var player2: CharacterBody2D = $Player2
@onready var ball: RigidBody2D = $Ball
@onready var player1_score_label: Label = $Player1ScoreLabel
@onready var player2_score_label: Label = $Player2ScoreLabel
@onready var player1_ability_label: Label = $Player1AbilityLabel
@onready var player2_ability_label: Label = $Player2AbilityLabel
@onready var player1_ability_timer_label: Label = $Player1AbilityTimerLabel
@onready var player2_ability_timer_label: Label = $Player2AbilityTimerLabel
@onready var versus_label: Label = $VersusLabel

var player1_score: int = 0
var player2_score: int = 0
var match_over: bool = false
var player1_start_pos: Vector2
var player2_start_pos: Vector2
var ball_start_pos: Vector2

func _ready() -> void:
	player1_score_label.text = "0"
	player2_score_label.text = "0"
	player1_start_pos = player1.global_position
	player2_start_pos = player2.global_position
	ball_start_pos = ball.global_position
	
	result_label.visible = false
	goal_left.body_entered.connect(_on_goal_left_entered)
	goal_right.body_entered.connect(_on_goal_right_entered)
	match_timer.timeout.connect(_on_time_up)
	match_timer.start()

func _process(delta: float) -> void:
	if not match_over:
		var seconds_left := int(floor(match_timer.time_left))
		seconds_left = max(seconds_left, 0)
		timer_label.text = str(seconds_left)

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

	player1_ability_label.text = str(int(player1.ability_charge * 100)) + "%"
	player2_ability_label.text = str(int(player2.ability_charge * 100)) + "%"
	
	if player1.ability:
		player1_ability_timer_label.text = "%.1f" % player1.ability.get_time_remaining()
	if player2.ability:
		player2_ability_timer_label.text = "%.1f" % player2.ability.get_time_remaining()

func _on_goal_left_entered(body: Node) -> void:
	if body is RigidBody2D and not match_over:
		player2_score += 1
		_update_score_labels()
		_reset_positions()


func _on_goal_right_entered(body: Node) -> void:
	if body is RigidBody2D and not match_over:
		player1_score += 1
		_update_score_labels()
		_reset_positions()

func _update_score_labels() -> void:
	player1_score_label.text = str(player1_score)
	player2_score_label.text = str(player2_score)

func _reset_positions() -> void:
	player1.global_position = player1_start_pos
	player1.velocity = Vector2.ZERO
	if player1.ability:
		player1.ability.reset(player1)

	player2.global_position = player2_start_pos
	player2.velocity = Vector2.ZERO
	if player2.ability:
		player2.ability.reset(player2)

	var ball_target_pos: Vector2 = ball_start_pos

	if player1_score < player2_score:
		ball_target_pos.x = lerp(player1_start_pos.x, ball_start_pos.x, 0.5)
	elif player2_score < player1_score:
		ball_target_pos.x = lerp(player2_start_pos.x, ball_start_pos.x, 0.5)
	
	var _force_sync: Vector2 = ball.global_position  # force transform sync before deferred set
	
	ball.set_deferred("global_position", ball_target_pos)
	ball.set_deferred("linear_velocity", Vector2.ZERO)
	ball.set_deferred("angular_velocity", 0.0)

func _on_time_up() -> void:
	if not match_over:
		var pitch_winner := 0  # default draw
		if player1_score > player2_score:
			pitch_winner = 1
		elif player2_score > player1_score:
			pitch_winner = 2

		_end_match(_result_message(pitch_winner))
		match_finished.emit(pitch_winner)

func _result_message(pitch_winner: int) -> String:
	match pitch_winner:
		1: return "Player 1 Wins!"
		2: return "Player 2 Wins!"
		_: return "Draw!"

func _end_match(message: String) -> void:
	match_over = true
	match_timer.stop()
	
	result_label.text = message
	result_label.visible = true
	
	player1.set_physics_process(false)
	player2.set_physics_process(false)

func setup_duel(p1_ability: Ability, p2_ability: Ability, p1_name: String, p2_name: String) -> void:
	# Assign abilities for this duel
	player1.ability = p1_ability.duplicate() if p1_ability else null
	player2.ability = p2_ability.duplicate() if p2_ability else null
	
	# Reset scores/charge/state for a fresh match
	player1_score = 0
	player2_score = 0
	match_over = false
	player1.ability_charge = 0.0
	player2.ability_charge = 0.0
	player1.speed_modifier = 1.0
	player2.speed_modifier = 1.0
	
	versus_label.text = "%s  vs  %s" % [p1_name, p2_name]
	
	_update_score_labels()
	result_label.visible = false
	_reset_positions()
	match_timer.start()
	
	# unfreeze players in case they were frozen from a previous match
	player1.set_physics_process(true)
	player2.set_physics_process(true)
