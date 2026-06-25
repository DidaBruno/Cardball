extends Node

@export var auto_resolve: bool = false # debug: skip playing the match, random winner

@onready var card_game: Control = $CardGame
@onready var pitch: Node2D = $Pitch

var state: CardGameState

func _ready() -> void:
	var deck := DeckBuilder.build_full_deck()
	deck.shuffle()
	state = CardGameState.new()
	state.setup(4, deck, ["Bruno", "David", "Ivo", "Fabijan"])

	# Hand the state to the card driver so it can display/drive it
	card_game.bind_state(state)

	# Listen for the card game wanting to start a duel
	card_game.duel_requested.connect(_on_duel_requested)

	# Listen for the pitch finishing a match
	pitch.match_finished.connect(_on_pitch_match_finished)

	_show_cards()

func _show_cards() -> void:
	card_game.visible = true
	pitch.visible = false
	pitch.set_process(false)
	pitch.set_physics_process(false)

func _show_pitch() -> void:
	card_game.visible = false
	pitch.visible = true
	pitch.set_process(true)
	pitch.set_physics_process(true)

func _on_duel_requested() -> void:
	if auto_resolve:
		# Debug path: skip the match, pick a random winner, feed it straight back.
		var roll := randi() % 3
		var card_winner := -1
		if roll == 0:
			card_winner = state.active_player
		elif roll == 1:
			card_winner = state.target_player
		_finish_duel(card_winner)
		return

	# Real path: map card players
	var p1_ability: Ability = state.selected_card.ability
	var p2_ability: Ability = state.opponent_card.ability
	var p1_name: String = state.name_of(state.active_player)
	var p2_name: String = state.name_of(state.target_player)
	pitch.setup_duel(p1_ability, p2_ability, p1_name, p2_name)
	_show_pitch()

func _on_pitch_match_finished(pitch_winner: int) -> void:
	var card_winner := -1
	if pitch_winner == 1:
		card_winner = state.active_player # Player 1 was the active player
	elif pitch_winner == 2:
		card_winner = state.target_player # Player 2 was the opponent
	# pitch_winner == 0 stays -1 (draw)

	await get_tree().create_timer(2.0).timeout
	_finish_duel(card_winner)

func _finish_duel(card_winner: int) -> void:
	state.resolve_duel(card_winner)
	_show_cards()
	card_game.refresh()  # tell the card driver to redraw with updated state
