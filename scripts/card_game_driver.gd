extends Control

var state: CardGameState
@onready var state_label: Label = $StateLabel
@onready var hand_label: Label = $HandLabel
@onready var info_label: Label = $InfoLabel
@onready var choice_buttons: VBoxContainer = $ChoiceButtons

func _ready() -> void:
	var deck := DeckBuilder.build_full_deck()
	deck.shuffle()

	state = CardGameState.new()
	state.setup(4, deck, ["Bruno", "David", "Ivo", "Fabijan"])
	_refresh()

# Clear and rebuild the choice buttons for the current phase.
func _rebuild_buttons() -> void:
	# Remove old buttons
	for child in choice_buttons.get_children():
		child.queue_free()

	if state.is_match_over():
		return

	match state.phase:
		CardGameState.Phase.PICK_CARD:
			for i in state.hands[state.active_player].size():
				var card: Card = state.hands[state.active_player][i]
				_add_button("%s (%s)" % [card.player_name, card.country], _on_pick_card.bind(i))

		CardGameState.Phase.PICK_OPPONENT:
			for i in state.player_count:
				if i != state.active_player and state._has_cards(i):
					_add_button("Duel %s" % state.name_of(i), _on_pick_opponent.bind(i))

		CardGameState.Phase.OPPONENT_PICKS:
			for i in state.hands[state.target_player].size():
				var card: Card = state.hands[state.target_player][i]
				_add_button("%s (%s)" % [card.player_name, card.country], _on_opponent_pick.bind(i))

		CardGameState.Phase.REVEAL:
			# manual winner choice for testing
			_add_button("%s wins" % state.name_of(state.active_player), _on_resolve.bind(state.active_player))
			_add_button("%s wins" % state.name_of(state.target_player), _on_resolve.bind(state.target_player))
			_add_button("Draw", _on_resolve.bind(-1))

		CardGameState.Phase.RESOLVED:
			_add_button("Next turn", _on_next_turn)

func _add_button(label: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	choice_buttons.add_child(btn)

# Button callbacks
func _on_pick_card(index: int) -> void:
	state.pick_card(index)
	_refresh()

func _on_pick_opponent(index: int) -> void:
	state.pick_opponent(index)
	_refresh()

func _on_opponent_pick(index: int) -> void:
	state.opponent_pick_card(index)
	_refresh()

func _on_resolve(winner_index: int) -> void:
	state.resolve_duel(winner_index)
	_refresh()

func _on_next_turn() -> void:
	var reshuffled: Array = []
	if state._players_with_cards() < 2:
		reshuffled = state.used_pile.duplicate()
		reshuffled.shuffle()
	state.advance_turn(reshuffled)
	_refresh()

func _refresh() -> void:
	_rebuild_buttons()

	if state.is_match_over():
		state_label.text = "MATCH OVER — %s wins!" % state.name_of(state.winner)
		hand_label.text = ""
		info_label.text = ""
		return

	var score_str := ""
	for i in state.player_count:
		score_str += "%s: %d   " % [state.name_of(i), state.scores[i]]
	state_label.text = "Turn: %s   Phase: %s\nScores: %s" % [
		state.name_of(state.active_player), state.get_phase_name(), score_str
	]

	hand_label.text = _describe_current_phase()

	if state.last_winner >= 0:
		info_label.text = "Last duel won by %s" % state.name_of(state.last_winner)
	elif state.phase == CardGameState.Phase.RESOLVED:
		info_label.text = "Last duel was a draw"
	else:
		info_label.text = ""

func _describe_current_phase() -> String:
	match state.phase:
		CardGameState.Phase.PICK_CARD:
			return "%s, pick a card:" % state.name_of(state.active_player)
		CardGameState.Phase.PICK_OPPONENT:
			return "%s plays %s. Pick who to duel:" % [state.name_of(state.active_player), state.selected_card.player_name]
		CardGameState.Phase.OPPONENT_PICKS:
			return "%s, pick your card to defend:" % state.name_of(state.target_player)
		CardGameState.Phase.REVEAL:
			return "REVEAL: %s (%s) vs %s (%s) — pick the winner:" % [
				state.name_of(state.active_player), state.selected_card.player_name,
				state.name_of(state.target_player), state.opponent_card.player_name
			]
		CardGameState.Phase.RESOLVED:
			return "Duel done."
		_:
			return ""
