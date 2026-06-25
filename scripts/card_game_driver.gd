extends Control

signal duel_requested

var state: CardGameState
@onready var state_label: Label = $StateLabel
@onready var hand_label: Label = $HandLabel
@onready var info_label: Label = $InfoLabel
@onready var choice_buttons: VBoxContainer = $ChoiceButtons

func _ready() -> void:
	pass

func bind_state(game_state: CardGameState) -> void:
	state = game_state
	_refresh()

func refresh() -> void:
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
				_add_button("%s (%s)" % [card.player_name, card.country], _on_pick_card.bind(i), card.is_special)

		CardGameState.Phase.PICK_OPPONENT:
			for i in state.player_count:
				if i != state.active_player and state._has_cards(i):
					_add_button("Duel %s" % state.name_of(i), _on_pick_opponent.bind(i))

		CardGameState.Phase.OPPONENT_PICKS:
			for i in state.hands[state.target_player].size():
				var card: Card = state.hands[state.target_player][i]
				_add_button("%s (%s)" % [card.player_name, card.country], _on_opponent_pick.bind(i), card.is_special)

		CardGameState.Phase.REVEAL:
			_add_button("Start Duel!", _on_start_duel)

		CardGameState.Phase.RESOLVED:
			_add_button("Next turn", _on_next_turn)

func _add_button(label: String, callback: Callable, is_special: bool = false) -> void:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	
	# temporary way to highlight special cards
	if is_special:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.4, 0.9)  # blue background
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", Color.WHITE)  # readable on blue
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

func _on_start_duel() -> void:
	duel_requested.emit()

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
